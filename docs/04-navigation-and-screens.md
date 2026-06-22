# 04. Навигация и экраны

## 1. Карта навигации (go_router)

Фактическая карта маршрутов (проверено против `core/router/app_router.dart`,
июнь 2026). `initialLocation: '/dashboard'`. Корневой `ShellRoute` (с
`ShellScaffold` + нижняя навигация) оборачивает 5 основных разделов; детальные
и второстепенные экраны живут **вне** shell (открываются на весь экран).

```
ShellRoute (нижняя навигация, 5 табов)
├── /dashboard                         — Dashboard
├── /wardrobe                          — список гардероба
│    ├── /wardrobe/add                 — добавить вещь (extra: name, category)
│    └── /wardrobe/:itemId             — карточка вещи
│         └── /wardrobe/:itemId/edit   — редактировать (тот же AddItemScreen)
├── /outfits                           — список образов
│    ├── /outfits/build                — outfit builder (параметры → подборки)
│    └── /outfits/:outfitId            — детали образа
│         └── /outfits/:outfitId/rate  — оценить после носки (1–5★ + заметка)
├── /knowledge                         — база знаний (поиск inline в AppBar)
│    └── /knowledge/:articleId         — статья (Markdown)
└── /progress                          — Fitness-экран (замеры, графики, тренды)
     ├── /progress/add-measurement     — добавить замер
     ├── /progress/rpg                 — RPG (уровень, навыки, ачивки)
     └── /progress/habits              — привычки (7-дневный calendar strip)

Вне ShellRoute (full-screen):
├── /profile                           — профиль
│    └── /profile/edit                 — редактировать профиль
├── /purchases                         — советник по покупкам (5 табов по статусу)
├── /style-advisor                     — ИИ-советник по стилю/гардеробу
├── /health                            — мужское здоровье (16 маркеров, индекс)
│    └── /health/marker/:typeIndex     — деталь маркера (график динамики, ИИ-разбор)
└── /settings                          — настройки (тема, экспорт, очистка)
     └── /settings/logs                — журнал отладки
```

> ⚠️ Расхождение с планом: `go_router_builder` (`@TypedGoRoute`) подключён как
> dev-зависимость, но маршруты сейчас объявлены **императивно** в
> `app_router.dart`, без type-safe генерации. Экспорт/импорт — действия внутри
> `/settings` (диалоги/`share_plus`), а не отдельные маршруты.

## 2. Список экранов и их содержимое

### 2.1 Dashboard (`/dashboard`)
- приветствие (имя/время суток);
- **Gentleman Score** (карточка с числом и динамикой);
- 3 задачи дня (missions) с чекбоксами;
- сегодняшний образ (карточка → переход в детали);
- быстрые кнопки: Wardrobe, Outfit Builder, Measurements, Profile, Purchases.

### 2.2 Profile (`/profile`)
- замеры (рост, вес, талия, грудь, бёдра, плечи, шея, обувь);
- предпочтения (стиль, цвета, бюджет, запреты);
- цели;
- история изменений (список из MeasurementLog);
- блок «производные рекомендации» (что подходит фигуре).

### 2.3 Wardrobe (`/wardrobe`)
- сетка вещей (thumbnails);
- фильтры: категория, сезон, цвет, бренд;
- сортировка: дата, цена, cost-per-wear, рейтинг;
- поиск;
- FAB «добавить вещь».

### 2.4 Item Detail (`/wardrobe/:itemId`)
- фото;
- все атрибуты;
- cost-per-wear и число носок;
- кнопки: редактировать, добавить носку, удалить, в какой образ входит.

### 2.5 Add/Edit Item (`/wardrobe/add`, `/.../edit`)
- форма со всеми полями ClothingItem;
- выбор фото (камера/галерея);
- валидация.

### 2.6 Outfits (`/outfits`)
- список сохранённых образов (карточки с score);
- фильтр по поводу/сезону;
- FAB «собрать образ».

### 2.7 Outfit Builder (`/outfits/build`)
- входы: повод, погода, температура, сезон, дресс-код, настроение, ограничения;
- кнопка «подобрать»;
- результат: 1–3 образа с разбивкой score и объяснением;
- действия: сохранить, перегенерировать.

### 2.8 Outfit Detail (`/outfits/:outfitId`)
- вещи образа;
- score breakdown + объяснение;
- кнопка «оценить после носки».

