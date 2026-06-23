# 16. Weight Loss Intelligence + AI Nutrition — Feature Spec

> Версия: **2026-06-23**  
> Продуктовая ниша: **masculine health OS для мужчин с высоким ИМТ, особенно на GLP-1 / тирзепатиде**  
> Принцип: behavior system, accountability system, intelligent health OS — не obsessive calorie app.

---

## Ключевой тезис

Цель не «похудеть за месяц», а:

> **Stable. Capable. Disciplined. Metabolically healthy man.**

Система помогает держать курс — не оценивает человека.
Формулировки — всегда **operator-style**: паттерны, метрики, коррекция курса.
Никогда — вина, стыд, провал.

---

## A. Safe Weight Loss Rate System

### A1. Целевой диапазон

| Показатель | Значение |
|-----------|----------|
| Целевая скорость | 0.3–0.5 кг/неделю |
| Режим | Slow sustainable fat loss |
| Цель | Сохранение мышц + долгосрочная устойчивость |

### A2. Еженедельный анализ

Анализировать каждую неделю:
- Средний вес (moving average, 7 дней)
- Тренд снижения (кг/нед)
- Waist trend (см/нед)
- Adherence score
- Белок (г/день, соответствие норме)
- Логирование питания (% дней)

### A3. Ответы системы по скорости снижения

**< 0.3 кг/неделю:**
```
"Progress slower than target."
"Review intake consistency."
"Possible metabolic adaptation detected."
```
При активном протоколе тирзепатида:
```
"Discuss dose escalation with your physician if plateau persists."
```
⚠️ Только suggestion + physician-oriented language. **Никаких прямых медицинских указаний.**

**0.3–0.5 кг/неделю:**
```
"Optimal sustainable pace."
"Excellent long-term trajectory."
"Current protocol effective."
```

**> 0.5–1 кг/неделю:**
```
"Above target pace. Monitor protein intake."
"Ensure adequate nutrition for lean mass preservation."
```

**> 1 кг/неделю:**
```
"Rapid loss detected."
"Monitor protein intake and recovery closely."
"Ensure adequate nutrition."
```

---

## B. Compliance Score (Killer Feature)

Замена счётчику калорий. Пользователь видит не «1200/1800 ккал», а:

```
System Compliance: 82%
```

### B1. Компоненты Compliance Score

| Компонент | Вес |
|----------|-----|
| Логирование еды (% дней) | 20% |
| Белок (соответствие цели) | 25% |
| Вес (внесён сегодня) | 15% |
| Вода (норма) | 15% |
| Weekly check-in | 10% |
| Сон (часы, регулярность) | 10% |
| Шаги / активность | 5% |

Психологический эффект:
> «Я держу систему» — не «я провалил диету».

---

## C. AI Food Analysis System

### C1. Input Methods

| Метод | Описание |
|-------|---------|
| Фото | Сфотографировать тарелку |
| Текст | «Стейк и картошка», «2 яйца, кофе и сыр» |
| Голос | «Два бургера, кола и картошка» |

### C2. AI Analysis Output

ИИ оценивает:
- Блюдо (распознавание)
- Калории (~620 kcal — approximate, не exact)
- Белки / жиры / углеводы
- Ultra-processed food flag
- Satiety score
- Protein quality
- Fiber quality
- Overeating probability

**Важно**: показывать approximate values, не pretending exact precision:
```
~620 kcal
Protein: likely adequate
Fiber: low
Satiety: high
Processing level: minimal
```

### C3. AI Food Insights

После анализа — краткий комментарий (1–2 строки):
```
"Good protein density."
"Likely low satiety despite calories."
"High-calorie liquid intake detected."
"Meal composition supports fat loss."
"Protein too low for appetite preservation."
"Excellent protein-to-calorie ratio."
```

### C4. Smart Behavior Detection

ИИ замечает (без токсичности):
- Binge patterns
- Nighttime overeating
- Liquid calories
- Low protein streaks
- Frequent restaurant meals
- Emotional eating timing

Формулировки — всегда мягкие:
```
"Late eating pattern detected."
"Liquid calories noted — often invisible."
```

### C5. Food Analysis UX Flow

1. Фото → AI scanning animation
2. Распознавание блюда
3. Estimated nutrition card
4. One-tap confirm
5. AI insight (1–2 строки)

Цель: **< 5 секунд** от фото до результата.

---

## D. API Architecture (AI Abstraction Layer)

### D1. Multi-Provider Support

Расширение существующего `AiAdvisor` порта:

