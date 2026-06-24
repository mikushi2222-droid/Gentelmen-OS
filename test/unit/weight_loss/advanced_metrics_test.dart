import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/weight_loss/domain/advanced_metrics.dart';
import 'package:gentleman_os/features/weight_loss/domain/weight_trend.dart';

List<WeightPoint> _wpts(List<(int day, double kg)> data) => data
    .map((e) => WeightPoint(
          date: DateTime(2026, 1, 1).add(Duration(days: e.$1)),
          kg: e.$2,
        ))
    .toList();

List<WaistPoint> _waistPts(List<(int day, double cm)> data) => data
    .map((e) => WaistPoint(
          date: DateTime(2026, 1, 1).add(Duration(days: e.$1)),
          cm: e.$2,
        ))
    .toList();

void main() {
  group('analyzeWaistTrend — insufficient', () {
    test('пустой список → нулевые значения', () {
      final r = analyzeWaistTrend(points: []);
      expect(r.weeklyRateCmPerWeek, 0);
      expect(r.totalDeltaCm, 0);
      expect(r.beltNotchesRecovered, 0);
    });

    test('один замер → нулевые значения', () {
      final r = analyzeWaistTrend(
        points: [const WaistPoint(date: DateTime.utc(2026, 1, 1), cm: 110)],
      );
      expect(r.totalDeltaCm, 0);
    });
  });

  group('analyzeWaistTrend — снижение', () {
    test('-4 см за 28 дней → -1 см/нед', () {
      final pts = _waistPts([(0, 110.0), (28, 106.0)]);
      final r = analyzeWaistTrend(points: pts);
      expect(r.weeklyRateCmPerWeek, closeTo(-1.0, 0.01));
      expect(r.totalDeltaCm, closeTo(-4.0, 0.01));
    });

    test('2 дырки ремня при снижении на 4 см', () {
      final pts = _waistPts([(0, 110.0), (28, 106.0)]);
      final r = analyzeWaistTrend(points: pts);
      expect(r.beltNotchesRecovered, 2);
    });

    test('1 дырка при снижении на 3 см (floor от 1.5)', () {
      final pts = _waistPts([(0, 100.0), (14, 97.0)]);
      final r = analyzeWaistTrend(points: pts);
      expect(r.beltNotchesRecovered, 1);
    });

    test('0 дырок при наборе талии', () {
      final pts = _waistPts([(0, 100.0), (14, 102.0)]);
      final r = analyzeWaistTrend(points: pts);
      expect(r.beltNotchesRecovered, 0);
    });

    test('пользовательский cmPerBeltNotch = 3', () {
      // -6 см / 3 = 2 дырки
      final pts = _waistPts([(0, 110.0), (28, 104.0)]);
      final r = analyzeWaistTrend(points: pts, cmPerBeltNotch: 3);
      expect(r.beltNotchesRecovered, 2);
    });
  });

  group('analyzeWaistTrend — explanation', () {
    test('содержит ключевые данные', () {
      final pts = _waistPts([(0, 110.0), (14, 108.0)]);
      final r = analyzeWaistTrend(points: pts);
      expect(r.explanation.any((s) => s.contains('замеров')), isTrue);
      expect(r.explanation.any((s) => s.contains('см')), isTrue);
    });

    test('belt notch line появляется при восстановлении', () {
      final pts = _waistPts([(0, 110.0), (14, 107.0)]);
      final r = analyzeWaistTrend(points: pts);
      expect(r.beltNotchesRecovered, 1);
      expect(r.explanation.any((s) => s.toLowerCase().contains('belt')), isTrue);
    });
  });

  group('estimateFatLossFraction', () {
    test('baseline без белка и тренировок → 0.65', () {
      expect(
        estimateFatLossFraction(weightLostKg: 5, proteinAdequate: false),
        closeTo(0.65, 0.001),
      );
    });

    test('с белком → 0.77', () {
      expect(
        estimateFatLossFraction(
            weightLostKg: 5, proteinAdequate: true, trainingActive: false),
        closeTo(0.77, 0.001),
      );
    });

    test('с белком и тренировками → 0.85', () {
      expect(
        estimateFatLossFraction(
            weightLostKg: 5, proteinAdequate: true, trainingActive: true),
        closeTo(0.85, 0.001),
      );
    });

    test('нулевые или отрицательные потери → 0', () {
      expect(estimateFatLossFraction(weightLostKg: 0), 0.0);
      expect(estimateFatLossFraction(weightLostKg: -1), 0.0);
    });

    test('результат в диапазоне [0, 1]', () {
      final f = estimateFatLossFraction(
        weightLostKg: 10,
        proteinAdequate: true,
        trainingActive: true,
      );
      expect(f, inInclusiveRange(0.0, 1.0));
    });
  });

  group('adherenceScore', () {
    test('0 дней → 0', () {
      expect(adherenceScore(loggedDays: 0, totalDays: 0), 0.0);
    });

    test('5 из 7 дней → 0.714', () {
      expect(
        adherenceScore(loggedDays: 5, totalDays: 7),
        closeTo(5 / 7, 0.001),
      );
    });

    test('все дни залогированы → 1.0', () {
      expect(adherenceScore(loggedDays: 30, totalDays: 30), 1.0);
    });

    test('больше залогированных чем дней → clamp to 1.0', () {
      expect(adherenceScore(loggedDays: 10, totalDays: 7), 1.0);
    });
  });

  group('buildProgressSnapshot', () {
    test('plateau + waist improving → recomposition insight', () {
      // Вес стоит (plateau), талия снижается
      final wPts = _wpts([(0, 100.0), (7, 99.9), (14, 99.8)]);
      final waistPts = _waistPts([(0, 110.0), (7, 109.0), (14, 108.0)]);

      final snap = buildProgressSnapshot(
        weightPoints: wPts,
        waistPoints: waistPts,
        loggedDays: 14,
        totalDays: 14,
      );

      expect(snap.insights.any((s) => s.contains('recomposition')), isTrue);
    });

    test('высокая adherence → insight об этом', () {
      final snap = buildProgressSnapshot(
        weightPoints: _wpts([(0, 100.0), (7, 99.0)]),
        waistPoints: _waistPts([(0, 110.0), (7, 109.5)]),
        loggedDays: 7,
        totalDays: 7,
      );
      expect(
          snap.insights.any((s) => s.toLowerCase().contains('consistency')),
          isTrue);
    });

    test('низкая adherence → предупреждение', () {
      final snap = buildProgressSnapshot(
        weightPoints: _wpts([(0, 100.0), (14, 99.0)]),
        waistPoints: [],
        loggedDays: 3,
        totalDays: 14,
      );
      expect(snap.insights.any((s) => s.contains('Resume')), isTrue);
    });

    test('weightDeltaKg и waistDeltaCm вычисляются корректно', () {
      final snap = buildProgressSnapshot(
        weightPoints: _wpts([(0, 100.0), (14, 97.0)]),
        waistPoints: _waistPts([(0, 110.0), (14, 108.0)]),
        loggedDays: 10,
        totalDays: 14,
      );
      expect(snap.weightDeltaKg, closeTo(-3.0, 0.01));
      expect(snap.waistDeltaCm, closeTo(-2.0, 0.01));
    });

    test('без замеров — нет краша', () {
      final snap = buildProgressSnapshot(
        weightPoints: [],
        waistPoints: [],
        loggedDays: 0,
        totalDays: 7,
      );
      expect(snap.weightDeltaKg, 0);
      expect(snap.beltNotchesRecovered, 0);
    });
  });
}
