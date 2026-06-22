# 02. Техническая архитектура

## 1. Принцип

Приложение строится по **feature-first + layered architecture**, как рекомендует
Flutter (UI layer → logic layer → data layer). Каждая фича изолирована и содержит
собственные слои.

### Базовое правило
> **UI не знает о SQL. SQL не знает о UI.**
> Всё общение идёт через use cases и repositories. Это снижает связанность и
> делает код живучим.

## 2. Слои

```
┌─────────────────────────────────────────────┐
│  PRESENTATION  (Flutter widgets, screens)    │  ← знает о Riverpod-провайдерах
├─────────────────────────────────────────────┤
│  APPLICATION / LOGIC  (controllers, use cases,│  ← оркестрирует домен
│                        view state notifiers)  │
├─────────────────────────────────────────────┤
│  DOMAIN  (entities, value objects, интерфейсы │  ← чистый Dart, без Flutter/Drift
│           репозиториев, бизнес-правила)        │
├─────────────────────────────────────────────┤
│  DATA  (DTO, DAO, реализации repositories,    │  ← Drift, файлы, secure storage
│         mappers, источники данных)            │
└─────────────────────────────────────────────┘
```

Правила зависимостей (dependency rule):
- Presentation зависит от Application и Domain.
- Application зависит от Domain.
- Data зависит от Domain (реализует его интерфейсы).
- **Domain не зависит ни от чего** (чистый Dart).

## 3. Роль каждого слоя в фиче

Каждая `feature/<name>/` содержит:

| Подпапка | Содержимое |
|----------|-----------|
| `presentation/` | экраны, виджеты, маршруты фичи |
| `application/` (или `logic/`) | контроллеры (Notifier/AsyncNotifier), use cases, view-state |
| `domain/` | entities, value objects, интерфейсы репозиториев, бизнес-правила |
| `data/` | DTO, DAO (Drift), реализации репозиториев, мапперы |

## 4. Источник истины

**Repositories — единственный источник истины.** UI и логика никогда не ходят в
БД напрямую. Репозиторий:
- инкапсулирует DAO/Drift;
- маппит DTO ↔ domain entity;
- предоставляет потоки (`Stream`) для реактивных экранов;
- гарантирует, что все данные персистятся локально.

## 5. Управление состоянием — Riverpod

- **Notifier / AsyncNotifier** — для состояния, которое меняется со временем
  (списки, формы, view state экрана).
- **Provider** — для зависимостей (репозитории, use cases, БД).
- **StreamProvider** — для реактивных данных из Drift.
- DI реализуется через Riverpod-провайдеры (override в тестах).

Пример графа провайдеров:

```
appDatabaseProvider (Drift)
  └─ wardrobeDaoProvider
       └─ wardrobeRepositoryProvider (impl)  ──implements──>  WardrobeRepository (domain)
            └─ wardrobeListControllerProvider (AsyncNotifier)
                 └─ WardrobeScreen (presentation)
```

## 6. Навигация — go_router

- Декларативные маршруты, deep links.
- `go_router_builder` для **type-safe routes** (генерация маршрутов).
- Корневой `ShellRoute` с нижней навигацией (BottomNavigationBar / NavigationBar)
  для основных разделов; вложенные маршруты для деталей.

Карта маршрутов — в [04-navigation-and-screens.md](04-navigation-and-screens.md).

## 7. Персистентность — Drift (SQLite)

- Типобезопасные таблицы и запросы.
- Версионирование схемы и миграции (`MigrationStrategy`).
- Транзакции для crash-safe записей.
- Реактивные `watch`-запросы → `Stream` в репозиториях.
- Изображения хранятся в файловой системе приложения; в БД — только путь
  (`imagePath`).

## 8. Модели — freezed + json_serializable

- Доменные entity и DTO — неизменяемые (`@freezed`).
- `copyWith`, value-equality, паттерн-матчинг для union-типов (например, статусы).
- `json_serializable` — для экспорта/импорта и сериализации DTO.