```dart
abstract class NutritionAiAdvisor {
  Future<FoodAnalysisResult> analyzeFood({
    String? text,
    String? imageBase64,
    String? mime,
  });
  
  Future<WeeklyReport> generateWeeklyDebrief(WeeklySummary data);
  Future<String> generateBehaviorInsight(BehaviorSnapshot snapshot);
}
```

Поддерживаемые провайдеры через RouterAI:
- `openai/gpt-4o` (vision + text)
- `anthropic/claude-sonnet-4.5`
- `google/gemini-2.5-flash` (multimodal, основной для vision)
- `openai/gpt-4o-mini` (экономичный)

### D2. Multimodal Support

Vision-запросы через `RouterAiClient.analyzeImage()` (уже реализован для гардероба).
Переиспользовать существующую инфраструктуру.

### D3. Fallback Chain

```
Cloud AI → Local rules → Graceful degradation
```

---

## E. Advanced Health Metrics

### E1. Новые метрики (расширение MeasurementLog)

| Метрика | Тип | Описание |
|--------|-----|---------|
| `movingAvgWeight` | computed | Скользящее среднее веса, 7 дней |
| `waistTrendPerWeek` | computed | Тренд талии (см/нед) |
| `adherenceScore` | computed | % соответствия протоколу |
| `proteinConsistencyScore` | computed | Регулярность потребления белка |
| `estimatedFatLossPace` | computed | Оценочная скорость потери жира |
| `plateauDetected` | bool | Вес стоит ≥ 14 дней |
| `energyLevel` | int (1–10) | Субъективная энергия |
| `hungerLevel` | int (1–10) | Уровень голода |
| `cravings` | int (1–10) | Тяга к еде |
| `stressLevel` | int (1–10) | Стресс |
| `sleepHours` | double | Часы сна |
| `hydrationMl` | int | Вода (мл) |
| `stepsCount` | int | Шаги |
| `proteinGrams` | int | Белок (г) |

### E2. Plateau Detection

Если `movingAvgWeight` меняется < 0.15 кг за 14 дней → plateau detected.

**Plateau Protocol Response (не «ты делаешь плохо»):**
```
"Plateau protocol initiated."
```
Система проверяет:
- adherence (логирование)
- воду
- белок
- позднюю еду
- активность
- стресс

И выдаёт конкретную гипотезу:
```
"Possible factor: reduced logging consistency."
"Possible factor: elevated evening intake."
```

---

## F. Operator-Style Health Insights (Dashboard)

Главный экран может показывать короткие insights (1 строка):

```
"Protein compliance below target."
"Waist trend improving faster than weight."
"Late eating pattern increasing."
"Hydration insufficient for current bodyweight."
"Excellent weekly adherence."
"Current trajectory sustainable."
"Scale stagnant. Behavioral markers improving."
"Behavior drift detected."
```

**Важно**: не более 2 инсайтов на экране одновременно. Ротация.

---

## G. Behavioral Intelligence Engine

### G1. System Drift Detection

ИИ замечает ухудшение режима и пишет:
```
"Behavior drift detected."
```
Никогда:
```
"You are failing."
```

Триггеры дрифта:
- Пропуски логирования > 2 дней
- Ухудшение сна > 3 ночей
- Рост позднего приёма пищи
- Снижение шагов > 30%

### G2. Smart Relapse Prevention

ИИ замечает признаки скорого выпадения:
```
"Users typically disengage after this pattern begins."
"Minimal logging is still better than losing visibility."
```

### G3. Smart Notification Escalation

Тон и частота уведомлений меняются:

| День | Текст |
|------|-------|
| 1 | "No meals logged today." |
| 3 | "Tracking consistency deteriorating." |
| 5 | "Visibility lost." |
| 7 | "Re-entry recommended. Start with one meal." |

### G4. Behavior Drift Heatmap

Визуализация: в какие дни/часы контроль снижается.
ИИ:
```
"Most instability occurs after low sleep nights."
"Friday evening pattern detected."
```

### G5. AI Behavior Forecast

ИИ предсказывает вероятность срыва на основе:
- Пропусков
- Качества сна
- Стрессовых паттернов
- Weekend drift

Тихо, без тревоги:
```
"Compliance instability increasing."
```

---

## H. Low Effort Day Mode

Когда пользователь выгорел или сорвался.

Вместо «you broke your streak» — кнопка:
```
[Minimal compliance mode]
```

Достаточно:
- Вес
- 1 приём пищи
- Вода

Streak сохраняется. **Massively improves retention.**

---

## I. Re-entry Flow

Когда пользователь пропал на 1–30 дней:

Не:
```
"You missed 28 days."
```

