# 03. Модель данных

Все сущности персистятся локально в Drift (SQLite). Ниже — доменные entity,
таблицы, связи, индексы и стратегия миграций.

## 1. Обзор сущностей

| Сущность | Назначение |
|----------|-----------|
| `UserProfile` | параметры тела и предпочтения (один экземпляр) |
| `ClothingItem` | вещь гардероба |
| `Outfit` | сохранённый комплект |
| `OutfitItem` | связь many-to-many образ↔вещь |
| `WearLog` | факт носки вещи/образа (для cost-per-wear) |
| `MeasurementLog` | замер тела на дату |
| `KnowledgeArticle` | статья энциклопедии (Markdown) |
| `Habit` | привычка |
| `HabitLog` | отметка выполнения привычки |
| `XpEvent` | начисление опыта |
| `Achievement` | достижение |
| `PurchaseWish` | желаемая покупка |
| `DailyMission` | задача дня на Dashboard |
| `HealthMarker` | замер мужского здоровья (анализ/показатель на дату) |

> Всего **14 Drift-таблиц** и **10 DAO** (проверено против `app_database.dart`,
> схема v7, июнь 2026).

## 2. Доменные модели (freezed)

### UserProfile
```
height: double            // см
weight: double            // кг
waist: double             // см
chest: double             // см
hips: double              // см
shoulders: double         // см
neck: double              // см
shoeSize: double          // EU
stylePreference: List<StyleTag>
colorPreference: List<String>   // hex или имена
budgetPreference: BudgetTier    // low / medium / high
restrictions: List<String>      // запреты/неудобства
updatedAt: DateTime
```

### ClothingItem
```
id: String (uuid)
name: String
category: ClothingCategory   // enum
brand: String?
size: String?
color: String?               // основной цвет (hex/имя)
material: String?
season: Season               // enum: spring/summer/autumn/winter/all
fit: Fit                     // enum: slim/regular/relaxed/...
price: double?
purchaseDate: DateTime?
imagePath: String?           // путь к локальному файлу
notes: String?
condition: Condition         // enum: new/good/worn/retired
rating: int?                 // 1..5 удобство
wearCount: int               // денормализовано из WearLog (кеш)
isAvailable: bool            // не в стирке/не убрано
createdAt: DateTime
```
Производное: `costPerWear = price / max(wearCount, 1)`.

### Outfit
```
id: String
name: String
occasion: Occasion           // enum
weather: WeatherCondition    // enum
temperatureC: int?
dressCode: DressCode         // enum
season: Season
items: List<String>          // id вещей (через OutfitItem)
score: double                // итоговый score на момент сборки
scoreBreakdown: OutfitScore  // fit/color/occasion/weather/comfort
notes: String?
createdAt: DateTime
```

### OutfitScore (value object, не таблица)
```
fitScore: double
colorScore: double
occasionScore: double
weatherScore: double
comfortScore: double
total: double                // взвешенная сумма
explanation: List<String>    // объяснимость: почему такой score
```

### MeasurementLog
```
id: String
date: DateTime
weight: double?
waist: double?
chest: double?
hips: double?
steps: int?
notes: String?
```

### KnowledgeArticle
```
id: String
title: String
category: KnowledgeCategory  // enum
tags: List<String>
contentMarkdown: String
sourceRef: String?
favorite: bool
bookmarked: bool
createdAt: DateTime
```

### Habit
```
id: String
title: String
target: int                  // целевое число (раз/день|неделю)
period: HabitPeriod          // daily/weekly
streak: int                  // текущий стрик (кеш)
active: bool
createdAt: DateTime
```

### XpEvent
```
id: String
type: XpType                 // style/fitness/etiquette/reading/career/finance/general
amount: int
reason: String
createdAt: DateTime
```

### Achievement
```
id: String
code: String                 // уникальный код ачивки
title: String
description: String
unlocked: bool
unlockedAt: DateTime?
```

### PurchaseWish
```
id: String
itemName: String
category: ClothingCategory
priority: int                // 1..5
budget: double?
reason: String?
status: WishStatus           // wish/planned/bought/rejected
createdAt: DateTime
```

### HealthMarker
```
id: String
type: HealthMarkerType       // enum: 16 маркеров (тестостерон общий/свободный,
                             //   ГСПГ, ПСА, витамин D, ферритин, ЛПНП, ЛПВП,
                             //   глюкоза, HbA1c, ТТГ, давление сис./диа.,
                             //   пульс покоя, % жира, часы сна)
value: double
measuredAt: DateTime
notes: String?
```
Статус (`HealthStatus`: normal / warning / risk / unknown) и референсные
диапазоны — производные, вычисляются в `health_marker.dart` (чистая логика,
не хранятся). См. [14-ai-integration.md](14-ai-integration.md) §5 (ИИ-разбор).

## 3. Таблицы Drift и связи

