import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/fitness/application/fitness_providers.dart';
import 'package:gentleman_os/features/weight_loss/domain/advanced_metrics.dart';
import 'package:gentleman_os/features/weight_loss/domain/compliance_score.dart';
import 'package:gentleman_os/features/weight_loss/domain/weight_trend.dart';

/// Конвертирует список замеров Drift → `WeightPoint[]` для анализа тренда.
/// Фильтрует записи без значения веса.
final weightPointsProvider = Provider<AsyncValue<List<WeightPoint>>>((ref) {
  return ref.watch(measurementListProvider).whenData(
        (rows) => rows
            .where((r) => r.weight != null)
            .map((r) => WeightPoint(date: r.date, kg: r.weight!))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)),
      );
});

/// Конвертирует список замеров → `WaistPoint[]` для анализа тренда талии.
final waistPointsProvider = Provider<AsyncValue<List<WaistPoint>>>((ref) {
  return ref.watch(measurementListProvider).whenData(
        (rows) => rows
            .where((r) => r.waist != null)
            .map((r) => WaistPoint(date: r.date, cm: r.waist!))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)),
      );
});

/// Результат анализа тренда веса (7-дневная скользящая средняя, скорость,
/// plateau detection). `null` — нет данных (провайдер ещё грузится).
final weightTrendProvider = Provider<WeightTrendResult?>((ref) {
  final async = ref.watch(weightPointsProvider);
  return async.valueOrNull != null
      ? analyzeWeightTrend(points: async.valueOrNull!)
      : null;
});

/// Результат анализа тренда талии (см/нед, belt notches).
final waistTrendProvider = Provider<WaistTrendResult?>((ref) {
  final async = ref.watch(waistPointsProvider);
  return async.valueOrNull != null
      ? analyzeWaistTrend(points: async.valueOrNull!)
      : null;
});

/// Сводный прогресс-снимок (тренд + талия + adherence + insights).
///
/// Для расчёта adherence считаем дни с хоть каким-то замером.
/// [totalDays] = 30 дней для rolling monthly view.
final progressSnapshotProvider = Provider<ProgressSnapshot?>((ref) {
  final wAsync = ref.watch(weightPointsProvider);
  final waistAsync = ref.watch(waistPointsProvider);

  final wPts = wAsync.valueOrNull;
  final waistPts = waistAsync.valueOrNull;

  if (wPts == null || waistPts == null) return null;

  const windowDays = 30;
  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: windowDays));

  final recentWPts = wPts.where((p) => p.date.isAfter(cutoff)).toList();
  final recentWaistPts =
      waistPts.where((p) => p.date.isAfter(cutoff)).toList();

  // Считаем залогированные дни по объединённому набору дат замеров.
  final loggedDates = {
    ...recentWPts.map((p) =>
        DateTime(p.date.year, p.date.month, p.date.day)),
    ...recentWaistPts.map((p) =>
        DateTime(p.date.year, p.date.month, p.date.day)),
  };

  return buildProgressSnapshot(
    weightPoints: recentWPts,
    waistPoints: recentWaistPts,
    loggedDays: loggedDates.length,
    totalDays: windowDays,
  );
});

/// Сохранённая запись `DailyCompliances` за сегодня (реактивный стрим).
/// null = запись ещё не создана на сегодня.
final todayComplianceRecordProvider =
    StreamProvider<DailyCompliancesData?>((ref) {
  return ref.watch(dailyComplianceDaoProvider).watchToday();
});

/// Compliance Score за сегодня.
///
/// Если в `DailyCompliances` уже есть запись — возвращает её score напрямую
/// (check-in был сделан). Иначе считает динамически: замер веса + гидратация
/// из `MeasurementLogs`.
final todayComplianceProvider = Provider<double>((ref) {
  final saved = ref.watch(todayComplianceRecordProvider).valueOrNull;
  if (saved != null) return saved.score;

  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  final rows = ref.watch(measurementListProvider).valueOrNull ?? [];

  final hasWeightToday = rows.any((r) {
    final d = r.date;
    return DateTime(d.year, d.month, d.day) == todayStart &&
        r.weight != null;
  });

  final todayRow = rows
      .where((r) {
        final d = r.date;
        return DateTime(d.year, d.month, d.day) == todayStart;
      })
      .toList();

  final waterMl = todayRow.isNotEmpty
      ? todayRow.first.hydrationMl?.toDouble()
      : null;

  return computeComplianceScore(
    input: DailyComplianceInput(
      weightLogged: hasWeightToday,
      waterMl: waterMl,
    ),
  ).score;
});
