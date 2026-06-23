import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/biohacking/domain/optimization.dart';

void main() {
  group('optimizationScore', () {
    test('пустой список → 0', () {
      expect(optimizationScore(const []), 0);
    });

    test('равные веса → среднее в процентах', () {
      final domains = [
        const OptimizationDomain(name: 'Сон', score: 0.8),
        const OptimizationDomain(name: 'Стресс', score: 0.6),
        const OptimizationDomain(name: 'Вес', score: 0.4),
      ];
      // (0.8 + 0.6 + 0.4) / 3 = 0.6 → 60
      expect(optimizationScore(domains), 60);
    });

    test('учитывает веса', () {
      final domains = [
        const OptimizationDomain(name: 'A', score: 1.0, weight: 3),
        const OptimizationDomain(name: 'B', score: 0.0, weight: 1),
      ];
      // (1*3 + 0*1) / 4 = 0.75 → 75
      expect(optimizationScore(domains), 75);
    });

    test('нулевые веса → 0 (без деления на ноль)', () {
      final domains = [
        const OptimizationDomain(name: 'A', score: 1, weight: 0),
      ];
      expect(optimizationScore(domains), 0);
    });

    test('результат всегда в [0, 100]', () {
      final domains = [
        const OptimizationDomain(name: 'A', score: 5, weight: 1),
      ];
      expect(optimizationScore(domains), inInclusiveRange(0, 100));
    });
  });

  group('bottlenecks', () {
    test('сортирует по убыванию потенциала прироста', () {
      final domains = [
        const OptimizationDomain(name: 'Сон', score: 0.78),
        const OptimizationDomain(name: 'Стресс', score: 0.65),
        const OptimizationDomain(name: 'Вес', score: 0.54),
      ];
      final result = bottlenecks(domains);
      // у «Вес» самый большой gap (1-0.54)
      expect(result.first.name, 'Вес');
      expect(result.last.name, 'Сон');
    });

    test('не мутирует исходный список', () {
      final domains = [
        const OptimizationDomain(name: 'A', score: 0.9),
        const OptimizationDomain(name: 'B', score: 0.1),
      ];
      bottlenecks(domains);
      expect(domains.first.name, 'A');
    });
  });

  group('maxImpactActions', () {
    test('возвращает топ-N по узким местам', () {
      final domains = [
        const OptimizationDomain(name: 'Сон', score: 0.78),
        const OptimizationDomain(name: 'Стресс', score: 0.65),
        const OptimizationDomain(name: 'Вес', score: 0.54),
      ];
      final actions = maxImpactActions(domains, top: 2);
      expect(actions.length, 2);
      expect(actions.first.title, contains('Вес'));
      expect(actions.first.impactPercent, greaterThan(0));
      expect(actions.first.reason, isNotEmpty);
    });

    test('reason отражает ранг узкого места', () {
      final domains = [
        const OptimizationDomain(name: 'Сон', score: 0.78),
        const OptimizationDomain(name: 'Стресс', score: 0.65),
        const OptimizationDomain(name: 'Вес', score: 0.54),
      ];
      final actions = maxImpactActions(domains, top: 3);
      // Первое — главное узкое место; последующие помечены рангом.
      expect(actions.first.reason, contains('главное'));
      expect(actions[1].reason, isNot(contains('главное')));
      expect(actions[1].reason, contains('#2'));
      expect(actions[2].reason, contains('#3'));
    });

    test('пропускает домены без разрыва (score=1)', () {
      final domains = [
        const OptimizationDomain(name: 'Идеал', score: 1.0),
      ];
      expect(maxImpactActions(domains), isEmpty);
    });

    test('пустой вход → пусто', () {
      expect(maxImpactActions(const []), isEmpty);
    });
  });
}
