# 12. Производственный план: текущее состояние и план качества

> Версия документа: **2026-06-22** · Ветка: `claude/garment-wear-forecast-card-5o5oe8`  
> Приложение для личного использования — публикация в Play Store не планируется.

---

## 0. TL;DR — где мы сейчас

```
СЕЙЧАС  ──► КАЧЕСТВО
 (V2.9)      (V2.12)
   ✅         Фаза 4
```

Фазы 1–3 **завершены** в ходе итеративной разработки V2.x.
Активный следующий шаг — Фаза 4 (качество кода и тесты).

---

## 1. Оценка текущего состояния (июнь 2026)

| Модуль | Статус | Примечания |
|--------|--------|------------|
| Scaffold, тема, навигация | ✅ Готово | Material 3, тёмная тема, `#C9A84C` |
| Drift БД v6 + миграции | ✅ Готово | 14 таблиц, 10 DAO, транзакции, сид |
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
| RPG + Gentleman Score | ✅ Готово | XP × 8 типов, Score из 5 компонентов, ачивки, миссии |
| Покупки | ✅ Готово | 48ч правило, 5 табов по статусу |
| Аниме-маскот | ✅ Готово | `MascotAvatar`, 4 настроения |
| ИИ-слой | ✅ Готово | `AiAdvisor`, `RouterAI`, защищённый ключ |
| Экспорт/очистка | ✅ Готово | JSON + share |
| **Тесты 60%+** | 🟡 Частично | Unit есть, widget — базовые |
| **CI зелёный** | 🟡 Требует проверки | `analyze` + `test` |

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

## 6. Фаза 4 — Качество (АКТИВНАЯ)

**Цель:** `flutter analyze` чистый, покрытие тестами ≥ 60%, CI зелёный.

### Эпик 4.1 — Analyze
- [ ] **4.1.1** Прогнать `flutter analyze --no-fatal-infos`, исправить все warnings
- [ ] **4.1.2** Проверить deprecated API (Dart 3.9+ изменения)
- [ ] **4.1.3** Убедиться в чистоте всех generated файлов (`.g.dart`, `.freezed.dart`)

### Эпик 4.2 — Тесты (unit)
- [x] **4.2.1** `computeWearForecast` — все 5 ветвей urgency + граничные случаи (`test/unit/wardrobe/wear_forecast_test.dart`)
- [x] **4.2.2** `generateDailyMissions` — все комбинации флагов (`test/unit/dashboard/mission_generator_test.dart`)
- [x] **4.2.3** `computeGentlemanScore` — 5-компонентная формула (`test/unit/rpg/level_calculator_test.dart`)
- [x] **4.2.4** `scoreOutfit` — fit/color/occasion/weather/comfort (`test/unit/recommendation/outfit_scorer_test.dart`)
- [x] **4.2.5** `markerStatus(type, value)` — здоровье: норма/внимание/риск (`test/unit/health/health_marker_test.dart`)

### Эпик 4.3 — Тесты (widget)
- [x] **4.3.1** `DashboardScreen` — smoke test (`test/widget/dashboard/dashboard_screen_test.dart`)
- [ ] **4.3.2** `PurchasesScreen` — переключение 5 табов
- [x] **4.3.3** `WardrobeScreen` — поиск фильтрует items (`test/widget/wardrobe/wardrobe_screen_test.dart`)
- [ ] **4.3.4** `OutfitDetailScreen` — score breakdown отображается

### Эпик 4.4 — Миграционные тесты
- [ ] **4.4.1** v1→v6 без потери данных (in-memory Drift)

### Эпик 4.5 — CI
- [x] **4.5.1** Исправлен конфликт `custom_lint`/`riverpod_lint` → `flutter pub get` проходит (см. [15-ci-and-build.md](15-ci-and-build.md) §7)
- [ ] **4.5.2** `flutter test --coverage` зелёный в CI runner (зависит от выделения раннера — §1–3 doc 15)

**DoD Фазы 4:** `flutter analyze` + `flutter test` — оба зелёные.

---

## 7. Сводная timeline

| Фаза | Статус | Ключевой результат |
|------|--------|--------------------|
| 1 — Стабилизация | ✅ | Зелёный CI, актуальные зависимости |
| 2 — Аниме-маскот | ✅ | `MascotAvatar` с 4 настроениями |
| 3 — Мужское здоровье | ✅ | 16 маркеров, ИИ-разбор |
| 3b — V2.x улучшения | ✅ | V2.4–V2.9: 30+ фич и фиксов |
| 4 — Качество | 🟡 Активно | Analyze + Tests ≥ 60% |

---

## 8. Принципы (неизменны)

1. **Offline-first.** Данные не покидают устройство без явного действия.
2. **Запускаемость на каждом шаге.** Ни один коммит не ломает `main`.
3. **Объяснимость.** Каждая рекомендация — с понятным «почему».
4. **Не медприбор.** Здоровье — трекинг и просвещение, не диагностика.

---

## 9. Definition of Done (глобально)

- [ ] Код проходит `flutter analyze --no-fatal-infos`
- [ ] Новый код покрыт тестами (unit или widget)
- [ ] `flutter test` зелёный
- [ ] Фича доступна с дашборда или навигации
- [ ] Данные фичи попадают в экспорт
- [ ] Коммит описателен, запушен в ветку разработки
