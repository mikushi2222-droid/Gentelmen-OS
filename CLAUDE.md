# CLAUDE.md — правила разработки Gentleman OS

Гайд для любого, кто пишет код в этом репозитории (человек или агент). Не общие
лозунги, а конкретные правила под этот проект. Если правило мешает — сначала
обнови этот файл, потом нарушай.

---

## 0. Что это за проект

**Gentleman OS** — офлайн-first, local-only, однопользовательское приложение
на Flutter (Android) — система принятия бытовых решений: что надеть, что купить,
что улучшить. Главная ценность — **быстрый ответ на вопрос «что делать сегодня»**,
а не «знание ради знания».

Стек: Flutter 3.44 / Dart 3.9+ · Riverpod 3 · go_router · **drift** (SQLite) ·
freezed · build_runner · fl_chart · flutter_secure_storage.

---

## 1. Принципы (в порядке приоритета)

1. **Приватность.** Данные только на устройстве. Ничего не уходит в сеть без
   явного действия пользователя. Ключи API — только в `flutter_secure_storage`,
   никогда в БД/логах/коде. В логах ключи маскируются.
2. **Скорость UI.** Основной интерфейс не ждёт сеть. Никакого синхронного I/O
   (файлы, БД) в `build()`. Списки ленивые. Облачный ИИ — опционально, поверх
   оффлайн-ядра, с деградацией на локальный движок при любой ошибке.
3. **Объяснимость.** Рекомендации строятся на понятных правилах (см.
   `outfit_builder/domain/`), а не на чёрном ящике. Любой score умеет объяснить
   себя списком `explanation`.
4. **Простота.** Нет соцсети, чата, маркетплейса, мультипользователя. Не добавляй
   фичи, которых не просили.

---

## 2. Архитектура

Feature-first. Каждая фича — `lib/features/<name>/` со слоями:

```
presentation/   виджеты, экраны (ConsumerWidget/ConsumerStatefulWidget)
application/    Riverpod-провайдеры, оркестрация
domain/         чистые функции и модели бизнес-логики (без Flutter, без БД)
data/           репозитории + мапперы drift-строк ↔ доменных моделей
```

Общее — в `lib/core/` (db, ai, theme, router, services, widgets, utils) и
`lib/shared/` (models, enums).

**Жёсткие правила слоёв:**
- `domain/` не импортирует Flutter и drift. Это позволяет покрывать его чистыми
  unit-тестами без виджет-окружения — так и делаем (`test/unit/...`).
- Бизнес-логику пиши **чистыми функциями** (`scoreOutfit`, `computeLevel`,
  `colorHarmonyScore`). Их легко тестировать и невозможно «сломать состоянием».
- `presentation/` не лезет в DAO напрямую — только через провайдеры/репозитории.

---

## 3. Riverpod

- DAO/сервисы отдаются через провайдеры из `core/db/database_provider.dart` и
  `core/services/services_provider.dart`. Не создавай DAO вручную в виджетах.
- `services_provider.dart` **реэкспортирует** `xp_service.dart` и
  `achievement_service.dart` — импортируй только `services_provider.dart`, не
  тащи их по отдельности (иначе unused_import).
- Композитные данные собирай в провайдере, а не в виджете. Виджет читает
  `AsyncValue` и рисует через `.when`/`AsyncValueWidget`.
- FutureProvider читай через `.future`, если важно дождаться значения; не
  полагайся на `.valueOrNull` там, где провайдер мог ещё не разрезолвиться
  (типичный баг — пустое поле при наличии данных).

---

## 4. drift (БД) — читай перед любой работой с таблицами

**ГЛАВНОЕ ПРАВИЛО:** каждой таблице обязателен `@DataClassName('<Имя>Data')`.

drift по умолчанию **сингуляризует** имя таблицы для класса строки
(`ClothingItems` → `ClothingItem`), что (а) ломает весь код, который ждёт
`ClothingItemsData`, и (б) конфликтует с доменной моделью `ClothingItem`.
Поэтому конвенция проекта — класс строки = `<ИмяТаблицы>Data`:

```dart
@DataClassName('ClothingItemsData')
class ClothingItems extends Table { ... }
```

Прочее:
- Companion называется `<Таблица>Companion` (генерится автоматически).
- `Value(...)` — из `package:drift/drift.dart`. Если используешь `Value` вне
  файла таблицы/DAO — добавь `import 'package:drift/drift.dart' show Value;`.
- Миграции: при изменении схемы **подними `schemaVersion`** в `app_database.dart`
  и допиши шаг в `onUpgrade`. Сид-данные — в `onCreate`/идемпотентных
  `insertOnConflictUpdate`.
- Запросы — в DAO. N+1 недопустим: не вызывай запрос в цикле по сущностям
  (пример как надо — `HabitsDao.completedHabitIdsOn` одним запросом вместо
  `isCompletedToday` на каждую привычку).