### 2.9 Knowledge (`/knowledge`)
- список статей по категориям;
- поиск (заголовок/теги/текст);
- избранное и закладки.

### 2.10 Article (`/knowledge/:articleId`)
- Markdown-рендер;
- теги, кнопки избранное/закладка;
- источник (sourceRef).

### 2.11 Progress / Fitness (`/progress`)
- замеры (вес, талия, грудь, плечи) с тренд-дельтами (↑↓);
- графики fl_chart по метрикам;
- FAB «добавить замер» (`/progress/add-measurement`);
- быстрые ссылки на RPG (`/progress/rpg`) и привычки (`/progress/habits`).

> Отдельного экрана `/progress/measurements` нет — корневой `/progress` **и есть**
> экран замеров (`FitnessScreen`).

### 2.13 RPG (`/progress/rpg`)
- уровень и прогресс-бар XP;
- навыки (style, fitness, etiquette, reading, career, finance, health) с уровнями;
- достижения (разблокированные/закрытые);
- стрики.

### 2.14 Habits (`/progress/habits`)
- список привычек со стриками;
- отметка выполнения;
- добавить/архивировать привычку.

### 2.15 Purchases (`/purchases`)
- список желаемого, отсортированный по приоритету/бюджету;
- статусы (wish/planned/bought/rejected);
- FAB «добавить».

### 2.16 Settings (`/settings`)
- тема (тёмная по умолчанию);
- экспорт (JSON через `share_plus`);
- очистка данных;
- ИИ-советник: ввод ключа RouterAI, выбор модели;
- журнал отладки (`/settings/logs`);
- о приложении.

### 2.17 Health — Мужское здоровье (`/health`)
- 16 маркеров (тестостерон, ПСА, витамин D, ферритин, холестерин и др.);
- цветовой статус (норма/внимание/риск), референсные диапазоны;
- индекс здоровья [0–100];
- кнопка ✨ — ИИ-разбор маркеров (RouterAI + веб-поиск);
- деталь маркера (`/health/marker/:typeIndex`) — график динамики;
- дисклеймер «не является медицинской рекомендацией».
- Подробнее: [14-ai-integration.md](14-ai-integration.md) §5.

### 2.18 Style Advisor (`/style-advisor`)
- ИИ-советник по гардеробу (`styleAdviceProvider`): summary + предложения;
- работает на оффлайн-правилах без ключа, на LLM — с ключом RouterAI.

## 3. Список UI-компонентов (переиспользуемые)

> Таблица ниже — **концептуальная** карта ролей. В коде реально выделены как
> переиспользуемые: `MissionTile`, `QuickActionButton`, `ClothingCard`,
> `MascotAvatar`, `EmptyState`, `AsyncValueWidget` (loading/empty/error/data в
> одном виджете). Остальные роли реализованы инлайн в экранах, без отдельных
> классов.

| Компонент | Где используется |
|-----------|------------------|
| `ScoreCard` | Dashboard (Gentleman Score), Outfit score |
| `MissionTile` | Dashboard (задачи дня) |
| `QuickActionButton` | Dashboard (быстрые кнопки) |
| `ClothingCard` | Wardrobe (сетка) |
| `AttributeRow` | Item detail, Profile |
| `OutfitCard` | Outfits, Dashboard |
| `ScoreBreakdownChart` | Outfit detail/builder (5 осей) |
| `ExplanationList` | Outfit detail (объяснимость) |
| `FilterChipBar` | Wardrobe, Knowledge |
| `ArticleCard` | Knowledge |
| `MarkdownView` | Article |
| `MetricChart` | Measurements, Progress (fl_chart) |
| `XpProgressBar` | RPG |
| `SkillTile` | RPG |
| `AchievementBadge` | RPG |
| `HabitTile` | Habits |
| `WishTile` | Purchases |
| `EmptyState` | все списки |
| `LoadingState` / `ErrorState` | async-экраны |
| `AppFormField` | все формы |
| `ConfirmDialog` | удаление/очистка |

## 4. Состояния экранов

Каждый async-экран обрабатывает 4 состояния:
`loading` → `empty` → `error` → `data`. Это единый паттерн через
`AsyncValue` Riverpod.

## 5. Доступность

- Тёмная тема по умолчанию, высокий контраст.
- Touch targets ≥ 48dp.
- Крупные заголовки (Material 3 typography).
- Семантические лейблы для скринридеров на иконках-кнопках.