```
user_profile        (single row, id = 0)
clothing_items      (id PK)
outfits             (id PK)
outfit_items        (outfit_id FK, item_id FK)        -- many-to-many
wear_logs           (id PK, item_id FK, outfit_id FK?, worn_at)
measurement_logs    (id PK, date)
knowledge_articles  (id PK)
habits              (id PK)
habit_logs          (id PK, habit_id FK, date)
xp_events           (id PK, created_at)
achievements        (id PK, code UNIQUE)
purchase_wishes     (id PK)
daily_missions      (id PK, date, completed)
health_markers      (id PK, type, measured_at)
```

Связи:
- `Outfit 1—N OutfitItem N—1 ClothingItem` (many-to-many через `outfit_items`).
- `ClothingItem 1—N WearLog` (носки) → агрегируется в `wearCount`.
- `Habit 1—N HabitLog`.

### Индексы
- `clothing_items(category)`, `clothing_items(season)`, `clothing_items(brand)` — фильтры гардероба.
- `wear_logs(item_id)` — cost-per-wear.
- `measurement_logs(date)` — графики.
- `xp_events(created_at)`, `xp_events(type)` — расчёт уровней/навыков.
- `daily_missions(date)` — выборка задач дня.

## 4. Enum-словари

- `ClothingCategory`: shirt, polo, tShirt, trousers, jeans, blazer, jacket, coat, shoes, accessory.
- `Season`: spring, summer, autumn, winter, all.
- `Fit`: slim, regular, relaxed, comfort, straight.
- `Condition`: new, good, worn, retired.
- `Occasion`: everyday, work, business, formal, smartCasual, sport, date, travel.
- `WeatherCondition`: sunny, cloudy, rain, snow, windy, hot, cold.
- `DressCode`: casual, smartCasual, businessCasual, business, blackTie.
- `KnowledgeCategory`: style, etiquette, grooming, fabrics, shoes, suits, casual, health, discipline, reading.
- `XpType`: style, fitness, etiquette, reading, career, finance, general, health.
- `WishStatus`: wish, planned, bought, rejected.
- `BudgetTier`: low, medium, high.
- `HabitPeriod`: daily, weekly.

Enum хранятся как int (index) или текст через `TypeConverter` Drift.

## 5. Маппинг слоёв

```
Drift row (data table)  ──DAO──>  DTO (json_serializable)  ──mapper──>  Domain entity (freezed)
```

- DAO возвращает Drift-классы (data rows).
- Mapper'ы конвертируют в доменные entity (и обратно для записи).
- DTO используются для экспорта/импорта (json).

## 6. Миграции

`schemaVersion` сейчас **7**. Фактическая цепочка `onUpgrade` (из
`app_database.dart`):

| from → to | Что делает |
|-----------|-----------|
| 1 → 2 | сид статей базы знаний V2 (`_seedKnowledgeArticlesV2`) |
| 2 → 3 | `addColumn` `knowledge_articles.readAt` (статус «прочитано») |
| 3 → 4 | `createTable` `health_markers` |
| 4 → 5 | сид health-статей базы знаний |
| 5 → 6 | сид health-привычек (сон / шаги / вода) |
| 6 → 7 | пересев базовых статей (фикс категории `discipline-habits`: 9→8) |

- `onCreate` — `createAll()` + полный сид стартового контента (см.
  [10-seed-content.md](10-seed-content.md)).
- Все шаги идемпотентны (`insertOnConflictUpdate` / `insertOrIgnore`).
- Миграционный тест `v1→v7 без потери данных` — в бэклоге качества
  ([12-production-plan.md](12-production-plan.md) Эпик 4.4).

## 7. Экспорт / импорт (схема файла)

```json
{
  "schemaVersion": 7,
  "exportedAt": "2026-06-22T10:00:00Z",
  "userProfile": { ... },
  "clothingItems": [ ... ],
  "outfits": [ ... ],
  "outfitItems": [ ... ],
  "wearLogs": [ ... ],
  "measurementLogs": [ ... ],
  "knowledgeArticles": [ ... ],
  "habits": [ ... ],
  "habitLogs": [ ... ],
  "xpEvents": [ ... ],
  "achievements": [ ... ],
  "purchaseWishes": [ ... ],
  "dailyMissions": [ ... ],
  "healthMarkers": [ ... ]
}
```

- Изображения опционально упаковываются в zip рядом с json (пути перезаписываются при импорте).
- При импорте: проверить `schemaVersion`, при необходимости мигрировать, затем
  применить транзакционно (replace или merge — выбор пользователя).

## 8. Денормализация и инварианты

- `ClothingItem.wearCount` — кеш от `wear_logs`; пересчитывается при добавлении/удалении носки.
- `Habit.streak` — кеш от `habit_logs`; пересчитывается при отметке.
- Уровень/навыки RPG **не** хранятся как поля — вычисляются из `xp_events`
  (единый источник истины), при необходимости кешируются в памяти.
- Инвариант: образ ссылается только на существующие, доступные вещи; при удалении
  вещи — каскадно чистить `outfit_items` или помечать образ неполным.
