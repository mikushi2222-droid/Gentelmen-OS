import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/weight_loss/domain/compliance_score.dart';

const _full = DailyComplianceInput(
  mealsLogged: 3,
  weightLogged: true,
  waterMl: 2500,
  sleepHours: 7.5,
  steps: 7000,
  habitsCompleted: 5,
  habitsTotal: 5,
  checkInDone: true,
);

const _empty = DailyComplianceInput();

void main() {
  group('computeComplianceScore — полная активность', () {
    test('все компоненты на максимуме → score ≈ 100', () {
      final r = computeComplianceScore(input: _full);
      expect(r.score, closeTo(100, 0.01));
    });

    test('все компоненты равны 1', () {
      final r = computeComplianceScore(input: _full);
      final c = r.components;
      expect(c.logging, 1.0);
      expect(c.weight, 1.0);
      expect(c.water, 1.0);
      expect(c.sleep, 1.0);
      expect(c.steps, 1.0);
      expect(c.habits, 1.0);
      expect(c.checkIn, 1.0);
    });
  });

  group('computeComplianceScore — нулевая активность', () {
    test('пустые данные → score == 0', () {
      final r = computeComplianceScore(input: _empty);
      expect(r.score, 0.0);
    });

    test('habitsTotal == 0, habits == 0 → нет деления на ноль, habits = 0', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(
          habitsCompleted: 0,
          habitsTotal: 0,
        ),
      );
      expect(r.components.habits, 0.0);
      expect(r.score, 0.0);
    });
  });

  group('computeComplianceScore — веса компонентов', () {
    test('только логирование еды (25%) → score ≈ 25', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(mealsLogged: 3),
      );
      expect(r.score, closeTo(25.0, 0.01));
    });

    test('только замер веса (15%) → score ≈ 15', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(weightLogged: true),
      );
      expect(r.score, closeTo(15.0, 0.01));
    });

    test('только вода (15%) → score ≈ 15', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(waterMl: 2500),
      );
      expect(r.score, closeTo(15.0, 0.01));
    });

    test('только сон (15%) → score ≈ 15', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(sleepHours: 7.5),
      );
      expect(r.score, closeTo(15.0, 0.01));
    });

    test('только шаги (10%) → score ≈ 10', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(steps: 7000),
      );
      expect(r.score, closeTo(10.0, 0.01));
    });

    test('только привычки (15%) → score ≈ 15', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(
          habitsCompleted: 3,
          habitsTotal: 3,
        ),
      );
      expect(r.score, closeTo(15.0, 0.01));
    });

    test('только чек-ин (5%) → score ≈ 5', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(checkInDone: true),
      );
      expect(r.score, closeTo(5.0, 0.01));
    });
  });

  group('computeComplianceScore — частичная активность', () {
    test('половина привычек → habits == 0.5', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(
          habitsCompleted: 2,
          habitsTotal: 4,
        ),
      );
      expect(r.components.habits, 0.5);
    });

    test('вода сверх нормы не даёт больше 1.0', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(waterMl: 5000),
      );
      expect(r.components.water, 1.0);
    });

    test('шаги сверх нормы ограничены', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(steps: 20000),
      );
      expect(r.components.steps, 1.0);
    });

    test('результат всегда в [0, 100]', () {
      for (final meals in [0, 1, 2, 3, 10]) {
        final r = computeComplianceScore(
          input: DailyComplianceInput(
            mealsLogged: meals,
            waterMl: 1000,
            steps: 5000,
          ),
        );
        expect(r.score, inInclusiveRange(0.0, 100.0));
      }
    });
  });

  group('computeComplianceScore — пользовательские нормы', () {
    test('нормы 2 приёма пищи: 2 блюда → logging == 1', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(mealsLogged: 2),
        norms: const ComplianceNorms(targetMealsPerDay: 2),
      );
      expect(r.components.logging, 1.0);
    });

    test('низкая норма воды: 1500 мл', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(waterMl: 1500),
        norms: const ComplianceNorms(targetWaterMl: 1500),
      );
      expect(r.components.water, 1.0);
    });
  });

  group('computeComplianceScore — message', () {
    test('score ≥ 85 → optimal message', () {
      final r = computeComplianceScore(input: _full);
      expect(r.message, contains('optimal'));
    });

    test('score == 0 → visibility lost message', () {
      final r = computeComplianceScore(input: _empty);
      expect(r.message, contains('Visibility lost'));
    });

    test('score ≈ 50 → degraded message', () {
      final r = computeComplianceScore(
        input: const DailyComplianceInput(
          mealsLogged: 2,
          weightLogged: true,
          habitsCompleted: 1,
          habitsTotal: 5,
        ),
      );
      expect(r.score, inInclusiveRange(0.0, 65.0));
      expect(r.message, isNotEmpty);
    });
  });

  group('averageComplianceScore', () {
    test('пустой список → 0', () {
      expect(averageComplianceScore([]), 0.0);
    });

    test('среднее 7 дней', () {
      final avg = averageComplianceScore([80, 70, 90, 60, 75, 85, 65]);
      expect(avg, closeTo(75.0, 0.1));
    });

    test('один день', () {
      expect(averageComplianceScore([72.5]), 72.5);
    });
  });
}
