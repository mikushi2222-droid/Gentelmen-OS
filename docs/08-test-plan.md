# 08. План тестирования

Flutter официально рекомендует: unit-тесты для логики, widget-тесты для UI,
golden-тесты для визуала. План построен на этом.

## 0. Текущее состояние (июнь 2026)

Что **реально есть** в репозитории:

```
test/unit/
├── ai/local_ai_advisor_test.dart
├── dashboard/mission_generator_test.dart
├── health/health_marker_test.dart
├── mascot/mascot_avatar_test.dart
├── outfit/{color_harmony,occasion_rules,outfit_generator,weather_rules}_test.dart
├── profile/user_profile_test.dart
├── recommendation/{fit_rules,outfit_scorer}_test.dart
├── rpg/level_calculator_test.dart           // computeLevel + computeGentlemanScore
└── wardrobe/{clothing_item,wear_forecast}_test.dart
test/widget/
├── core/score_ring_test.dart
├── dashboard/dashboard_screen_test.dart      // smoke + provider overrides
└── wardrobe/{clothing_card,wardrobe_screen}_test.dart
```

Ещё **не реализовано** (бэклог качества, см. [12-production-plan.md](12-production-plan.md)):
golden-тесты, миграционные тесты (`v1→v7`), `integration_test/`, тесты
репозиториев на in-memory Drift, виджет-тесты `PurchasesScreen` / `OutfitDetailScreen`.

> Все тесты требуют прогнанного `build_runner` (генерация `.g.dart`/`.freezed.dart`)
> — эти файлы в `.gitignore` и в CI/локально генерируются перед `flutter test`.

Разделы ниже — целевой план (к чему стремимся), а не текущее покрытие.

## 1. Пирамида тестов

```
        ╱╲        golden tests (немного: Dashboard, Wardrobe, Outfit Builder)
       ╱──╲       widget tests (ключевые экраны и формы)
      ╱────╲      unit tests (домен, правила, репозитории) — основная масса
```

## 2. Unit-тесты (приоритет №1)

### Движок рекомендаций
- `fitScore` — каждое правило посадки (slim штраф, regular бонус, rise, ткани).
- `colorHarmony` — нейтраль+нейтраль, нейтраль+акцент, конфликтные пары.
- `occasionScore` — матрица повод↔дресс-код.
- `weatherScore` — температурные пороги, сезон.
- `comfortScore` — рейтинги, restrictions.
- `outfitScorer` — взвешенная сумма, total ∈ [0,100], непустое explanation.
- `outfitGenerator` — валидные слоты, нет недоступных вещей, разнообразие топа.

### RPG
- `computeLevel` — таблица totalXp → level/progress.
- `achievementRules` — каждое условие отдельно, идемпотентность разблокировки.
- стрики — последовательности дат с разрывами.
- `gentlemanScore` — детерминизм при фиксированном состоянии.

### Репозитории (на in-memory Drift)
- CRUD каждой сущности.
- cost-per-wear пересчёт при добавлении WearLog.
- каскады при удалении вещи (чистка outfit_items).
- история замеров создаётся при изменении профиля.

## 3. Widget-тесты

- Dashboard: рендер score, 3 миссий, быстрых кнопок; пустое состояние.
- Wardrobe: сетка, фильтр по категории, пустое состояние, переход в деталь.
- Add/Edit Item: валидация формы, сохранение вызывает репозиторий (mock/override).
- Outfit Builder: ввод параметров → отображение результатов со score breakdown.
- Profile: редактирование сохраняет, история отображается.
- Measurements: график рендерится при наличии данных.
- Состояния `loading/empty/error/data` для async-экранов.

Подход: override Riverpod-провайдеров на фейковые репозитории.

## 4. Golden-тесты (по возможности)

- Dashboard (light/dark).
- Wardrobe grid.
- Outfit Builder результат с разбивкой score.

Зафиксировать тему, шрифты и фиксированные данные для стабильности.

## 5. Тесты экспорта/импорта

- round-trip: export → import → состояние идентично исходному.
- импорт с другой `schemaVersion` → корректная миграция или отказ с понятной ошибкой.
- импорт повреждённого JSON → graceful error, данные не разрушены.
- merge vs replace стратегии.

## 6. Тесты миграций БД

- Для каждой версии схемы: `from N → N+1` сохраняет данные.
- Использовать `drift` schema verification / generated schema снапшоты.
- Тест `onCreate` сеет стартовый контент.

## 7. Интеграционные сценарии (smoke)

End-to-end на эмуляторе (`integration_test`):
1. Запуск → Dashboard рендерится из сид-данных.
2. Добавить вещь → появляется в гардеробе.
3. Собрать образ → получить ≥1 подборку → сохранить.
4. Записать замер → точка появляется на графике.
5. Экспорт → импорт → данные на месте.

## 8. Инструменты и команды

```bash
flutter test                      # unit + widget + golden
flutter test --update-goldens     # обновить golden-эталоны
flutter test integration_test/    # интеграционные (на устройстве/эмуляторе)
dart run build_runner build --delete-conflicting-outputs   # перед тестами
```

## 9. Покрытие и цели

- Домен (правила, scoring, RPG): цель ~90%+ (это ядро ценности).
- Репозитории: ~80%.
- UI: ключевые экраны покрыты widget-тестами; golden — по 3 главным.
- CI прогоняет `flutter analyze` + `flutter test` на каждый коммит ветки.

## 10. Не тестируем (осознанно)

- Тривиальные геттеры/`copyWith` (генерируются freezed).
- Сторонние пакеты.
- Визуальные мелочи без бизнес-логики.
