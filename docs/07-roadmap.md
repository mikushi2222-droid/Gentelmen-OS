# 07. Дорожная карта — актуальное состояние и план V2.x / V3.x

> Последнее обновление: **2026-06-23**  
> Ветка разработки: `claude/claude-md-project-memory-2ouxu6`  
> Схема БД: **v7** (v8 запланирована под V3.0)

---

## Продуктовая ниша (обновлено)

> **Masculine health OS для мужчин с высоким ИМТ, особенно на GLP-1 / тирзепатиде.**

Приложение — не «fat loss tracker». Это:
- **Behavior system** — не обсессивный счётчик калорий.
- **Accountability system** — «система помогает держать курс», не «система оценивает».
- **Intelligent health OS** — operator-style insights, trajectory integrity, system continuity.

Полная спецификация V3.x: [docs/16-weight-health-ai-spec.md](16-weight-health-ai-spec.md)

---

## 1. Что уже реализовано (M1–M10 + V2.x)

### Базовые милестоуны (M1–M10) — ✅ Завершены

| Milestone | Описание | Статус |
|-----------|----------|--------|
| M1 | Scaffold, тема Material 3, навигация (5 табов) | ✅ |
| M2 | Drift БД v1, DAO, сид, миграции | ✅ |
| M3 | Профиль + замеры + BMI + рекомендации по фигуре | ✅ |
| M4 | Гардероб CRUD + фото + cost-per-wear | ✅ |
| M5 | Outfit Builder (scoring: посадка/цвет/повод/погода) + генерация | ✅ |
| M6 | База знаний (Markdown, поиск, закладки, «прочитано») | ✅ |
| M7 | Фитнес (замеры, fl_chart) | ✅ |
| M8 | RPG (XP, уровни, навыки, ачивки, Gentleman Score, миссии) | ✅ |
| M9 | Покупки (48ч правило, приоритеты, статусы) | ✅ |
| M10 | Экспорт/очистка, настройки, журнал отладки | ✅ |

### V2.x — Итеративные улучшения (все завершены)

| Версия | Фича | Коммит |
|--------|------|--------|
| V2.1 | Аниме-маскот (`MascotAvatar`, `moodFromScore`) | `74946ff` |
| V2.2 | Модуль «Мужское здоровье» (16 маркеров, индекс, ИИ-разбор) | `74946ff` |
| V2.3 | ИИ-советник по гардеробу (`styleAdviceProvider`), ИИ-анализ фото вещи | `fb53492` |
| V2.4 | `WearForecast` / `WearUrgency` — прогноз носки на карточке вещи | `74946ff` |
| — | **Исправления 6 bugs** (code-review: транзакция, `insertOrIgnore`, `hasRecentMarker`, `invalidate`, test clock, mission cap) | `a8bdcdf` |
| V2.5 | Тренд-дельты в фитнесе (↑↓ стрелки) + 7-дневный calendar strip в привычках | `578cf77` |
| V2.6 | Urgency-сортировка гардероба + outfit-today fix в миссиях + 5 табов в покупках | `593641e` |
| V2.7 | Dashboard urgency strip «Надеть сегодня» + knowledge bookmarks/favorites filter + время чтения статьи | `39e31a0` |
| V2.8 | Сохранение score breakdown в outfit + разбивка по осям в детали + «Надеть весь образ» + поиск в гардеробе | `f3270cb` |
| V2.9 | Habits мини-блок на Dashboard + outfit occasion filter + rating screen + purchase→wardrobe | — |
| V2.11–12 | Расширение unit-тестов + widget-тесты (Dashboard, Wardrobe) + фикс CI (`custom_lint`/`riverpod_lint`) | — |

> Прогресс по тестам и оставшимся эпикам качества отслеживается в
> [12-production-plan.md](12-production-plan.md) §6 (Фаза 4).

---

## 2. Следующие шаги — V2.10–V2.12

### V2.9 — Quick wins: привычки, покупки→гардероб, outfit rating ✅ Завершено

