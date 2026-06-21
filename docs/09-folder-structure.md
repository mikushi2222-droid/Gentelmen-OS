# 09. Структура каталогов

Feature-first + layered. Каждая фича самодостаточна и содержит свои слои.

```text
gentleman_os/
├── android/
├── lib/
│   ├── main.dart                      # ProviderScope + MaterialApp.router
│   ├── app.dart                       # корневой виджет приложения
│   │
│   ├── core/                          # кросс-слойные сервисы
│   │   ├── theme/
│   │   │   ├── app_theme.dart         # Material 3, тёмная тема default
│   │   │   ├── app_colors.dart
│   │   │   └── app_typography.dart
│   │   ├── router/
│   │   │   ├── app_router.dart        # go_router + ShellRoute
│   │   │   └── routes.dart            # типобезопасные маршруты (builder)
│   │   ├── db/
│   │   │   ├── app_database.dart      # Drift AppDatabase
│   │   │   ├── tables/               # объявления таблиц
│   │   │   ├── converters/           # TypeConverter'ы (enum, списки)
│   │   │   └── migrations.dart        # MigrationStrategy
│   │   ├── widgets/                   # общие виджеты
│   │   │   ├── empty_state.dart
│   │   │   ├── loading_state.dart
│   │   │   ├── error_state.dart
│   │   │   ├── score_card.dart
│   │   │   └── app_form_field.dart
│   │   ├── utils/                     # форматтеры, расширения
│   │   ├── result/                    # Result/Either, Failure
│   │   └── constants/                 # enum-словари, пороги, xp/scoring константы
│   │
│   ├── features/
│   │   ├── dashboard/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── profile/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── wardrobe/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── outfit_builder/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/             # outfit_scorer, fit_rules, color_harmony, generator
│   │   │   └── data/
│   │   ├── knowledge/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── fitness/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── rpg/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/             # level_calculator, achievement_rules, gentleman_score
│   │   │   └── data/
│   │   ├── purchases/
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   └── settings/
│   │       ├── presentation/
│   │       ├── application/        # export/import use cases
│   │       ├── domain/
│   │       └── data/
│   │
│   └── shared/                        # доменные модели, используемые многими фичами
│       ├── models/                    # freezed entities (ClothingItem, Outfit, ...)
│       └── enums/                     # ClothingCategory, Season, Fit, ...
│
├── assets/
│   ├── knowledge/                     # сид-статьи Markdown
│   └── seed/                          # стартовые данные (json)
│
├── test/
│   ├── unit/
│   │   ├── recommendation/
│   │   ├── rpg/
│   │   └── repositories/
│   ├── widget/
│   ├── golden/
│   └── migration/
├── integration_test/
│
├── pubspec.yaml
├── analysis_options.yaml              # строгий линтинг
├── build.yaml                         # конфиг кодгена
└── README.md
```

## Правила размещения

- **Доменные модели, общие для нескольких фич** (ClothingItem, Outfit, enums) →
  `shared/`. Узкоспецифичные для фичи модели — внутри её `domain/`.
- Движок рекомендаций живёт в `features/outfit_builder/domain/` (чистый Dart).
- RPG-логика — в `features/rpg/domain/`.
- Никаких импортов Flutter/Drift в `domain/`.
- `presentation` импортирует `application` и `domain`; `data` реализует
  интерфейсы из `domain`.

## Конфиг линтинга (`analysis_options.yaml`)

- `include: package:flutter_lints/flutter.yaml` + дополнительные строгие правила
  (prefer_const, require_trailing_commas, avoid_print и т.п.).
- Запрет прямого импорта `core/db` из `presentation` (через ревью/конвенцию).