А:
```
"System ready. Resume from current state."
```

Один экран, 3 поля:
- Текущий вес
- Талия
- Еда сегодня

Готово. Система продолжает работу.

---

## J. Recovery & Biohacking Layer

> Стиль: **executive longevity OS** + **human performance cockpit**
> Никакой псевдонауки. Только measurable, evidence-aware, practical.

### J1. Recovery Biometrics

Отслеживать:
- Сон (часы + качество)
- Энергия (1–10)
- Стресс (1–10)
- HRV (если есть wearable)
- Fatigue score

### J2. Recovery State Engine

ИИ определяет состояние:

| State | Описание |
|-------|---------|
| Recovery Optimal | Все параметры в норме |
| Mild Fatigue | Небольшое снижение |
| Stress Elevated | Стресс выше обычного |
| CNS Load High | Нагрузка на нервную систему |
| Recovery Compromised | Требуется снижение давления |

Состояние влияет на: тон напоминаний, агрессивность целей, частоту prompts.

### J3. Circadian Intelligence

Анализ:
- Регулярность времени сна/пробуждения
- Поздняя еда
- Вечерняя стимуляция (кофеин, экраны)

Insights:
```
"Late eating correlates with poorer recovery."
"Sleep regularity improving appetite stability."
"Circadian disruption detected."
```

### J4. Metabolic Weather

Дейли-статус как «погода организма»:

| Status | Описание |
|--------|---------|
| Stable | Всё в норме |
| Volatile | Нестабильность показателей |
| Recovery Focused | Приоритет восстановления |
| High Stress | Стресс-режим |
| Appetite Suppressed | Подавленный аппетит (GLP-1) |
| Adaptive Plateau | Адаптация к дефициту |

### J5. Operational Readiness Score

```
Operational Readiness: STABLE
```

На основе: сон + энергия + белок + гидратация + вес + активность + стресс.

Состояния: Optimal / Stable / Compromised / Recovery Needed.

---

## K. Protein Preservation Engine

Критично на тирзепатиде. ИИ оценивает:
- г белка / кг веса тела
- Распределение по приёмам пищи
- Риск потери мышц

Предупреждения:
```
"Protein distribution suboptimal."
"Current intake may impair lean mass retention."
"Current pace may compromise lean mass."
```

---

## L. AI Coach Persona

Не чат-бот. Personality layer поверх системы.

Стиль:
- Calm tactical operator
- Premium physician assistant
- Disciplined executive coach

Характеристики:
- Короткие реплики
- Минимум болтовни
- Максимум usefulness
- Никогда не осуждает

---

## M. AI Weekly Debrief

Каждую неделю — короткий AI-отчёт в стиле **tactical operator report**:

```
WEEKLY STATUS REPORT — Week 24

Weight: -0.4 kg (moving average)
Waist: -1.2 cm
Compliance: 84%
Protein: adequate (4 of 7 days)
Late eating: reduced vs last week
Sleep: stable

Trajectory: sustainable
Next focus: protein consistency
```

---

## N. Future Self Projection

Холодная визуализация траектории (не мотивационные цитаты):

```
"Current trajectory → -18 kg in 12 months."
"Waist trend indicates meaningful visceral fat reduction."
"Current adherence insufficient for target timeline."
```

---

## O. Monthly Executive Report

PDF/share-style summary. Стиль: **luxury medical briefing**.

Секции:
- Weight trend (график)
- Waist trend (график)
- Adherence breakdown
- Protein compliance
- Recovery overview
- Appetite stability
- Projected outcome

Экспорт: JSON / share. Можно показать врачу или тренеру.

---

## P. Identity Engine

Фазовая система для психологической трансформации:

| Phase | Название |
|-------|---------|
| 1 | System Recovery |
| 2 | Metabolic Stabilization |
| 3 | Fat Loss Phase |
| 4 | Body Recomposition |
| 5 | Athletic Build |

Система пишет:
```
"Behavior becoming stable."
"Control improving."
"System consistency established."
"Waistline contracting."
```

Это меняет self-image через язык, не через стыд.

---

## Q. Waist Visualization Priority

Для мужчин с высоким ИМТ талия — более значимый маркер, чем вес.

- Большой акцент на waist trend (не вес)
- Belt notch milestones: «1 notch recovered»
- Clothing fit indicators
- Estimated visceral fat reduction

```
"1 belt notch recovered."
"Estimated visceral fat reduction."
```

---

## R. Voice-First UX

Минимальный friction для ввода еды:

1. Tap mic button
2. «Два бургера, кола и картошка»
3. AI распознал → оценил → внёс