**Приоритет: Высокий.** Замыкают незакрытые UX-петли. (Детали ниже — для истории.)

#### A. Стрик-счётчик привычек на Dashboard
- Добавить мини-блок «Привычки сегодня» между urgency strip и разделом миссий
- Показывает N/total выполненных сегодня + текущий стрик (дней подряд)
- Тап → `/progress/habits`

#### B. «Купил → добавить в гардероб»
- При переводе покупки в статус `bought` в `_showOptions` → `AlertDialog`
  с предложением «Добавить в гардероб?»
- Если «Да» → `context.push('/wardrobe/add')` с предзаполненными полями
  (название, категория из `PurchaseWish`)

#### C. Оценка образа после носки (`/outfits/:id/rate`)
- Простой экран (уже есть в роутинге, но не реализован): ползунок 1–5 + поле заметки
- Сохранять `OutfitRating` в `outfit.notes` или отдельной таблице
- Обновлять `outfit.score` с учётом пользовательской оценки

#### D. Фильтр образов по поводу
- В `OutfitsScreen` добавить горизонтальные чипы `Occasion.values` (как категории в гардеробе)

---

### V2.10 — Глубина: мультифильтр гардероба, дашборд привычек, style advisor

**Приоритет: Средний.**

#### A. Расширенный фильтр гардероба
- PRD требует фильтр по сезону, цвету, бренду — сейчас только категория
- Добавить `BottomSheet`-фильтр с чипами сезона + текстовыми полями цвета/бренда
- `wardrobeByFiltersProvider` = `wardrobeListProvider` + клиентская фильтрация

#### B. Быстрое выполнение привычки с Dashboard
- В секции привычек Dashboard добавить чекбоксы для каждой активной привычки
- Тап → `habitsDao.complete(habitId, today)` без перехода в раздел

#### C. Style Advisor — улучшение промпта
- Передавать в ИИ-советник больше контекста: топ-5 вещей по urgency, сезон
- Добавить раздел «Образ дня» с рекомендацией конкретного сочетания

#### D. Health: напоминание о сдаче анализов
- `HealthMarkerType` имеет рекомендованный интервал (3/6/12 мес)
- Плитка «Давно не проверяли» на health screen если last date > interval

---

### V2.11 — Качество: тесты, CI, анализ

**Приоритет: Высокий перед релизом.**

#### A. Flutter Analyze — зелёный
- Прогнать `flutter analyze --no-fatal-infos`
- Исправить все warnings (deprecated API, unused imports, nullable)

#### B. Тесты
- Unit: `computeWearForecast` — все ветки (retired, offSeason, neverWorn, > 30d, > 14d)
- Unit: `generateDailyMissions` — все комбинации флагов
- Unit: `computeGentlemanScore` — 5 компонентов
- Widget: `ClothingCard` с разными urgency (уже частично есть)
- Widget: `DashboardScreen` — smoke test (рендерится без ошибок)
- Widget: `PurchasesScreen` — переключение табов
- Migration: v1→v2→v3→v4→v5→v6→v7 без потери данных

#### C. CI
- Убедиться что `flutter test --coverage` проходит в CI runner
- Порог покрытия 60% (информативно, без fail)

---

### V2.12 — Качество: тесты и CI

**Приоритет: Высокий.**

#### A. Flutter Analyze — зелёный
- `flutter analyze --no-fatal-infos` без единого warning
- Deprecated API (Dart 3.9+), unused imports, nullable-проблемы

#### B. Unit тесты
- `computeWearForecast` — все 5 ветвей urgency + граничные случаи
- `generateDailyMissions` — все комбинации флагов
- `computeGentlemanScore` — 5 компонентов
- `scoreOutfit` — fit/color/occasion/weather/comfort
- `markerStatus(type, value)` — норма/внимание/риск