## 9. Безопасное хранилище

`flutter_secure_storage` — только для чувствительных секретов, если они появятся
(например, будущий API-ключ ИИ-слоя). В v1 почти не используется.

## 10. Кодогенерация

`build_runner` генерирует:
- Drift-таблицы и DAO;
- freezed-модели;
- json-сериализацию;
- go_router-маршруты.

Команда: `dart run build_runner build --delete-conflicting-outputs`.

## 11. Дизайн-система — Material 3

- Material 3 — стандартная и актуальная основа дизайна Flutter.
- `ColorScheme.fromSeed` + тёмная тема по умолчанию.
- Централизованная тема (`core/theme/`), переиспользуемые виджеты (`core/widgets/`).

## 12. Кросс-слойные сервисы (core)

Фактическая структура (проверено против кода, июнь 2026):

| Модуль | Назначение |
|--------|-----------|
| `core/theme/` | `app_theme.dart`, `app_colors.dart` (Material 3, тёмная тема) |
| `core/router/` | `app_router.dart` (go_router + ShellRoute), `shell_scaffold.dart` |
| `core/db/` | `AppDatabase` (Drift), `tables/`, `daos/`, миграции (inline в `app_database.dart`) |
| `core/widgets/` | `async_value_widget.dart`, `empty_state.dart`, `mascot_avatar.dart` |
| `core/utils/` | `app_logger.dart` (кольцевой буфер логов), `date_utils.dart` |
| `core/services/` | `xp_service.dart`, `achievement_service.dart`, `services_provider.dart` |
| `core/ai/` | ИИ-слой: порт `AiAdvisor`, `LocalAiAdvisor`, `RouterAiClient` (см. [14-ai-integration.md](14-ai-integration.md)) |

> Константы scoring/XP и enum-словари живут рядом с потребляющей логикой
> (`features/*/domain/`, `shared/enums/`), а не в выделенном `core/constants/`.

## 13. Обработка ошибок

- Фактически (июнь 2026): доменные/репозиторные операции бросают исключения,
  которые ловятся на уровне провайдеров через `AsyncValue` (Riverpod
  `FutureProvider`/`StreamProvider` сами оборачивают ошибку в `AsyncError`).
  Выделенного `Result<T, Failure>`-типа в коде нет — это сознательное упрощение
  для одиночного приложения.
- ИИ-слой нормализует сетевые ошибки в `RouterAiException` с человекочитаемым
  сообщением; облачные сбои тихо откатываются на оффлайн-движок.
- UI отображает дружелюбные состояния через `AsyncValueWidget`
  (loading / empty / error / data).

## 14. Экспорт / импорт

- Экспорт — единый JSON-файл со всеми сущностями (+ опционально zip с изображениями).
- Импорт — валидация версии схемы, merge/replace стратегия, транзакционно.
- Это и есть «резервная копия» в отсутствие облака.

## 15. Тестируемость как свойство архитектуры

- Domain — чистый Dart → тривиально юнит-тестируется.
- Репозитории тестируются на in-memory Drift (NativeDatabase.memory()).
- Контроллеры тестируются с override провайдеров.
- UI — widget/golden тесты. См. [08-test-plan.md](08-test-plan.md).

## 16. Тренейдоффы (явные)

| Решение | Плюс | Минус | Почему так |
|---------|------|-------|-----------|
| Drift вместо Isar/Hive | SQL-мощь, миграции, реляции | больше boilerplate/кодген | данные реляционные (outfit↔items), нужны миграции |
| Riverpod вместо Bloc | меньше церемоний, отличный DI | своя кривая обучения | для одиночного проекта быстрее |
| Local-only | приватность, простота | нет sync между устройствами | осознанное ограничение v1 |
| Правила вместо ML | объяснимость, офлайн | менее «умно» | ядро ценнее магии; ML — v2+ |
| freezed-кодген | безопасные модели | время на build_runner | окупается на масштабе сущностей |
