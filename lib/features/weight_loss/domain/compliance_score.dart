/// V3.0 — Compliance Score: альтернатива счётчику калорий.
///
/// Измеряем не «сколько съел», а «держит ли человек систему».
/// 7 компонентов, каждый 0..1, итог масштабируется в 0..100.
///
/// Философия: «System Compliance: 82%» — не «ты съел мало», а «ты держишь курс».
/// Формулировки оператор-стайл, никогда не обвинительные.
library;

/// Одна запись для расчёта Compliance Score.
/// Все поля — за один день. null = не залогировано.
class DailyComplianceInput {
  const DailyComplianceInput({
    this.mealsLogged = 0,
    this.weightLogged = false,
    this.waterMl,
    this.sleepHours,
    this.steps,
    this.habitsCompleted = 0,
    this.habitsTotal = 0,
    this.checkInDone = false,
  });

  final int mealsLogged;
  final bool weightLogged;
  final double? waterMl;
  final double? sleepHours;
  final int? steps;
  final int habitsCompleted;
  final int habitsTotal;
  final bool checkInDone;
}

/// Нормативы для Compliance Score (опционально переопределяются пользователем).
class ComplianceNorms {
  const ComplianceNorms({
    this.targetMealsPerDay = 3,
    this.targetWaterMl = 2500,
    this.targetSleepHours = 7.5,
    this.targetSteps = 7000,
  });

  final int targetMealsPerDay;
  final double targetWaterMl;
  final double targetSleepHours;
  final int targetSteps;
}

/// Результат расчёта Compliance Score за день.
class ComplianceResult {
  const ComplianceResult({
    required this.score,
    required this.components,
    required this.message,
  });

  /// Итоговый балл 0..100.
  final double score;

  /// Разбивка по компонентам (0..1 каждый).
  final ComplianceComponents components;

  /// Оператор-стайл сводка.
  final String message;
}

/// Значения 7 компонентов Compliance Score (0..1).
class ComplianceComponents {
  const ComplianceComponents({
    required this.logging,
    required this.weight,
    required this.water,
    required this.sleep,
    required this.steps,
    required this.habits,
    required this.checkIn,
  });

  /// Логирование приёмов пищи.
  final double logging;

  /// Замер веса.
  final double weight;

  /// Потребление воды.
  final double water;

  /// Сон.
  final double sleep;

  /// Шаги.
  final double steps;

  /// Выполнение привычек.
  final double habits;

  /// Утренний/вечерний чек-ин.
  final double checkIn;

  double get average =>
      (logging + weight + water + sleep + steps + habits + checkIn) / 7;
}

/// Веса компонентов (в сумме 1.0).
const _weights = (
  logging: 0.25,
  weight: 0.15,
  water: 0.15,
  sleep: 0.15,
  steps: 0.10,
  habits: 0.15,
  checkIn: 0.05,
);

/// Вычисляет Compliance Score за один день.
///
/// [input] — данные за день.
/// [norms] — целевые показатели (опционально).
ComplianceResult computeComplianceScore({
  required DailyComplianceInput input,
  ComplianceNorms norms = const ComplianceNorms(),
}) {
  final logging = (input.mealsLogged / norms.targetMealsPerDay).clamp(0.0, 1.0);
  final weight = input.weightLogged ? 1.0 : 0.0;
  final water = input.waterMl == null
      ? 0.0
      : (input.waterMl! / norms.targetWaterMl).clamp(0.0, 1.0);
  final sleep = input.sleepHours == null
      ? 0.0
      : (input.sleepHours! / norms.targetSleepHours).clamp(0.0, 1.0);
  final steps = input.steps == null
      ? 0.0
      : (input.steps! / norms.targetSteps).clamp(0.0, 1.0);
  final habits = input.habitsTotal == 0
      ? 0.0
      : (input.habitsCompleted / input.habitsTotal).clamp(0.0, 1.0);
  final checkIn = input.checkInDone ? 1.0 : 0.0;

  final components = ComplianceComponents(
    logging: logging,
    weight: weight,
    water: water,
    sleep: sleep,
    steps: steps,
    habits: habits,
    checkIn: checkIn,
  );

  final raw = logging * _weights.logging +
      weight * _weights.weight +
      water * _weights.water +
      sleep * _weights.sleep +
      steps * _weights.steps +
      habits * _weights.habits +
      checkIn * _weights.checkIn;

  final score = (raw * 100).clamp(0.0, 100.0);

  return ComplianceResult(
    score: score,
    components: components,
    message: _complianceMessage(score),
  );
}

/// Усредняет Compliance Score за несколько дней (7-дневный rolling average).
double averageComplianceScore(List<double> dailyScores) {
  if (dailyScores.isEmpty) return 0.0;
  return dailyScores.reduce((a, b) => a + b) / dailyScores.length;
}

String _complianceMessage(double score) {
  if (score >= 85) return 'System compliance: optimal.';
  if (score >= 65) return 'System compliance: stable.';
  if (score >= 40) return 'System compliance: degraded. Recovery recommended.';
  return 'Visibility lost. Resume from current state.';
}
