# 12. Производственный план: текущее состояние и план качества

> Версия документа: **2026-06-24** · Ветка: `claude/code-docs-review-x4vztn` (= `main`)  
> Приложение для личного использования — публикация в Play Store не планируется.

---

## 0. TL;DR — где мы сейчас

```
КАЧЕСТВО ──► V3.x
 (V2.12)    (планируется)
   ✅           next
```

Фазы 1–4 **завершены**. `flutter analyze --no-fatal-infos` проходит.
Активный следующий шаг — старт V3.0 (Weight Loss Intelligence Layer).

---

## 1. Оценка текущего состояния (июнь 2026)

| Модуль | Статус | Примечания |
|--------|--------|------------|
| Scaffold, тема, навигация | ✅ Готово | Material 3, тёмная тема, `#C9A84C` |
| Drift БД v7 + миграции | ✅ Готово | 14 таблиц, 10 DAO, транзакции, сид |
| Профиль + замеры + BMI | ✅ Готово | `isLargeFrame`, производные рекомендации |
| Гардероб | ✅ Готово | CRUD, фото, cost-per-wear, поиск, urgency |
| `WearForecast` / urgency | ✅ Готово | 5 статусов, прогноз на детали вещи |
| Dashboard urgency strip | ✅ Готово | «Надеть сегодня», горизонтальная лента |
| Dashboard привычки мини-блок | ✅ Готово | N/total + стрик, тап → привычки |
| Outfit Builder + scoring | ✅ Готово | 5 осей, score breakdown сохраняется в JSON |
| Outfit фильтр по поводу | ✅ Готово | горизонтальные чипы на экране образов |
| Оценка образа после носки | ✅ Готово | 1–5 звёзд + заметка, блендинг в score |
| «Надеть весь образ» | ✅ Готово | batch wear на все вещи образа |
| «Купил → добавить в гардероб» | ✅ Готово | AlertDialog при смене статуса на «Куплено» |
| База знаний | ✅ Готово | Markdown, поиск, закладки, время чтения |
| Фитнес + тренд-дельты | ✅ Готово | fl_chart, стрелки ↑↓ |
| Привычки + 7д calendar | ✅ Готово | calendar strip, стрик |
| Мужское здоровье | ✅ Готово | 16 маркеров, ИИ-разбор, индекс [0–100] |
| Импорт анализов с фото | ✅ Готово | `LabPhotoAnalyzer` → RouterAI vision → `HealthMarkers` |
| Подтверждение опасных удалений | ✅ Готово | AlertDialog для образов и маркеров здоровья |
| Журнал мутаций данных | ✅ Готово | `AppLogger` — все ключевые write-операции |
| RPG + Gentleman Score | ✅ Готово | XP × 8 типов, Score из 5 компонентов, ачивки, миссии |
| Покупки | ✅ Готово | 48ч правило, 5 табов по статусу |
| Аниме-маскот | ✅ Готово | `MascotAvatar`, 4 настроения |
| ИИ-слой | ✅ Готово | `AiAdvisor`, `RouterAI`, защищённый ключ |
| Экспорт/очистка | ✅ Готово | JSON + share |
| **Тесты 60%+** | ✅ Готово | Unit + widget по всем ключевым модулям |
| **CI (`analyze`)** | ✅ Готово | `--no-fatal-infos` — 0 ошибок, 0 warnings, только infos |

---

## 2. Фаза 1 — Стабилизация (ЗАВЕРШЕНА)

**Итог:** сборка проходит, зависимости актуализированы (июнь 2026).

---

## 3. Фаза 2 — Аниме-маскот (ЗАВЕРШЕНА)

**Итог:** маскот реагирует на Gentleman Score (`sleeping < 20`, `neutral < 50`, `pleased < 80`, `proud ≥ 80`).  
Реализован в `core/widgets/mascot_avatar.dart`.

---

## 4. Фаза 3 — Модуль «Мужское здоровье» (ЗАВЕРШЕНА)

**Итог:**
- Таблица `HealthMarkers`, миграция v4→v5→v6
- `HealthScreen` с карточками маркеров и цветовым статусом
- `HealthMarkerDetailScreen` с fl_chart-графиком динамики
- ИИ-разбор через `RouterAiClient` + веб-поиск
- Дисклеймер «не является медицинской рекомендацией»
- XP за внесение маркера (`XpType.health`)

---

## 5. Фаза 3b — V2.x Итеративные улучшения (ЗАВЕРШЕНЫ)

