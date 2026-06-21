# Gentleman OS

Личное офлайн-приложение для одного пользователя — система принятия решений
для современного мужчины: что надеть, что купить, что улучшить, как выглядеть
собраннее и не ошибаться с посадкой, цветами и дресс-кодом.

> Главная ценность приложения — не «знание ради знания», а быстрый ответ на
> бытовой вопрос: **«что делать сегодня»**.

## Что это

Gentleman OS — это **offline-first, local-only, feature-first** приложение на
Flutter (Android). Оно объединяет:

- профиль тела и размеров;
- цифровой гардероб;
- генератор образов (outfit builder);
- личную базу знаний по стилю и этикету;
- трекер веса, талии и привычек;
- **модуль мужского здоровья** (анализы, индекс, ИИ-разбор);
- RPG-слой мотивации (уровни, XP, навыки, ачивки);
- советник по покупкам;
- **опциональный облачный ИИ-советник** (RouterAI) поверх оффлайн-ядра.

## Принципы

- **Приватность.** Все данные хранятся локально. Ничего не отправляется без
  явного действия пользователя.
- **Скорость.** Основной UI не ждёт сеть. Запуск быстрый, списки ленивые.
- **Простота.** Никакой соцсети, чата для всех, маркетплейса или мультипользователя.
- **Объяснимость.** Рекомендации строятся на понятных правилах, а не на чёрном ящике.

## Документация плана

| Документ | Назначение |
|----------|-----------|
| [docs/00-overview.md](docs/00-overview.md) | Обзор, цели, нефункциональные требования |
| [docs/01-prd.md](docs/01-prd.md) | Product Requirements Document |
| [docs/02-architecture.md](docs/02-architecture.md) | Техническая архитектура, слои, стек |
| [docs/03-data-model.md](docs/03-data-model.md) | Сущности, DTO, DAO, таблицы, миграции |
| [docs/04-navigation-and-screens.md](docs/04-navigation-and-screens.md) | Карта навигации, список экранов и компонентов |
| [docs/05-recommendation-engine.md](docs/05-recommendation-engine.md) | Логика рекомендаций и scoring образов |
| [docs/06-rpg-and-gamification.md](docs/06-rpg-and-gamification.md) | RPG-слой: XP, уровни, навыки, ачивки |
| [docs/07-roadmap.md](docs/07-roadmap.md) | Дорожная карта, этапы, спринт-бэклог |
| [docs/08-test-plan.md](docs/08-test-plan.md) | План тестирования |
| [docs/09-folder-structure.md](docs/09-folder-structure.md) | Структура каталогов проекта |
| [docs/10-seed-content.md](docs/10-seed-content.md) | Сидовый контент и стартовые данные |
| [docs/11-agent-build-prompt.md](docs/11-agent-build-prompt.md) | Промпт для кодирующего агента |
| [docs/12-production-plan.md](docs/12-production-plan.md) | Производственный план до релиза 1.0 |
| [docs/13-packages-spec.md](docs/13-packages-spec.md) | Спецификация пакетов (версии июнь 2026 + ссылки) |
| [docs/14-ai-integration.md](docs/14-ai-integration.md) | Интеграция RouterAI и логирование |

## Технологический стек (актуально, июнь 2026)

| Слой | Технология | Версия |
|------|-----------|--------|
| Среда | Flutter / Dart | 3.44 / 3.9+ |
| UI | Flutter + Material 3 | — |
| Состояние / DI | flutter_riverpod | ^3.3.2 |
| Навигация | go_router | ^17.3.0 |
| Локальная БД | drift (SQLite) | ^2.34.0 |
| Модели | freezed | ^3.2.5 |
| Сериализация | json_serializable | ^6.14.0 |
| Безопасное хранилище | flutter_secure_storage | ^10.3.1 |
| Графики | fl_chart | ^1.2.0 |
| Markdown | flutter_markdown_plus | ^1.0.7 |
| HTTP / ИИ | http + RouterAI | ^1.6.0 |

> Полная спецификация версий и ссылки на документацию: [docs/13-packages-spec.md](docs/13-packages-spec.md).

## Сборка

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze --no-fatal-infos
flutter test --coverage
flutter build apk --debug   # build/app/outputs/flutter-apk/app-debug.apk
```

## Статус

Реализованы Milestones 1–10 + модули **мужского здоровья**, **аниме-маскота** и
**ИИ-советника** (RouterAI). Дальнейший план — [docs/12-production-plan.md](docs/12-production-plan.md).
Реализация ведётся поэтапно согласно [docs/07-roadmap.md](docs/07-roadmap.md).
