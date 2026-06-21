import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/outfit_builder/domain/color_harmony.dart';

void main() {
  group('colorHarmonyScore', () {
    test('пустые цвета → нейтральная оценка 0.6', () {
      final r = colorHarmonyScore([], []);
      expect(r.score, closeTo(0.6, 0.01));
    });

    test('все null цвета → нейтральная оценка 0.6', () {
      final r = colorHarmonyScore([null, null], []);
      expect(r.score, closeTo(0.6, 0.01));
    });

    test('полностью нейтральная палитра → score выше 0.7', () {
      final r = colorHarmonyScore(['navy', 'grey', 'white'], []);
      expect(r.score, greaterThan(0.7));
      expect(r.notes, anyElement(contains('нейтральн')));
    });

    test('нейтраль + 1 акцент → score выше 0.7', () {
      final r = colorHarmonyScore(['navy', 'bright red'], []);
      expect(r.score, greaterThan(0.7));
    });

    test('несколько акцентов → штраф', () {
      final r = colorHarmonyScore(['bright red', 'electric blue', 'yellow'], []);
      expect(r.score, lessThan(0.6));
      expect(r.notes, anyElement(contains('рискованно')));
    });

    test('любимый цвет → бонус', () {
      final without = colorHarmonyScore(['navy', 'grey'], []);
      final with_ = colorHarmonyScore(['navy', 'grey'], ['navy']);
      expect(with_.score, greaterThan(without.score));
    });

    test('score всегда в [0, 1]', () {
      final cases = [
        colorHarmonyScore([], []),
        colorHarmonyScore(['red', 'blue', 'green', 'yellow'], []),
        colorHarmonyScore(['white', 'beige', 'cream'], ['white']),
      ];
      for (final r in cases) {
        expect(r.score, inInclusiveRange(0.0, 1.0));
      }
    });

    test('notes непустые при ненулевых цветах', () {
      final r = colorHarmonyScore(['navy', 'white'], []);
      expect(r.notes, isNotEmpty);
    });

    test('регистронезависимость — Navy = navy', () {
      final lower = colorHarmonyScore(['navy'], []);
      final upper = colorHarmonyScore(['Navy'], []);
      expect(lower.score, closeTo(upper.score, 0.01));
    });
  });
}
