# 13. Спецификация пакетов (актуально на июнь 2026)

> Источник правды по зависимостям для ИИ-агентов и разработчиков.
> Все версии актуализированы на **июнь 2026** (Flutter **3.44**, Dart **3.9+**).
> При обновлении сверяйтесь с pub.dev — ссылки приведены для каждого пакета.

## Среда

| Параметр | Значение |
|----------|----------|
| Flutter | `>=3.44.0` (stable, май 2026) |
| Dart SDK | `>=3.9.0 <4.0.0` |
| Платформа | Android (minSdk 21), офлайн-first |
| Кодоген | `build_runner` (drift, freezed, json_serializable) |

## Runtime-зависимости

| Пакет | Версия | Назначение | pub.dev | Документация |
|-------|--------|------------|---------|--------------|
| flutter_riverpod | `^3.3.2` | State management / DI | [pub](https://pub.dev/packages/flutter_riverpod) | [riverpod.dev](https://riverpod.dev) |
| riverpod_annotation | `^4.0.3` | Аннотации для кодогена провайдеров | [pub](https://pub.dev/packages/riverpod_annotation) | [riverpod.dev](https://riverpod.dev) |
| go_router | `^17.3.0` | Декларативная навигация, deep links | [pub](https://pub.dev/packages/go_router) | [docs](https://pub.dev/documentation/go_router/latest/) |
| drift | `^2.34.0` | Реактивная типобезопасная SQLite ORM | [pub](https://pub.dev/packages/drift) | [drift.simonbinder.eu](https://drift.simonbinder.eu) |
| drift_flutter | `^0.3.0` | Платформенная инициализация drift (+нативные либы) | [pub](https://pub.dev/packages/drift_flutter) | [drift.simonbinder.eu](https://drift.simonbinder.eu) |
| sqlite3_flutter_libs | `^0.6.0` | Нативные бинарники SQLite (через drift_flutter) | [pub](https://pub.dev/packages/sqlite3_flutter_libs) | — |
| freezed_annotation | `^3.1.0` | Аннотации иммутабельных моделей | [pub](https://pub.dev/packages/freezed_annotation) | [docs](https://pub.dev/documentation/freezed/latest/) |
| json_annotation | `^4.12.0` | Аннотации JSON-сериализации | [pub](https://pub.dev/packages/json_annotation) | — |
| fl_chart | `^1.2.0` | Графики (линейные/столбчатые) | [pub](https://pub.dev/packages/fl_chart) | [docs](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md) |
| image_picker | `^1.2.2` | Выбор фото из камеры/галереи | [pub](https://pub.dev/packages/image_picker) | — |
| path_provider | `^2.1.6` | Системные пути (documents dir) | [pub](https://pub.dev/packages/path_provider) | — |
| path | `^1.9.0` | Работа с путями | [pub](https://pub.dev/packages/path) | — |
| flutter_markdown_plus | `^1.0.7` | Рендер Markdown (замена discontinued flutter_markdown) | [pub](https://pub.dev/packages/flutter_markdown_plus) | — |
| uuid | `^4.5.3` | Генерация UUID v4 | [pub](https://pub.dev/packages/uuid) | — |
| flutter_secure_storage | `^10.3.1` | Защищённое хранение (ключ RouterAI) | [pub](https://pub.dev/packages/flutter_secure_storage) | — |
| share_plus | `^13.1.0` | Системный «Поделиться» (экспорт) | [pub](https://pub.dev/packages/share_plus) | — |
| permission_handler | `^12.0.3` | Запрос разрешений | [pub](https://pub.dev/packages/permission_handler) | — |
| intl | `^0.20.2` | Локали, форматирование дат/чисел | [pub](https://pub.dev/packages/intl) | — |
| http | `^1.6.0` | HTTP-клиент (RouterAI) | [pub](https://pub.dev/packages/http) | — |

## Dev-зависимости

| Пакет | Версия | Назначение | pub.dev |
|-------|--------|------------|---------|
| flutter_lints | `^6.0.0` | Набор рекомендованных линтов | [pub](https://pub.dev/packages/flutter_lints) |
| build_runner | `^2.15.0` | Запуск кодогенерации | [pub](https://pub.dev/packages/build_runner) |
| riverpod_generator | `^4.0.4` | Кодоген провайдеров Riverpod | [pub](https://pub.dev/packages/riverpod_generator) |
| drift_dev | `^2.34.0` | Кодоген drift (`.g.dart`) | [pub](https://pub.dev/packages/drift_dev) |
| freezed | `^3.2.5` | Кодоген моделей (`.freezed.dart`) | [pub](https://pub.dev/packages/freezed) |
| json_serializable | `^6.14.0` | Кодоген `fromJson/toJson` | [pub](https://pub.dev/packages/json_serializable) |
| go_router_builder | `^4.3.0` | Типобезопасные маршруты | [pub](https://pub.dev/packages/go_router_builder) |

> **Удалено (июнь 2026):** `custom_lint ^0.8.1` и `riverpod_lint ^3.1.4` исключены
> из-за конфликта транзитивных зависимостей: `riverpod_lint >=3.1.4` требует
> `analyzer_plugin ^0.14.0`, а `custom_lint ^0.8.1` — `analyzer_plugin ^0.13.0`
> (несовместимые диапазоны). Версия-решение не найдена, поэтому пакеты удалены.
> Riverpod-специфичные линты (например, `avoid_public_notifier_auto_dispose`)
> больше не проверяются автоматически; стандартный набор `flutter_lints` сохранён.

## Команды кодогенерации

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # .g.dart / .freezed.dart
flutter analyze --no-fatal-infos
flutter test --coverage
```

> `.g.dart` и `.freezed.dart` **не коммитятся** — генерируются в CI и локально.

## Заметки по миграции (важно для ИИ-агентов)

### Riverpod 2 → 3
- Классический API (`Provider`, `FutureProvider`, `StreamProvider`, `Provider.family`,
  `ConsumerWidget`, `ref.watch/read`, `AsyncValue.when`, `.valueOrNull`) сохранён —
  существующий код совместим.
- `Ref` унифицирован (нет `FutureProviderRef<T>` и т.п.) — не типизируйте `ref` вручную.

### Freezed 2 → 3
- **Все** `@freezed`-классы должны быть `abstract class` или `sealed class`
  (для union-типов). Простые data-классы → `abstract class X with _$X`.
- Удалены `map/when` у freezed-union (используйте Dart pattern matching).
  Не путать с `AsyncValue.when` из Riverpod — он остаётся.

### go_router 13 → 17
- `state.pathParameters['x']` — текущий API (не `params`).
- Query-параметры: `state.uri.queryParameters`.

### fl_chart 0.68 → 1.x
- Удалён `tooltipBgColor` → `getTooltipColor` (в проекте не использовался).
- `SideTitles.getTitlesWidget: (double value, TitleMeta meta)` — без изменений.

### flutter_markdown → flutter_markdown_plus
- Пакет `flutter_markdown` объявлен discontinued. Замена — `flutter_markdown_plus`.
- API совместим: `Markdown`, `MarkdownBody`, `MarkdownStyleSheet`.

### share_plus 9 → 13
- API: `SharePlus.instance.share(ShareParams(files: [XFile(path)], text: '...'))`.

## RouterAI (внешний ИИ-сервис)

| Параметр | Значение |
|----------|----------|
| Base URL | `https://routerai.ru/api/v1` (OpenAI-совместимый) |
| Эндпоинт | `POST /chat/completions` |
| Аутентификация | `Authorization: Bearer <API_KEY>` |
| Хранение ключа | `flutter_secure_storage` (только на устройстве) |
| Веб-поиск | `plugins: [{"id":"web"}]` или суффикс модели `:online` |
| Мультимодальность | `image_url` (base64/URL) для анализа фото вещей |
| Документация | https://routerai.ru/docs · модели: https://routerai.ru/models |

Подробнее — см. [14-ai-integration.md](14-ai-integration.md).