#### C. Widget тесты
- `DashboardScreen` — smoke test (рендерится без ошибок)
- `PurchasesScreen` — переключение 5 табов
- `WardrobeScreen` — поиск фильтрует items
- `OutfitDetailScreen` — score breakdown отображается

#### D. CI
- `flutter test --coverage` зелёный

---

## 3. V3.x — Weight Loss Intelligence + AI Nutrition

> Полная спецификация: [docs/16-weight-health-ai-spec.md](16-weight-health-ai-spec.md)  
> Требует: DB миграция **v7 → v8** (новые таблицы: FoodLog, FoodItem, DailyCompliance, RecoveryLog, WeeklyReport, SupplementLog, NutritionGoal)

---

### V3.0 — Weight Loss Intelligence Layer

**Приоритет: Высокий**

#### A. Safe Weight Loss Rate System
- Анализ скорости снижения веса каждую неделю (кг/нед, moving average)
- Три режима ответа: < 0.3 / 0.3–0.5 / > 1 кг/нед с operator-style сообщениями
- Plateau detection: вес стоит ≥ 14 дней → "Plateau protocol initiated."
- Для протокола тирзепатида: physician-oriented suggestion (не медицинские указания)

#### B. Compliance Score
- Замена счётчику калорий: `System Compliance: 82%`
- 7 компонентов: логирование, белок, вес, вода, check-in, сон, шаги
- Показывается на Dashboard вместо/рядом с Gentleman Score
- Психологический эффект: «держу систему», не «провалил диету»

#### C. Advanced Metrics
- Moving average weight (7 дней)
- Waist trend (см/нед)
- Adherence score
- Protein consistency score
- Estimated fat-loss pace
- Plateau detection flag

#### D. DB Migration v7 → v8
- Новая таблица `FoodLog` (приём пищи)
- Новая таблица `DailyCompliance` (дневной score)
- Новая таблица `RecoveryLog` (энергия, голод, сон, стресс, вода, шаги)
- Расширение `MeasurementLog`: proteinGrams, hydrationMl

---

### V3.1 — AI Food Analysis

**Приоритет: Высокий**

#### A. Text + Photo Food Logging
- Текст: «Стейк и картошка» → AI → approximate nutrition
- Фото: camera → base64 → RouterAI (gemini-2.5-flash vision) → results
- UX: < 5 секунд от фото до результата
- Approximate values: ~620 kcal, «Protein: likely adequate»

#### B. Nutrition AI Abstraction
- Новый порт `NutritionAiAdvisor` (параллельно `AiAdvisor`)
- Переиспользовать `RouterAiClient.analyzeImage()` (уже реализован)
- Fallback: если нет ключа → manual entry форма

#### C. AI Food Quality Engine
- Satiety score
- Processing level (ultra-processed flag)
- Protein quality assessment
- Overeating probability

#### D. Smart Behavior Detection (без токсичности)
- Binge patterns, nighttime overeating, liquid calories, low protein streaks
- Формулировки: «Late eating pattern detected» — никогда «you failed»

---

### V3.2 — Behavioral Intelligence

**Приоритет: Высокий**

#### A. Operator-Style Dashboard Insights
- 1–2 insights в ротации на главном экране
- Примеры: «Protein compliance below target», «Waist trend improving faster than weight»

#### B. System Drift Detection
- Автоматическое обнаружение ухудшения режима
- Триггеры: пропуски > 2 дней, плохой сон > 3 ночей, рост позднего приёма пищи
- Ответ: «Behavior drift detected» (не «you are failing»)

#### C. Smart Notification Escalation
- Day 1: «No meals logged today»
- Day 3: «Tracking consistency deteriorating»
- Day 5: «Visibility lost»
- Day 7: «Re-entry recommended. Start with one meal.»

#### D. Low Effort Day Mode
- Кнопка «Minimal compliance mode»
- Достаточно: вес + 1 еда + вода
- Streak сохраняется

#### E. Re-entry Flow
- После пропуска ≥ 3 дней → экран «System ready. Resume from current state.»
- 3 поля: вес, талия, еда сегодня

