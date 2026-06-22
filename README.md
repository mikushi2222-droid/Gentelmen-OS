# Gentleman OS

Личное офлайн-приложение для одного пользователя — система принятия решений
для современного мужчины: что надеть, что купить, что улучшить, как выглядеть
собраннее и не ошибаться с посадкой, цветами и дресс-кодом.

> Главная ценность приложения — не «знание ради знания», а быстрый ответ на
> бытовой вопрос: **«что делать сегодня»**.

## Что это

Gentleman OS — это **offline-first, local-only, feature-first** приложение на
Flutter (Android). Оно объединяет:

- профиль тела и размеров с рекомендациями под фигуру;
- цифровой гардероб (CRUD, фото, cost-per-wear, поиск, прогноз носки);
- генератор образов (outfit builder) со scoring по 5 осям + разбивка по компонентам;
- личную базу знаний по стилю и этикету (Markdown, закладки, время чтения);
- трекер веса, талии и привычек (7-дневный визуальный календарь);
- **модуль мужского здоровья** (16 маркеров, индекс, ИИ-разбор с рекомендациями);
- RPG-слой мотивации (уровни, XP по 8 типам, Gentleman Score из 5 компонентов, ачивки, ежедневные миссии);
- советник по покупкам (правило 48ч, приоритеты, фильтрация по статусу);
- **опциональный облачный ИИ-советник** (RouterAI) поверх оффлайн-ядра.

## Принципы

- **Приватность.** Все данные хранятся локально. Ничего не отправляется без явного действия.
- **Скорость.** Основной UI не ждёт сеть. Запуск быстрый, списки ленивые.
- **Простота.** Никакой соцсети, чата для всех, маркетплейса или мультипользователя.
- **Объяснимость.** Рекомендации строятся на понятных правилах, а не на чёрном ящике.

## Статус (июнь 2026)

| Модуль | Статус |
|--------|--------|
| Scaffold, тема, навигация | ✅ |
| Drift БД v6 + миграции | ✅ |
| Профиль + замеры + BMI | ✅ |
| Гардероб (CRUD, фото, cost-per-wear, поиск, urgency-сортировка) | ✅ |
| Прогноз носки (`WearForecast`, `WearUrgency`) | ✅ |
| Dashboard urgency strip («Надеть сегодня») | ✅ |
| Dashboard мини-блок привычек (N/total + стрик) | ✅ |
| Outfit Builder + scoring 5 осей + разбивка | ✅ |
| Outfit фильтр по поводу | ✅ |
| Оценка образа после носки (1–5 ★ + заметка) | ✅ |
| «Надеть весь образ» (batch wear) | ✅ |
| «Купил → добавить в гардероб» | ✅ |
| База знаний (Markdown, поиск, закладки/избранное, время чтения) | ✅ |
| Фитнес + графики + тренд-дельты | ✅ |
| Привычки + 7-дневный calendar strip | ✅ |
| Мужское здоровье (16 маркеров, ИИ-разбор) | ✅ |
| RPG (XP, уровни, навыки, ачивки, ежедневные миссии) | ✅ |
| Покупки (48ч правило, 5 табов по статусу) | ✅ |
| Аниме-маскот (реагирует на Gentleman Score) | ✅ |
| ИИ-слой (`AiAdvisor`, `RouterAI`, защищённый ключ) | ✅ |
| Экспорт/очистка | ✅ |
| Тесты (unit + widget) | 🟡 частично |
| CI зелёный | 🟡 требует проверки |

Ветка разработки: `claude/garment-wear-forecast-card-5o5oe8`

## Документация

| Документ | Назначение |
|----------|-----------|
| [docs/00-overview.md](docs/00-overview.md) | Обзор, цели, нефункциональные требования |
| [docs/01-prd.md](docs/01-prd.md) | Product Requirements Document |
| [docs/02-architecture.md](docs/02-architecture.md) | Техническая архитектура, слои, стек |
| [docs/03-data-model.md](docs/03-data-model.md) | Сущности, DTO, DAO, таблицы, миграции |
| [docs/04-navigation-and-screens.md](docs/04-navigation-and-screens.md) | Карта навигации, экраны, компоненты |
| [docs/05-recommendation-engine.md](docs/05-recommendation-engine.md) | Логика рекомендаций и scoring образов |
| [docs/06-rpg-and-gamification.md](docs/06-rpg-and-gamification.md) | RPG-слой: XP, уровни, навыки, ачивки |
| [docs/07-roadmap.md](docs/07-roadmap.md) | **Активная дорожная карта и бэклог V2.x** |
| [docs/08-test-plan.md](docs/08-test-plan.md) | План тестирования |
| [docs/09-folder-structure.md](docs/09-folder-structure.md) | Структура каталогов проекта |
| [docs/10-seed-content.md](docs/10-seed-content.md) | Сидовый контент и стартовые данные |
| [docs/11-agent-build-prompt.md](docs/11-agent-build-prompt.md) | Промпт для кодирующего агента |
| [docs/12-production-plan.md](docs/12-production-plan.md) | Производственный план до релиза 1.0 |
| [docs/13-packages-spec.md](docs/13-packages-spec.md) | Спецификация пакетов (версии июнь 2026) |
| [docs/14-ai-integration.md](docs/14-ai-integration.md) | Интеграция RouterAI и логирование |
| [docs/15-ci-and-build.md](docs/15-ci-and-build.md) | CI, сборка APK, раннеры, конфликты зависимостей |

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

> Полная спецификация: [docs/13-packages-spec.md](docs/13-packages-spec.md).

## Сборка

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze --no-fatal-infos
flutter test --coverage
flutter build apk --debug   # build/app/outputs/flutter-apk/app-debug.apk
```
