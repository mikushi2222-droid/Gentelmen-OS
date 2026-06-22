import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/health/domain/biological_age.dart';

void main() {
  group('biologicalAge', () {
    test('хороший образ жизни омолаживает (39 → 34)', () {
      final r = biologicalAge(
        chronologicalAge: 39,
        factors: const [
          BioAgeFactor(label: 'Талия в норме', deltaYears: -2),
          BioAgeFactor(label: 'Хороший сон', deltaYears: -2),
          BioAgeFactor(label: 'Активность', deltaYears: -1),
        ],
      );
      expect(r.years, 34);
    });

    test('плохие факторы старят', () {
      final r = biologicalAge(
        chronologicalAge: 30,
        factors: const [BioAgeFactor(label: 'Недосып', deltaYears: 5)],
      );
      expect(r.years, 35);
    });

    test('ограничение диапазоном [18, 100]', () {
      final low = biologicalAge(
        chronologicalAge: 20,
        factors: const [BioAgeFactor(label: 'X', deltaYears: -50)],
      );
      expect(low.years, 18);
    });

    test('объяснение включает хронологический возраст и факторы', () {
      final r = biologicalAge(
        chronologicalAge: 40,
        factors: const [BioAgeFactor(label: 'Талия', deltaYears: 1.5)],
      );
      expect(r.explanation.first, contains('40'));
      expect(r.explanation.any((e) => e.contains('Талия')), isTrue);
    });
  });
}