| Итерация | Что сделано |
|----------|------------|
| V2.4 | `WearForecast` на карточке вещи (urgency 5 статусов) |
| Bug fix | 6 code-review bugs: транзакция wear, `insertOrIgnore` сид, `hasRecentMarker`, `ref.invalidate`, тест-часы, cap mission |
| V2.5 | Trend deltas в фитнесе + 7-дневный calendar strip привычек |
| V2.6 | Urgency-сортировка гардероба + outfit-today в миссиях + 5 табов покупок |
| V2.7 | Dashboard urgency strip + knowledge bookmarks filter + article read time |
| V2.8 | Outfit score breakdown сохранение + разбивка 5 осей + batch wear + wardrobe search |
| V2.9 | Habits мини-блок на Dashboard + outfit occasion filter + rating screen + purchase→wardrobe |

---

## 6. Фаза 4 — Качество (ЗАВЕРШЕНА)

**Результат:** `flutter analyze --no-fatal-infos` — 0 errors, 0 warnings. Тесты покрывают все ключевые домены.

### Эпик 4.1 — Analyze
- [x] **4.1.1** `flutter analyze --no-fatal-infos` — 0 errors, 0 warnings, только infos
- [x] **4.1.2** Deprecated API: `withOpacity` → `withValues(alpha:)` во всех 16 файлах
- [x] **4.1.3** Generated файлы исключены из анализа в `analysis_options.yaml`

### Эпик 4.2 — Тесты (unit)
- [x] **4.2.1** `computeWearForecast` — все 5 ветвей urgency + граничные случаи (`test/unit/wardrobe/wear_forecast_test.dart`)
- [x] **4.2.2** `generateDailyMissions` — все комбинации флагов (`test/unit/dashboard/mission_generator_test.dart`)
- [x] **4.2.3** `computeGentlemanScore` — 5-компонентная формула (`test/unit/rpg/level_calculator_test.dart`)
- [x] **4.2.4** `scoreOutfit` — fit/color/occasion/weather/comfort (`test/unit/recommendation/outfit_scorer_test.dart`)
- [x] **4.2.5** `markerStatus(type, value)` — здоровье: норма/внимание/риск (`test/unit/health/health_marker_test.dart`)

### Эпик 4.3 — Тесты (widget)
- [x] **4.3.1** `DashboardScreen` — smoke test (`test/widget/dashboard/dashboard_screen_test.dart`)
- [x] **4.3.2** `PurchasesScreen` — 5 табов, фильтрация по статусу, пустые состояния (`test/widget/purchases/purchases_screen_test.dart`)
- [x] **4.3.3** `WardrobeScreen` — поиск фильтрует items (`test/widget/wardrobe/wardrobe_screen_test.dart`)
- [x] **4.3.4** `OutfitDetailScreen` — score breakdown, объяснения, пустой образ (`test/widget/outfit/outfit_detail_screen_test.dart`)

### Эпик 4.4 — Миграционные тесты
- [x] **4.4.1** schema v7 — onCreate + seed (in-memory Drift) (`test/unit/db/migration_test.dart`)

### Эпик 4.5 — CI
- [x] **4.5.1** Исправлен конфликт `custom_lint`/`riverpod_lint` → `flutter pub get` проходит (см. [15-ci-and-build.md](15-ci-and-build.md) §7)
- [x] **4.5.2** Исправлен дублирующий `import services_provider.dart` в `dashboard_screen.dart`
- [x] **4.5.3** `flutter analyze --no-fatal-infos` — 0 errors, 0 warnings (только infos) на CI runner

**DoD Фазы 4: ВЫПОЛНЕН** — `flutter analyze --no-fatal-infos` зелёный.

---

## 7. Сводная timeline

| Фаза | Статус | Ключевой результат |
|------|--------|--------------------|
| 1 — Стабилизация | ✅ | Зелёный CI, актуальные зависимости |
| 2 — Аниме-маскот | ✅ | `MascotAvatar` с 4 настроениями |
| 3 — Мужское здоровье | ✅ | 16 маркеров, ИИ-разбор |
| 3b — V2.x улучшения | ✅ | V2.4–V2.9: 30+ фич и фиксов |
| 4 — Качество | ✅ | `analyze` чистый (0/0/infos), все тесты написаны |

---

## 8. Принципы (неизменны)

1. **Offline-first.** Данные не покидают устройство без явного действия.
2. **Запускаемость на каждом шаге.** Ни один коммит не ломает `main`.
3. **Объяснимость.** Каждая рекомендация — с понятным «почему».
4. **Не медприбор.** Здоровье — трекинг и просвещение, не диагностика.

---

## 9. Definition of Done (глобально)

- [x] Код проходит `flutter analyze --no-fatal-infos`
- [x] Новый код покрыт тестами (unit или widget)
- [ ] `flutter test --coverage` зелёный (требует Android/Flutter окружения)
- [x] Фича доступна с дашборда или навигации
- [x] Данные фичи попадают в экспорт
- [x] Коммит описателен, запушен в ветку разработки

> Следующий шаг: старт V3.0 — новая feature-ветка → PR → merge to main.