---

## 5. Кодоген (build_runner)

Файлы `*.g.dart` / `*.freezed.dart` **не коммитятся** (см. `.gitignore`) —
генерируются. Поэтому:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

обязательны **до** `flutter analyze` и тестов. Если правишь таблицу, freezed-
модель, riverpod-`@riverpod` или go_router_builder — перегенерируй.

---

## 6. UI / UX

- Material 3, тема — `core/theme/`. Режим темы переключаемый и сохраняемый
  (`themeModeProvider`); по умолчанию тёмная (дизайн dark-first). Не хардкодь
  `ThemeMode` в `MaterialApp`.
- Цвета: `Color.withValues(alpha: x)`, **не** `withOpacity` (deprecated).
- Картинки из файлов рисуй через `Image.file(..., errorBuilder: ...)`. **Никогда**
  `File(path).existsSync()` в `build`/`itemBuilder` — это синхронный I/O и джанк.
- Фото из `image_picker` — **временные**. Сразу копируй в documents-каталог
  (`core/utils/image_storage.dart → persistWardrobeImage`) и храни постоянный
  путь; при удалении сущности чисти файл (`deleteWardrobeImage`).
- `TextEditingController` всегда диспозь: в `State.dispose()` либо для диалогов —
  `showDialog(...).whenComplete(ctrl.dispose)`.
- Пустые состояния (`EmptyState`), загрузка и ошибки обрабатываются явно во всех
  `AsyncValue`.
- Тексты — на русском, тон спокойный и уважительный (см. сид-контент).

---

## 7. Дата/время

- Для «календарных» вычислений (стрики, «сегодня») используй
  `DateTime(y, m, d - 1)` и сравнение нормализованных к полуночи дат. **Не**
  `subtract(Duration(days: 1))` — оно ломается на переходах летнего времени.
- «Сегодня» = диапазон `[startOfDay, startOfDay + 1 day)`, а не сравнение полей.

---

## 8. Геймификация / достижения

- Коды достижений — **единый источник правды** `core/services/achievement_catalog.dart`
  (`Achv`). И сид БД, и логика разблокировки используют одни и те же константы.
  Строковые литералы кодов запрещены — опечатка должна быть ошибкой компиляции.
- Каждое засеянное достижение обязано иметь реальный триггер в
  `AchievementService`. Не сей недостижимых ачивок.
- XP начисляется в `XpService`; после начисления проверяй уровневые ачивки.

---

## 9. Облачный ИИ (RouterAI)

- Всегда есть оффлайн-фолбэк (`LocalAiAdvisor`). Любая ошибка сети/парсинга →
  деградация на локальный движок, приложение не падает.
- Запросы/ответы логируй через `core/utils/app_logger.dart` (`log`), ключ —
  маскируй. Не логируй полные секреты.
- Ключ и модель — в secure storage (`RouterAiConfig`/`RouterAiSettings`).

---

## 10. Качество кода и анализатор

- **`flutter analyze` падает на warnings**, даже с `--no-fatal-infos`. Целевое
  состояние — **ноль errors и ноль warnings**. infos (const, ColoredBox,
  unnecessary_underscores) желательны, но не блокируют.
- Не оставляй неиспользуемые переменные/импорты (`cs`, мёртвые `final`, лишние
  `import`).
- Только `package:`-импорты (`always_use_package_imports`), trailing-commas,
  `const` где можно.
- Record-паттерн **нельзя** использовать в списке параметров функции. Вместо
  `data: ((a, b)) { ... }` пиши `data: (rec) { final (a, b) = rec; ... }`.

---

## 11. Зависимости

- Это **приложение** → `pubspec.lock` коммитим (воспроизводимые сборки).
- Перед добавлением dev-зависимостей проверь совместимость constraints
  (исторический инцидент: `custom_lint` и `riverpod_lint` тянули несовместимый
  `analyzer_plugin` и ломали `flutter pub get` → весь CI). Если `pub get` не
  резолвится — чини это первым, всё остальное вторично.

---

