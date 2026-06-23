# 04. Навигация и экраны

## 1. Карта навигации (go_router)

Корневой `ShellRoute` с нижней навигацией на 5 основных разделов; остальные —
вложенные/модальные маршруты.

```
/
├── /dashboard                         (ShellRoute tab 1) — Dashboard
├── /wardrobe                          (ShellRoute tab 2) — список гардероба
│    ├── /wardrobe/add                 — добавить вещь
│    └── /wardrobe/:itemId             — карточка вещи
│         └── /wardrobe/:itemId/edit   — редактировать
├── /outfits                           (ShellRoute tab 3) — образы
│    ├── /outfits/build                — outfit builder (входные параметры → подборки)
│    ├── /outfits/:outfitId            — детали образа
│    └── /outfits/:outfitId/rate       — оценить после носки
├── /knowledge                         (ShellRoute tab 4) — база знаний
│    ├── /knowledge/:articleId         — статья (Markdown)
│    └── /knowledge/search             — поиск
├── /progress                          (ShellRoute tab 5) — прогресс (fitness + RPG)
│    ├── /progress/measurements        — замеры и графики
│    ├── /progress/measurements/add    — добавить замер
│    ├── /progress/rpg                 — RPG-экран (уровень, навыки, ачивки)
│    └── /progress/habits              — привычки
├── /profile                           — профиль (из Dashboard/Settings)
│    └── /profile/edit                 — редактировать профиль
├── /purchases                         — советник по покупкам
│    └── /purchases/add                — добавить желаемое
└── /settings                          — настройки
     └── /settings/logs                — журнал отладки
```

Экспорт/импорт/резервная копия/очистка — это **действия внутри** экрана
настроек (диалоги + системный «Поделиться»), а не отдельные маршруты.

Типобезопасные маршруты — через `go_router_builder` (`@TypedGoRoute`).

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

### 2.11 Progress (`/progress`)
- сводка: вес, талия, тренд;
- быстрые ссылки на Measurements, RPG, Habits.

### 2.12 Measurements (`/progress/measurements`)
- графики (вес, талия, грудь) по периодам;
- история записей;
- FAB «добавить замер».

### 2.13 RPG (`/progress/rpg`)
- уровень и прогресс-бар XP;
- навыки (style, fitness, etiquette, reading, career, finance) с уровнями;
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
- экспорт / импорт;
- резервная копия;
- очистка данных;
- ключ облачного ИИ (RouterAI);
- журнал отладки (`/settings/logs`);
- о приложении.

### 2.17 Журнал отладки (`/settings/logs`)
Показывает последние записи `AppLogger` (кольцевой буфер, 500 записей текущей
сессии), обновляется в реальном времени. В журнал попадают: старт приложения,
**все необработанные ошибки/исключения** (перехват в `main.dart`), переходы по
экранам и события AI/хранилища. Возможности: фильтр по уровню
(DEBUG/INFO/WARN/ERROR), копирование в буфер обмена, **выгрузка всего журнала
в `.md`-файл** через системный «Поделиться» (`AppLogger.dumpMarkdown()`),
очистка. Полезно для багрепортов; секреты в логах маскируются.

## 3. Список UI-компонентов (переиспользуемые)

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
