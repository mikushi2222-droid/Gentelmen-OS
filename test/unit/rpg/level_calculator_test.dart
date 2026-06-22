import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/rpg/domain/level_calculator.dart';

void main() {
  group('computeLevel', () {
    test('0 XP → уровень 1, прогресс 0', () {
      final info = computeLevel(0);
      expect(info.level, 1);
      expect(info.totalXp, 0);
      expect(info.progress, 0.0);
    });

    test('достаточно XP для уровня 2', () {
      // xpForLevel(1) = 100 * 1^1.5 = 100
      final info = computeLevel(100);
      expect(info.level, 2);
    });

    test('прогресс внутри уровня корректен', () {
      // На уровне 1 нужно 100 XP. При 50 XP прогресс = 0.5
      final info = computeLevel(50);
      expect(info.level, 1);
      expect(info.progress, closeTo(0.5, 0.01));
    });

    test('total всегда >= 0 и progress в [0,1]', () {
      for (final xp in [0, 1, 50, 99, 100, 500, 1000, 9999]) {
        final info = computeLevel(xp);
        expect(info.level, greaterThanOrEqualTo(1));
        expect(info.progress, inInclusiveRange(0.0, 1.0));
      }
    });

    test('уровни монотонно возрастают с XP', () {
      final levels = [0, 10, 100, 200, 500, 1000, 5000]
          .map(computeLevel)
          .map((i) => i.level)
          .toList();
      for (var i = 1; i < levels.length; i++) {
        expect(levels[i], greaterThanOrEqualTo(levels[i - 1]));
      }
    });
  });

  group('computeGentlemanScore', () {
    test('максимальная активность → 100', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 50,
        fitnessXpLast7d: 50,
        habitsCompleted: 7,
        habitsTotal: 7,
        articlesReadLast7d: 3,
        healthXpLast7d: 30,
      );
      expect(score, closeTo(100, 1));
    });

    test('нулевая активность → 0', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 0,
        fitnessXpLast7d: 0,
        habitsCompleted: 0,
        habitsTotal: 0,
        articlesReadLast7d: 0,
      );
      expect(score, 0.0);
    });

    test('результат всегда в [0, 100]', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 1000,
        fitnessXpLast7d: 1000,
        habitsCompleted: 100,
        habitsTotal: 7,
        articlesReadLast7d: 100,
      );
      expect(score, inInclusiveRange(0.0, 100.0));
    });

    test('только привычки (вес 30%) → score ≈ 30', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 0,
        fitnessXpLast7d: 0,
        habitsCompleted: 7,
        habitsTotal: 7,
        articlesReadLast7d: 0,
        healthXpLast7d: 0,
      );
      expect(score, closeTo(30.0, 0.01));
    });

    test('только чтение (вес 10%, максимум при 3 статьях) → score ≈ 10', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 0,
        fitnessXpLast7d: 0,
        habitsCompleted: 0,
        habitsTotal: 0,
        articlesReadLast7d: 3,
        healthXpLast7d: 0,
      );
      expect(score, closeTo(10.0, 0.01));
    });

    test('только здоровье (вес 10%, максимум при 30 XP) → score ≈ 10', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 0,
        fitnessXpLast7d: 0,
        habitsCompleted: 0,
        habitsTotal: 0,
        articlesReadLast7d: 0,
        healthXpLast7d: 30,
      );
      expect(score, closeTo(10.0, 0.01));
    });

    test('только стиль (вес 25%, максимум при 50 XP) → score ≈ 25', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 50,
        fitnessXpLast7d: 0,
        habitsCompleted: 0,
        habitsTotal: 0,
        articlesReadLast7d: 0,
        healthXpLast7d: 0,
      );
      expect(score, closeTo(25.0, 0.01));
    });

    test('только фитнес (вес 25%, максимум при 50 XP) → score ≈ 25', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 0,
        fitnessXpLast7d: 50,
        habitsCompleted: 0,
        habitsTotal: 0,
        articlesReadLast7d: 0,
        healthXpLast7d: 0,
      );
      expect(score, closeTo(25.0, 0.01));
    });

    test('нет привычек (habitsTotal == 0) → habitsC == 0, нет ошибки', () {
      final score = computeGentlemanScore(
        styleXpLast7d: 50,
        fitnessXpLast7d: 50,
        habitsCompleted: 0,
        habitsTotal: 0,
        articlesReadLast7d: 0,
        healthXpLast7d: 0,
      );
      // style(0.25) + fitness(0.25) = 0.50 → 50
      expect(score, closeTo(50.0, 0.01));
    });
  });
}