Всё. Без тапинга, без форм.
Особенно важно для пользователей с высоким ИМТ (снижение fatigue).

---

## S. Supplement Stack Tracking

Minimal executive stack. Не bodybuilding app.

Примеры добавок:
- Magnesium
- Omega-3
- Creatine
- Fiber
- Vitamin D
- Electrolytes
- Protein powder

Функции:
- Reminder
- Adherence tracking
- Субъективный эффект (1–5)

---

## T. No Zero Days + Minimal Viable Compliance

Концепция: система всегда принимает минимальный вклад.

```
"System continuity preserved."
```

Минимальный протокол:
- 1 приём пищи залогирован
- Вес внесён
- Вода отмечена

Streak не ломается.

---

## U. Executive Silence Mode

Для мужчин, которые ненавидят лишние уведомления:

- Минимум текста
- Только critical prompts
- Silent tracking
- Quiet UI

Переключается в настройках. **Premium framing.**

---

## V. Micro-Habit Engine

ИИ выбирает **1 ключевой micro-habit в неделю** из:
- Walk after meals
- Protein first at each meal
- Hydration before caffeine
- Sleep consistency ± 30 min

Один фокус. Без перегрузки.

---

## W. Dopamine-Free Achievement System

Без конфетти и мультяшных бейджей.

Minimal prestige achievements:
```
"30 Days Visible"
"System Stabilized"
"100 Meals Logged"
"Consistency Maintained"
"Waistline Reduced"
"Re-entry Successful"
"Plateau Overcome"
"Muscle Preserved"
```

Сдержанно. Премиально.

---

## X. Adaptive Goal System

При повышенном стрессе / плохом сне / побочках:

Не:
```
"Lose weight harder."
```

А:
```
"Maintain operational stability."
```

Система временно снижает требования, сохраняя continuity.

---

## Y. UI Theme System

Optional themes:
- **Operator** (default) — тёмный, тактический
- **Executive** — минималистичный, деловой
- **Minimal** — максимальная чистота
- **Luxury Black** — AMOLED, премиум

---

## Z. Critical Design Rules

1. **Никогда не писать** «ты провалился», «ты сломал стрик», «ты всё делаешь плохо».
2. Всегда **physician-oriented language** для медицинских тем.
3. **Approximate values** для питания — никогда не делать вид, что AI знает точно.
4. **Не превращать** в обсессивный калорийный трекер.
5. **Никакой псевдонауки** в biohacking-слое.
6. **Biohacking Rule**: no crypto-bro nonsense, no alpha male cringe, no fake dopamine hacking.

---

## DB Schema Extensions (v8+)

Новые таблицы / расширения:

| Таблица | Описание |
|--------|---------|
| `FoodLog` | Приём пищи: время, текст, фото, AI-анализ результат |
| `FoodItem` | Распознанный продукт: название, ккал, белок, жиры, углеводы, quality score |
| `DailyCompliance` | Дневной Compliance Score (суммарный + по компонентам) |
| `WeeklyReport` | AI Weekly Debrief (текст + дата) |
| `RecoveryLog` | Ежедневный: энергия, голод, стресс, сон, шаги, вода |
| `SupplementLog` | Приём добавки + субъективный эффект |
| `NutritionGoal` | Целевые значения: белок г/день, калории, вода |

Текущая версия: **v7**. Эти изменения → **v8** (один migration step, добавление таблиц).

---

## Implementation Phases

| Фаза | Описание | Приоритет |
|------|---------|----------|
| V3.0 | Weight loss rate system + Advanced metrics + Compliance Score | Высокий |
| V3.1 | AI Food Analysis (text + photo) + Multi-provider API layer | Высокий |
| V3.2 | Behavioral Intelligence (drift, relapse, escalation, plateau) | Высокий |
| V3.3 | Recovery Layer (energy/sleep/stress tracking + Recovery State) | Средний |
| V3.4 | Weekly Debrief + Monthly Report + Future Self Projection | Средний |
| V3.5 | Voice UX + Supplement tracking + Micro-habit engine | Средний |
| V3.6 | Identity Engine + Waist emphasis + Themes + Re-entry Flow | Низкий |
| V3.7 | Biohacking Layer (Circadian, Metabolic Weather, Longevity Mode) | Низкий |

---

## Non-Goals

- Публичный food database (USDA, FatSecret) — не интегрировать без явной нужды.
- Точный подсчёт калорий — только AI approximation.
- Медицинские диагнозы — только паттерны и physician-oriented suggestions.
- Социальные функции — приложение для одного пользователя.
- Gamification с confetti — только prestige-style achievements.
