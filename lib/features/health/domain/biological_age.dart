/// Объяснимая оценка биологического возраста (Уровень 2 — Здоровье).
/// ВАЖНО: это просвещение и трекинг, НЕ медицинская диагностика. Оценка грубая
/// и объяснимая: хронологический возраст корректируется суммой факторов.
/// См. docs/16-vision-three-levels-and-biohacking.md.
library;

/// Фактор, сдвигающий биологический возраст относительно хронологического.
/// Отрицательная дельта — «омолаживает» (хорошие привычки), положительная —
/// «старит» (избыточная талия, плохой сон и т.п.).
class BioAgeFactor {
  const BioAgeFactor({required this.label, required this.deltaYears});

  /// Объяснение фактора («Талия в норме», «Недосып»).
  final String label;

  /// Сдвиг в годах (может быть отрицательным).
  final double deltaYears;
}

/// Результат оценки: число лет + объяснение по факторам.
class BioAgeResult {
  const BioAgeResult({required this.years, required this.explanation});

  /// Оценка биологического возраста в годах.
  final double years;

  /// Список объяснений (принцип объяснимости проекта).
  final List<String> explanation;
}

/// Оценивает биологический возраст: хронологический + сумма факторов,
/// ограниченный разумным диапазоном [18, 100].
BioAgeResult biologicalAge({
  required int chronologicalAge,
  required List<BioAgeFactor> factors,
}) {
  final delta = factors.fold<double>(0, (s, f) => s + f.deltaYears);
  final raw = chronologicalAge + delta;
  final years = raw.clamp(18.0, 100.0);
  return BioAgeResult(
    years: years,
    explanation: [
      'Хронологический возраст: $chronologicalAge',
      for (final f in factors)
        '${f.label}: ${f.deltaYears >= 0 ? '+' : ''}'
            '${f.deltaYears.toStringAsFixed(1)} г.',
    ],
  );
}