#### F. Smart Relapse Prevention
- ИИ замечает нарастание хаоса
- Мягкие nudges: «Minimal logging is still better than losing visibility»

#### G. Plateau Protocol
- При plateau: диагностика adherence, воды, белка, позднего питания, стресса
- Конкретные гипотезы, не общие советы

---

### V3.3 — Recovery Layer

**Приоритет: Средний**

#### A. Daily Recovery Check-in
- Энергия (1–10), голод (1–10), тяга к еде (1–10), стресс (1–10)
- Сон (часы), вода (мл), шаги (из Health Connect если доступно)

#### B. Recovery State Engine
- Автоматическое определение: Optimal / Mild Fatigue / Stress Elevated / CNS Load High / Recovery Compromised
- Влияет на тон системных сообщений и aggressive goals

#### C. Metabolic Weather (дейли-статус)
- Один из 6 состояний: Stable / Volatile / Recovery Focused / High Stress / Appetite Suppressed / Adaptive Plateau
- Показывается на Dashboard

#### D. Operational Readiness Score
- «Operational Readiness: STABLE»
- На основе: сон + энергия + белок + гидратация + вес + активность + стресс
- Состояния: Optimal / Stable / Compromised / Recovery Needed

#### E. Circadian Intelligence
- Анализ регулярности сна/пробуждения
- Insights: «Sleep regularity improving appetite stability»

#### F. Protein Preservation Engine
- г белка / кг веса
- Предупреждение при риске потери мышц: «Current pace may compromise lean mass»

#### G. Adaptive Goal System
- При стрессе / плохом сне → временно снижать цели
- «Maintain operational stability» вместо «Lose weight harder»

---

### V3.4 — AI Reporting & Identity

**Приоритет: Средний**

#### A. AI Weekly Debrief
- Каждую неделю — tactical operator report (авто-генерация)
- Формат: вес, талия, compliance, белок, поздняя еда, сон, trajectory, next focus

#### B. Future Self Projection
- Холодный расчёт траектории: «Current trajectory → -18 kg in 12 months»
- «Current adherence insufficient for target timeline»

#### C. Monthly Executive Report
- PDF/share-style summary
- Секции: weight trend, waist trend, adherence, protein, recovery, projected outcome
- Экспорт для врача / тренера

#### D. Identity Engine (Phase System)
- 5 фаз: System Recovery → Metabolic Stabilization → Fat Loss → Recomposition → Athletic Build
- Нарративные сообщения: «Behavior becoming stable», «Control improving»

#### E. Invisible Progress Detection
- Когда вес стоит, но поведенческие маркеры улучшаются:
  «Scale stagnant. Behavioral markers improving.»

#### F. Behavior Drift Heatmap
- Визуализация нестабильных дней/часов
- «Most instability occurs after low sleep nights»

---

### V3.5 — Advanced UX

**Приоритет: Средний**

#### A. Voice-First Food Logging
- Голосовой ввод: «Два бургера, кола и картошка»
- AI распознаёт → оценивает → вносит автоматически

#### B. Waist Visualization Priority
- Большой акцент на waist trend (не вес)
- Belt notch milestones: «1 belt notch recovered»
- Estimated visceral fat reduction

#### C. Supplement Stack Tracking
- Minimal executive stack: magnesium, omega-3, creatine, fiber, vitamin D, electrolytes
- Reminder, adherence, subjective effect (1–5)

#### D. Micro-Habit Engine
- 1 ключевой micro-habit в неделю (ИИ выбирает)
- Примеры: walk after meals, protein first, hydration before caffeine

#### E. No Zero Days / Minimal Viable Compliance
- Система определяет минимальный протокол для continuity
- «System continuity preserved»

#### F. Cognitive Load Reduction
- Система замечает усталость от трекинга
- Упрощает UI, предлагает repeat meals, включает quick mode

---

### V3.6 — Biohacking & Longevity

**Приоритет: Низкий**

