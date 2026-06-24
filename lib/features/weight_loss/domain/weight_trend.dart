/// V3.0 — Weight Loss Intelligence Layer: анализ тренда веса.
///
/// Чистые функции без Flutter и Drift — полностью тестируемы.
/// Философия: оператор-стайл, не терапевт. Система замечает паттерны и
/// называет их без осуждения. Никогда «ты провалился» — только «паттерн».
library;

/// Статус скорости снижения веса за неделю.
///
/// Основано на клинически принятых ориентирах для устойчивого снижения
/// веса без риска потери мышечной массы.
enum WeightTrendStatus {
  /// Снижение медленнее 0.3 кг/нед — плато или набор.
  plateau,

  /// 0.3–1.0 кг/нед — целевой коридор устойчивого снижения.
  optimal,

  /// Быстрее 1.0 кг/нед — повышенный риск потери мышечной массы.
  aggressive,

  /// Нет достаточно данных (< 2 измерений).
  insufficient,
}

extension WeightTrendStatusX on WeightTrendStatus {
  /// Оператор-стайл сообщение для отображения в UI.
  String get message => switch (this) {
        WeightTrendStatus.plateau => 'Plateau detected.',
        WeightTrendStatus.optimal => 'Weight loss trajectory: optimal.',
        WeightTrendStatus.aggressive =>
          'Rate elevated. Lean mass preservation protocol recommended.',
        WeightTrendStatus.insufficient => 'Insufficient data. Continue logging.',
      };
}

/// Результат анализа тренда веса.
class WeightTrendResult {
  const WeightTrendResult({
    required this.status,
    required this.weeklyRatekgPerWeek,
    required this.movingAverage,
    this.plateauDays = 0,
    this.explanation = const [],
  });

  final WeightTrendStatus status;

  /// Средняя скорость снижения, кг/нед (отрицательная при наборе).
  final double weeklyRatekgPerWeek;

  /// 7-дневная скользящая средняя по последним точкам (кг).
  /// Пустой список — данных нет.
  final List<double> movingAverage;

  /// Количество дней без значимого снижения (для plateau).
  final int plateauDays;

  /// Объяснение расчёта (принцип объяснимости).
  final List<String> explanation;
}

/// Точка замера: дата + значение веса в кг.
class WeightPoint {
  const WeightPoint({required this.date, required this.kg});
  final DateTime date;
  final double kg;
}

/// Анализирует тренд веса по серии замеров.
///
/// [points] — хронологически упорядоченный список замеров (старые → новые).
/// [plateauThresholdDays] — сколько дней без снижения считать плато (default 14).
/// [plateauMinDeltaKg] — минимальное снижение кг для НЕ-плато (default 0.2).
WeightTrendResult analyzeWeightTrend({
  required List<WeightPoint> points,
  int plateauThresholdDays = 14,
  double plateauMinDeltaKg = 0.2,
}) {
  final sorted =
      List<WeightPoint>.from(points)..sort((a, b) => a.date.compareTo(b.date));

  if (sorted.length < 2) {
    return const WeightTrendResult(
      status: WeightTrendStatus.insufficient,
      weeklyRatekgPerWeek: 0,
      movingAverage: [],
      explanation: ['Менее двух измерений — тренд не вычисляется.'],
    );
  }

  final totalDays =
      sorted.last.date.difference(sorted.first.date).inDays.toDouble();
  if (totalDays < 1) {
    return const WeightTrendResult(
      status: WeightTrendStatus.insufficient,
      weeklyRatekgPerWeek: 0,
      movingAverage: [],
      explanation: ['Все замеры в один день — тренд не вычисляется.'],
    );
  }

  final totalDelta = sorted.last.kg - sorted.first.kg;
  final weeklyRate = totalDelta / totalDays * 7;
  final movingAvg = _movingAverage(sorted, windowDays: 7);

  // Plateau: последние plateauThresholdDays — снижение < plateauMinDeltaKg.
  final plateauDays = _countPlateauDays(
    sorted,
    thresholdDays: plateauThresholdDays,
    minDeltaKg: plateauMinDeltaKg,
  );

  final status = _classifyRate(weeklyRate, plateauDays, plateauThresholdDays);

  return WeightTrendResult(
    status: status,
    weeklyRatekgPerWeek: weeklyRate,
    movingAverage: movingAvg,
    plateauDays: plateauDays,
    explanation: [
      'Период: ${sorted.length} замеров за ${totalDays.round()} дн.',
      'Дельта: ${totalDelta >= 0 ? '+' : ''}${totalDelta.toStringAsFixed(1)} кг',
      'Скорость: ${weeklyRate.toStringAsFixed(2)} кг/нед',
      if (plateauDays >= plateauThresholdDays)
        'Плато: $plateauDays дн. без значимого снижения (порог ${plateauMinDeltaKg.toStringAsFixed(1)} кг)',
    ],
  );
}

WeightTrendStatus _classifyRate(
    double rate, int plateauDays, int plateauThresholdDays) {
  if (plateauDays >= plateauThresholdDays) return WeightTrendStatus.plateau;
  if (rate > -0.3) return WeightTrendStatus.plateau;
  if (rate < -1.0) return WeightTrendStatus.aggressive;
  return WeightTrendStatus.optimal;
}

/// 7-дневная скользящая средняя по дням (не по точкам).
List<double> _movingAverage(List<WeightPoint> sorted, {int windowDays = 7}) {
  final result = <double>[];
  for (var i = 0; i < sorted.length; i++) {
    final cutoff = sorted[i].date.subtract(Duration(days: windowDays - 1));
    final window = sorted.where((p) => !p.date.isBefore(cutoff) &&
        !p.date.isAfter(sorted[i].date)).toList();
    if (window.isEmpty) continue;
    final avg = window.map((p) => p.kg).reduce((a, b) => a + b) / window.length;
    result.add(double.parse(avg.toStringAsFixed(2)));
  }
  return result;
}

/// Сколько дней подряд (считая от последнего замера назад) вес не снизился
/// на [minDeltaKg] относительно того же периода.
int _countPlateauDays(
  List<WeightPoint> sorted, {
  required int thresholdDays,
  required double minDeltaKg,
}) {
  if (sorted.length < 2) return 0;
  final last = sorted.last;
  final cutoff = last.date.subtract(Duration(days: thresholdDays));
  final windowPoints = sorted.where((p) => !p.date.isBefore(cutoff)).toList();
  if (windowPoints.length < 2) return 0;
  final delta = windowPoints.last.kg - windowPoints.first.kg;
  // delta < 0 означает снижение; если снизились меньше чем на minDeltaKg — плато.
  if (delta > -minDeltaKg) {
    return last.date.difference(windowPoints.first.date).inDays;
  }
  return 0;
}
