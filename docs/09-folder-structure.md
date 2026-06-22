# 09. Структура каталогов

Feature-first + layered. Каждая фича самодостаточна и содержит свои слои.

Фактическое дерево (проверено против репозитория, июнь 2026):

```text
gentleman_os/
├── android/
├── lib/
│   ├── main.dart                      # ProviderScope + bootstrap
│   ├── app.dart                       # MaterialApp.router + тема
│   │
│   ├── core/                          # кросс-слойные сервисы
│   │   ├── ai/                        # ИИ-слой (порт + реализации)
│   │   │   ├── ai_advisor.dart        # порт AiAdvisor
│   │   │   ├── local_ai_advisor.dart  # оффлайн-движок
│   │   │   ├── router_ai_advisor.dart # облачный советник + fallback
│   │   │   ├── router_ai_client.dart  # OpenAI-совместимый HTTP-клиент
│   │   │   ├── router_ai_config.dart  # конфиг + ключ (secure storage)
│   │   │   ├── ai_advisor_provider.dart
│   │   │   └── style_advice.dart
│   │   ├── theme/                     # app_theme.dart, app_colors.dart (Material 3)
│   │   ├── router/                    # app_router.dart (ShellRoute), shell_scaffold.dart
│   │   ├── db/
│   │   │   ├── app_database.dart      # Drift AppDatabase + миграции + сид (inline)
│   │   │   ├── tables/                # 14 объявлений таблиц
│   │   │   ├── daos/                  # 10 DAO
│   │   │   └── database_provider.dart
│   │   ├── services/                  # xp_service, achievement_service, services_provider
│   │   ├── widgets/                   # async_value_widget, empty_state, mascot_avatar
│   │   └── utils/                     # app_logger.dart, date_utils.dart
│   │
│   ├── features/                      # каждая фича: presentation / application / domain / data
│   │   ├── dashboard/                 # domain/mission_generator.dart
│   │   ├── wardrobe/                  # domain/wear_forecast.dart
│   │   ├── outfit_builder/            # domain/{outfit_scorer,fit_rules,color_harmony,
│   │   │                              #         occasion_rules,weather_rules,outfit_generator}
│   │   ├── knowledge/
│   │   ├── fitness/
│   │   ├── habits/
│   │   ├── health/                    # domain/{health_marker,health_ai_analyzer}
│   │   ├── rpg/                        # domain/level_calculator.dart
│   │   ├── purchases/
│   │   ├── profile/
│   │   ├── style_advisor/
│   │   └── settings/                  # domain/export_service.dart
│   │
│   └── shared/                        # доменные модели, используемые многими фичами
│       ├── models/                    # freezed: clothing_item, outfit, user_profile, knowledge_article
│       └── enums/                     # clothing_category, season, fit, xp_type, ... (10 enum)
│
├── assets/
│   ├── knowledge/                     # каталог Markdown (сид сейчас захардкожен в app_database.dart)
│   ├── seed/
│   └── images/
│
├── test/
│   ├── unit/                          # ai, dashboard, health, mascot, outfit,
│   │                                  # profile, recommendation, rpg, wardrobe
│   └── widget/                        # core, dashboard, wardrobe
│
├── pubspec.yaml
├── analysis_options.yaml              # flutter_lints + строгие правила
└── README.md
```

> Не все фичи имеют все четыре слоя — простые экраны (например, `style_advisor`)
> содержат только `presentation/`. Слои добавляются по мере надобности, без
> пустых заглушек.

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
  (`prefer_const_constructors`, `require_trailing_commas`, `avoid_print`,
  `always_use_package_imports` и др.).
- `exclude`: `**/*.g.dart`, `**/*.freezed.dart` (генерируемые файлы).
- `custom_lint`/`riverpod_lint` **удалены** (июнь 2026) из-за конфликта
  `analyzer_plugin` — см. [15-ci-and-build.md](15-ci-and-build.md) §7.
- Запрет прямого импорта `core/db` из `presentation` — через ревью/конвенцию
  (не форсируется линтером).