#### A. Hydration Intelligence
- Счётчик воды с учётом веса тела
- «Hydration below current bodyweight requirements»
- Корреляция с fatigue

#### B. Electrolyte & Mineral Tracking
- Optional: sodium, potassium, magnesium
- Особенно при GLP-1, low-carb, fasting

#### C. Energy Stability Analysis
- Корреляция энергии с едой/сном/стрессом
- «Energy instability increasing»

#### D. Stress → Eating Correlation
- ИИ ищет паттерны: стрессовые дни + поздняя еда
- «Elevated stress correlates with evening overeating»

#### E. Executive Morning Briefing
- Утренний AI-summary: сон, recovery, appetite, hydration, suggested focus

#### F. Evening Shutdown Protocol
- Вечером: логирование + hydration check + late eating warning

#### G. Breathing & Downregulation
- 2-минутные протоколы: stress reset, post-binge recovery, sleep downshift
- Стиль: tactical nervous system reset

#### H. Glucose-Aware Mode (future-ready)
- Заготовка под CGM интеграцию
- Performance metabolic intelligence (не diabetic panic UI)

#### I. UI Theme System
- Operator (default) / Executive / Minimal / Luxury Black

#### J. Executive Silence Mode
- Минимум текста, только critical prompts, silent tracking

---

## 4. Бэклог (идеи для будущего)

| # | Идея | Обоснование |
|---|------|-------------|
| B1 | Импорт анализов из PDF/фото (OCR) | Снизит трение при вводе |
| B2 | Виджет домашнего экрана (Score, задача дня) | Быстрый доступ без открытия |
| B3 | Health Connect: шаги, пульс, сон | Автозаполнение фитнес-данных |
| B4 | Облачный шифрованный бэкап | Защита при потере устройства |
| B5 | AI Coach Persona (personality layer) | Самая addictive часть продукта |
| B6 | Metabolic Resilience Score | Комплексный индекс стабильности |
| B7 | Nervous System Load Analysis | HRV + поведение + fatigue |
| B8 | Smart Meal Timing (не ЧТО есть, а КАК строить день) | Особенно ценно на GLP-1 |
| B9 | Appetite Signal Calibration | На тирзепатиде люди теряют hunger cues |
| B10 | AI Narrative Shift (постепенная смена self-image) | Behavioral psychology layer |

---

## 5. Принципы разработки (дополнены для V3.x)

1. **Приложение запускаемо на каждом шаге** — ни один коммит не ломает `main`.
2. **Offline-first** — данные не покидают устройство без явного действия.
3. **Объяснимость** — каждая рекомендация показывает «почему».
4. **Не медприбор** — здоровье: трекинг и просвещение, не диагностика.
5. **Нет преждевременных абстракций** — три похожих строки лучше абстракции.
6. **Никогда не писать** «ты провалился», «ты сломал стрик» — только operator-style patterns.
7. **Approximate values** для AI nutrition — никогда не симулировать точность.
8. **Physician-oriented language** для медицинских тем — только suggestions, не указания.
9. **Не obsessive tracker** — compliance score, не калорийная тюрьма.

---

## 6. Риски

| Риск | Митигация |
|------|-----------|
| Раздувание scope V2.x | V2.12 ограничены конкретными задачами |
| Снижение мотивации | RPG-слой + чёткие milestone с DoD |
| Регрессии при полировке | Widget-тесты + code-review после каждой итерации |
| WearLogs неточность | urgency strip использует estimate; точность вырастет с накоплением данных |
| V3.x scope creep | Реализация пофазно: V3.0 → V3.1 → V3.2 без перепрыгивания |
| AI food analysis точность | Всегда approximate — UI явно показывает «~» и «likely» |
| Медицинская ответственность | Physician-oriented language + дисклеймер на всех health экранах |
| DB migration v8 сложность | Только additive изменения (новые таблицы), без ALTER COLUMN |
| RouterAI стоимость (food logging) | Кэшировать результаты, rate limit, graceful degradation |
