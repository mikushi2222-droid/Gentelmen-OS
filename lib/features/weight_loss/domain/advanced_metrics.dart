/// V3.0 — Advanced Metrics: расширенный анализ состава тела и прогресса.
///
/// Все функции — чистые, без Flutter и Drift. Стиль — оператор-стайл.
/// «Талия важнее весов» — основной принцип визуализации прогресса V3.x.
library;

import 'package:gentleman_os/features/weight_loss/domain/weight_trend.dart';

/// Точка измерения талии (дата + см).
class WaistPoint {
  const WaistPoint({required this.date, required this.cm});
  final DateTime date;
  final double cm;
}

/// Результат анализа тренда талии.
class WaistTrendResult {
  const WaistTrendResult({
    required this.weeklyRateCmPerWeek,
    required this.totalDeltaCm,
    required this.beltNotchesRecovered,
    this.explanation = const [],
  });

  /// Скорость изменения талии, см/нед (отрицательная = снижение, хорошо).
  final double weeklyRateCmPerWeek;

  /// Общая дельта за весь период, см.
  final double totalDeltaCm;

  /// Количество условных «дырок на ремне» восстановлено
  /// (каждые 2 см снижения ≈ 1 дырка).
  final int beltNotchesRecovered;

  final List<String> explanation;
}

/// Анализирует тренд обхвата талии.
///
/// [points] — хронологически упорядоченный список.
/// [cmPerBeltNotch] — сколько см изменения талии ≈ одна дырка ремня (default 2).
WaistTrendResult analyzeWaistTrend({
  required List<WaistPoint> points,
  double cmPerBeltNotch = 2.0,
}) {
  final sorted =
      List<WaistPoint>.from(points)..sort((a, b) => a.date.compareTo(b.date));

  if (sorted.length < 2) {
    return const WaistTrendResult(
      weeklyRateCmPerWeek: 0,
      totalDeltaCm: 0,
      beltNotchesRecovered: 0,
      explanation: ['Недостаточно замеров.'],
    );
  }

  final totalDays =
      sorted.last.date.difference(sorted.first.date).inDays.toDouble();
  if (totalDays < 1) {
    return const WaistTrendResult(
      weeklyRateCmPerWeek: 0,
      totalDeltaCm: 0,
      beltNotchesRecovered: 0,
      explanation: ['Все замеры в один день.'],
    );
  }

  final totalDelta = sorted.last.cm - sorted.first.cm;
  final weeklyRate = totalDelta / totalDays * 7;
  final notches = totalDelta < 0
      ? (-totalDelta / cmPerBeltNotch).floor()
      : 0;

  return WaistTrendResult(
    weeklyRateCmPerWeek: weeklyRate,
    totalDeltaCm: totalDelta,
    beltNotchesRecovered: notches,
    explanation: [
      'Период: ${sorted.length} замеров за ${totalDays.round()} дн.',
      'Дельта: ${totalDelta >= 0 ? '+' : ''}${totalDelta.toStringAsFixed(1)} см',
      'Скорость: ${weeklyRate.toStringAsFixed(2)} см/нед',
      if (notches > 0)
        'Belt notches recovered: $notches'
              ' (каждые ${cmPerBeltNotch.toStringAsFixed(0)} см ≈ 1 дырка)',
    ],
  );
}

/// Оценка предполагаемого процента потери жира относительно общего снижения
/// веса. Основана на эмпирических данных по высокобелковым диетам:
/// при достаточном белке (~1.6 г/кг) → 80–90% потерь = жир.
///
/// [weightLostKg] — сколько кг потеряно суммарно (> 0).
/// [proteinAdequate] — было ли белка достаточно (≥ 1.4 г/кг веса).
/// [trainingActive] — есть ли силовые тренировки.
///
/// Возвращает оценку доли жира в потерях [0..1].
double estimateFatLossFraction({
  required double weightLostKg,
  bool proteinAdequate = false,
  bool trainingActive = false,
}) {
  if (weightLostKg <= 0) return 0.0;
  double fraction = 0.65; // baseline
  if (proteinAdequate) fraction += 0.12;
  if (trainingActive) fraction += 0.08;
  return fraction.clamp(0.0, 1.0);
}

/// Adherence score: отношение «дней с хоть каким-то логированием» к
/// «всем дням в периоде». Простая метрика системного соответствия.
///
/// [loggedDays] — количество дней, где было хотя бы одно действие.
/// [totalDays] — общее количество дней в периоде.
double adherenceScore({
  required int loggedDays,
  required int totalDays,
}) {
  if (totalDays <= 0) return 0.0;
  return (loggedDays / totalDays).clamp(0.0, 1.0);
}

/// Сводный прогресс-отчёт за период.
class ProgressSnapshot {
  const ProgressSnapshot({
    required this.weightDeltaKg,
    required this.waistDeltaCm,
    required this.adherence,
    required this.estimatedFatFraction,
    required this.beltNotchesRecovered,
    this.insights = const [],
  });

  final double weightDeltaKg;
  final double waistDeltaCm;

  /// Adherence [0..1].
  final double adherence;

  /// Оценочная доля жира в потерях [0..1].
  final double estimatedFatFraction;

  final int beltNotchesRecovered;

  /// Оператор-стайл insights для UI.
  final List<String> insights;
}

/// Строит сводный отчёт по прогрессу за период.
ProgressSnapshot buildProgressSnapshot({
  required List<WeightPoint> weightPoints,
  required List<WaistPoint> waistPoints,
  required int loggedDays,
  required int totalDays,
  bool proteinAdequate = false,
  bool trainingActive = false,
}) {
  final wt = analyzeWeightTrend(points: weightPoints);
  final waist = analyzeWaistTrend(points: waistPoints);
  final adh = adherenceScore(loggedDays: loggedDays, totalDays: totalDays);

  final weightLost = wt.weeklyRatekgPerWeek < 0
      ? -(weightPoints.isEmpty
          ? 0.0
          : weightPoints.last.kg - weightPoints.first.kg)
      : 0.0;
  final fatFraction = estimateFatLossFraction(
    weightLostKg: weightLost,
    proteinAdequate: proteinAdequate,
    trainingActive: trainingActive,
  );

  final insights = _buildInsights(wt, waist, adh);

  return ProgressSnapshot(
    weightDeltaKg:
        weightPoints.length >= 2
            ? weightPoints.last.kg - weightPoints.first.kg
            : 0,
    waistDeltaCm: waist.totalDeltaCm,
    adherence: adh,
    estimatedFatFraction: fatFraction,
    beltNotchesRecovered: waist.beltNotchesRecovered,
    insights: insights,
  );
}

List<String> _buildInsights(
  WeightTrendResult wt,
  WaistTrendResult waist,
  double adherence,
) {
  final result = <String>[];

  if (adherence < 0.5) {
    result.add('Tracking consistency deteriorating. Resume minimal logging.');
  } else if (adherence >= 0.85) {
    result.add('Tracking consistency: high.');
  }

  if (wt.status == WeightTrendStatus.plateau) {
    if (waist.weeklyRateCmPerWeek < -0.1) {
      result.add(
          'Scale stagnant. Waist trend improving — body recomposition detected.');
    } else {
      result.add('Plateau detected. Review adherence, hydration, protein.');
    }
  }

  if (wt.status == WeightTrendStatus.aggressive) {
    result.add(
        'Rate elevated. Lean mass preservation protocol: increase protein.');
  }

  if (waist.beltNotchesRecovered >= 1) {
    result.add('Belt notch progress: ${waist.beltNotchesRecovered} recovered.');
  }

  return result;
}