## 12. Перед коммитом (Definition of Done)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze            # 0 errors, 0 warnings
flutter test               # все зелёные
```

Если локального SDK нет — учитывай, что CI выполнит это за тебя; пиши код так,
чтобы пройти с первого раза (особенно §4 drift и §10 анализатор), а не итерируй
вслепую через CI.

---

## 13. Git / процесс

- Разработка — на выделенной ветке, не в дефолтной.
- Коммиты атомарные, по одной теме; сообщение объясняет **почему**, не только
  «что». Заголовок в стиле `тип(scope): суть` (`fix(rpg): …`, `perf: …`).
- PR создаём только по явной просьбе.
- Никогда не пушь секреты. `*.env`, `secrets.dart`, keystore — в `.gitignore`.

---

## 14. Карта кодовой базы (быстрый старт)

| Где | Что |
|-----|-----|
| `lib/main.dart`, `lib/app.dart` | Точка входа, ProviderScope, MaterialApp |
| `lib/core/db/` | drift: `app_database.dart`, `tables/`, `daos/` |
| `lib/core/ai/` | RouterAI клиент/конфиг + локальный/облачный советники |
| `lib/core/services/` | XP, достижения (+ `achievement_catalog.dart`) |
| `lib/core/router/` | go_router + `ShellScaffold` (нижняя навигация) |
| `lib/features/outfit_builder/domain/` | движок рекомендаций (чистые функции) |
| `lib/features/dashboard/` | Gentleman Score, дневные миссии |
| `lib/shared/` | доменные модели (freezed) и enums |
| `test/unit/` | чистые unit-тесты доменной логики |
| `docs/` | PRD, архитектура, дата-модель, roadmap |

Полезное в `docs/`: `02-architecture.md`, `03-data-model.md`,
`05-recommendation-engine.md`, `14-ai-integration.md`, `15-ci-and-build.md`.

---

## 15. Промпт для разработки с ИИ-агентом

Готовый шаблон. Подставь задачу в `<ЗАДАЧА>` и отдай агенту. Он кодирует
стандарты проекта так, чтобы агент прошёл CI с первого раза, а не итерировал
вслепую.

```text
Ты — senior Flutter/Dart инженер, работающий над Gentleman OS (offline-first,
Riverpod 3 + drift + freezed, feature-first). Прежде чем писать код, прочитай
CLAUDE.md целиком и следуй ему как обязательным правилам.

ЗАДАЧА:
<ЗАДАЧА>

ПОРЯДОК РАБОТЫ:
1. Сначала исследуй: найди затронутые файлы, существующие паттерны и
   ближайшие аналоги. Повторяй стиль соседнего кода (именование, импорты,
   плотность комментариев). Не изобретай новых абстракций без необходимости.
2. Спланируй минимальное изменение. Если требование неоднозначно, ЗАТРАГИВАЕТ
   архитектуру/данные/приватность или ломает обратную совместимость БД —
   остановись и задай уточняющий вопрос ДО написания кода. Иначе действуй.
3. Реализуй по слоям: бизнес-логику — чистой функцией в domain/ (без Flutter и
   drift), оркестрацию — в application/ (Riverpod), UI — в presentation/.
   Доступ к данным — через репозитории/DAO-провайдеры, не напрямую.
4. На каждое изменение поведения добавь/обнови unit-тест в test/unit/.

ОБЯЗАТЕЛЬНЫЕ ИНВАРИАНТЫ (нарушение = переделка):
- drift: новой таблице — @DataClassName('<Таблица>Data'); при смене схемы —
  поднять schemaVersion и дописать onUpgrade.
- После правок таблиц/freezed/@riverpod/go_router_builder — перегенерировать:
  dart run build_runner build --delete-conflicting-outputs.
- Никакого синхронного I/O в build(): Image.file(errorBuilder:), не existsSync().
- Color.withValues(alpha:), не withOpacity. TextEditingController — диспозить.
- Календарные даты через DateTime(y,m,d-1), не subtract(Duration(days:1)).
- Коды достижений — только из Achv (achievement_catalog.dart).
- Секреты/ключи — только secure storage; в логах маскировать; ничего в сеть
  без явного действия пользователя.
- Облачный ИИ — всегда с оффлайн-фолбэком.

ЗАВЕРШЕНИЕ (Definition of Done):
- flutter pub get && dart run build_runner build --delete-conflicting-outputs
- flutter analyze → 0 errors, 0 warnings (warnings валят CI)
- flutter test → всё зелёное
Если локального SDK нет — рассуждай так, будто эти команды должны пройти с
первого раза; не полагайся на CI как на отладчик.

ФОРМАТ ОТВЕТА:
- Кратко: что и зачем изменил (по файлам), какие тесты добавил, как проверил.
- Без воды и без пересказа неизменённого кода. Diff — это и есть отчёт.
- Честно сообщай о пропущенных шагах, упавших тестах и оставшихся рисках.

КОММИТ: атомарный, заголовок `тип(scope): суть`, тело объясняет «почему».
PR — только по явной просьбе.
```

Короткая версия для мелких правок:

```text
Senior Flutter-инженер на Gentleman OS. Следуй CLAUDE.md. Задача: <ЗАДАЧА>.
Повтори стиль соседнего кода, минимальный дифф, тест на изменение поведения.
drift→@DataClassName + перегенерация; без existsSync в build; withValues;
диспозь контроллеры. Done = analyze 0/0 + тесты зелёные. Неоднозначность или
влияние на схему/приватность — спроси до кода. Отчёт — кратко, по делу.
```
