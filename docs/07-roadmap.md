# 07. Дорожная карта — актуальное состояние и план V2.x / V3.x

> Последнее обновление: **2026-06-24**  
> Ветка: `claude/code-docs-review-x4vztn` (= main, `9668c6b`)  
> Схема БД: **v7** (v8 запланирована под V3.0)  
> RouterAI: `google/gemini-3.5-flash` (default + vision), audio endpoints (`transcribeAudio` / `synthesizeSpeech`) — фундамент V3.5

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

### V2.x — Итеративные улучшения (все завершены ✅)

| Версия | Фича | Ветка/коммит |
|--------|------|--------|
| V2.1 | Аниме-маскот (`MascotAvatar`, `moodFromScore`) | main |
| V2.2 | Модуль «Мужское здоровье» (16 маркеров, индекс, ИИ-разбор) | main |
| V2.3 | ИИ-советник по гардеробу (`styleAdviceProvider`), ИИ-анализ фото вещи | main |
| V2.4 | `WearForecast` / `WearUrgency` — прогноз носки на карточке вещи + ткань | main |
| — | **Исправления 6 bugs** post-code-review | main |
| V2.5 | Тренд-дельты в фитнесе (↑↓) + 7-дневный calendar strip в привычках | main |
| V2.6 | Urgency-сортировка гардероба + outfit-today fix + 5 табов в покупках | main |
| V2.7 | Dashboard urgency strip + knowledge bookmarks/favorites + время чтения | main |
| V2.8 | Score breakdown в outfit + «Надеть весь образ» + поиск в гардеробе | `9ad33cb` |
| V2.9 | Habits-блок на Dashboard + outfit occasion filter + rating + purchase→wardrobe | `1a1ca21` |
| V2.10 | Мультифильтр гардероба + быстрое выполнение привычки + style advisor context | `be4ff83` |
| V2.11 | Расширение unit-тестов + widget smoke tests (Dashboard, Wardrobe, Purchases) | `b0cde2b` |
| V2.12 | Фикс CI (`custom_lint`/`riverpod_lint`) + фикс `XpType.habits` + widget-тесты | `d46398d` |
| — | Фикс `discipline-habits` категории + schema **v7** миграция | `3b235f7` |
| — | RouterAI: audio STT/TTS + provider routing | `febe0f0` |
| — | Расшифровка фото бланка анализов через RouterAI (V2 здоровье) | `18bd8e8` |
| — | Авто-импорт анализов с фото (`LabImporter`) + модели Gemini 3 Flash | `a14df71` |
| — | Фиксы slug моделей RouterAI → `google/gemini-3.5-flash` | `c5a5fc7` |
| — | Confirm destructive deletes (образы, маркеры здоровья) | `8ae04bb` |
| — | `flutter analyze --no-fatal-infos` — 0 errors, 0 warnings | `9668c6b` |

---

## 2. Следующие шаги — V3.0

> Все фазы V2.x (V2.1–V2.12) **завершены** и смёрджены в `main`.
> Текущее состояние: schema v7, RouterAI Gemini 3.5 Flash, lab photo import, analyze clean.
> Ближайший шаг — старт V3.0 в новой feature-ветке.

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
- Фото: camera → base64 → RouterAI (gemini-3-flash-preview vision) → results
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
| ~~B1~~ | ~~Импорт анализов из PDF/фото (OCR)~~ | **✅ Реализован** (`LabPhotoAnalyzer`, `a14df71`) |
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
