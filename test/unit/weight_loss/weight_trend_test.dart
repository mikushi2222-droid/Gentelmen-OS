import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/weight_loss/domain/weight_trend.dart';

List<WeightPoint> _points(List<(int dayOffset, double kg)> data) => data
    .map((e) => WeightPoint(
          date: DateTime(2026, 1, 1).add(Duration(days: e.$1)),
          kg: e.$2,
        ))
    .toList();

void main() {
  group('analyzeWeightTrend — insufficient data', () {
    test('пустой список → insufficient', () {
      final r = analyzeWeightTrend(points: []);
      expect(r.status, WeightTrendStatus.insufficient);
      expect(r.weeklyRatekgPerWeek, 0);
      expect(r.movingAverage, isEmpty);
    });

    test('один замер → insufficient', () {
      final r = analyzeWeightTrend(
        points: [const WeightPoint(date: DateTime.utc(2026, 1, 1), kg: 100)],
      );
      expect(r.status, WeightTrendStatus.insufficient);
    });

    test('два замера в один день → insufficient', () {
      final r = analyzeWeightTrend(
        points: [
          const WeightPoint(date: DateTime.utc(2026, 1, 1), kg: 100),
          const WeightPoint(date: DateTime.utc(2026, 1, 1), kg: 99),
        ],
      );
      expect(r.status, WeightTrendStatus.insufficient);
    });
  });

  group('analyzeWeightTrend — скорость снижения', () {
    test('-0.6 кг/нед → optimal', () {
      // -6 кг за 10 недель = -0.6 кг/нед
      final pts = _points([(0, 100.0), (70, 94.0)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.status, WeightTrendStatus.optimal);
      expect(r.weeklyRatekgPerWeek, closeTo(-0.6, 0.01));
    });

    test('-1.5 кг/нед → aggressive', () {
      // -6 кг за 4 недели = -1.5 кг/нед
      final pts = _points([(0, 100.0), (28, 94.0)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.status, WeightTrendStatus.aggressive);
      expect(r.weeklyRatekgPerWeek, closeTo(-1.5, 0.01));
    });

    test('набор веса (+0.2 кг/нед) → plateau', () {
      final pts = _points([(0, 95.0), (7, 95.2)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.status, WeightTrendStatus.plateau);
      expect(r.weeklyRatekgPerWeek, greaterThan(0));
    });

    test('медленное снижение -0.1 кг/нед → plateau (ниже порога 0.3)', () {
      final pts = _points([(0, 100.0), (70, 99.0)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.status, WeightTrendStatus.plateau);
    });
  });

  group('analyzeWeightTrend — граничные значения порогов', () {
    test('-0.3 кг/нед точно → plateau (нужно строго меньше)', () {
      // -0.3 кг/нед: не проходит порог optimal (rate > -0.3 → plateau)
      final pts = _points([(0, 100.0), (7, 99.7)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.status, WeightTrendStatus.plateau);
    });

    test('-0.31 кг/нед → optimal', () {
      final pts = _points([(0, 100.0), (100, 95.57)]); // ≈ -0.31 кг/нед
      final r = analyzeWeightTrend(points: pts);
      expect(r.status, WeightTrendStatus.optimal);
    });

    test('-1.0 кг/нед точно → optimal (нужно строго больше 1.0 для aggressive)', () {
      final pts = _points([(0, 100.0), (7, 99.0)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.status, WeightTrendStatus.optimal);
    });

    test('-1.01 кг/нед → aggressive', () {
      final pts = _points([(0, 100.0), (7, 98.99)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.status, WeightTrendStatus.aggressive);
    });
  });

  group('analyzeWeightTrend — plateau detection', () {
    test('14 дней без снижения (< 0.2 кг) → plateau status', () {
      // Начало 100 кг, через 14 дней 99.9 кг (delta=-0.1 < порог 0.2)
      final pts = _points([(0, 100.0), (7, 99.95), (14, 99.9)]);
      final r = analyzeWeightTrend(points: pts, plateauThresholdDays: 14);
      expect(r.status, WeightTrendStatus.plateau);
      expect(r.plateauDays, greaterThanOrEqualTo(14));
    });

    test('plateauDays == 0 при хорошем снижении', () {
      final pts = _points([(0, 100.0), (7, 99.0), (14, 98.0)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.plateauDays, 0);
    });
  });

  group('analyzeWeightTrend — movingAverage', () {
    test('средняя по 2 точкам за 7 дней', () {
      final pts = _points([(0, 100.0), (6, 98.0)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.movingAverage, isNotEmpty);
      expect(r.movingAverage.last, closeTo(99.0, 0.1));
    });

    test('одна точка в окне → её же значение', () {
      final pts = _points([(0, 95.5), (20, 94.0)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.movingAverage.first, closeTo(95.5, 0.01));
    });
  });

  group('analyzeWeightTrend — explanation', () {
    test('объяснение содержит ключевые данные', () {
      final pts = _points([(0, 100.0), (14, 98.0)]);
      final r = analyzeWeightTrend(points: pts);
      expect(r.explanation.any((s) => s.contains('замеров')), isTrue);
      expect(r.explanation.any((s) => s.contains('кг/нед')), isTrue);
    });
  });

  group('WeightTrendStatusX.message', () {
    test('все статусы имеют непустое сообщение', () {
      for (final s in WeightTrendStatus.values) {
        expect(s.message, isNotEmpty);
      }
    });

    test('plateau содержит "Plateau"', () {
      expect(WeightTrendStatus.plateau.message, contains('Plateau'));
    });

    test('optimal содержит "optimal"', () {
      expect(WeightTrendStatus.optimal.message, contains('optimal'));
    });
  });
}
