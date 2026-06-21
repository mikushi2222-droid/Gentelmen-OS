import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

void main() {
  group('UserProfileModel', () {
    test('BMI корректен при нормальных значениях', () {
      final p = UserProfileModel(
        height: 180,
        weight: 80,
        updatedAt: DateTime(2024),
      );
      // 80 / (1.8 * 1.8) ≈ 24.69
      expect(p.bmi, isNotNull);
      expect(p.bmi!, closeTo(24.69, 0.1));
    });

    test('BMI null при нулевом росте', () {
      final p = UserProfileModel(
        height: 0,
        weight: 80,
        updatedAt: DateTime(2024),
      );
      expect(p.bmi, isNull);
    });

    test('BMI null при нулевом весе', () {
      final p = UserProfileModel(
        height: 180,
        weight: 0,
        updatedAt: DateTime(2024),
      );
      expect(p.bmi, isNull);
    });

    test('bmiCategory — Норма при ИМТ 22', () {
      final p = UserProfileModel(
        height: 180,
        weight: 71,
        updatedAt: DateTime(2024),
      );
      expect(p.bmiCategory, 'Норма');
    });

    test('bmiCategory — Избыток веса при ИМТ 27', () {
      final p = UserProfileModel(
        height: 175,
        weight: 82,
        updatedAt: DateTime(2024),
      );
      // 82 / (1.75 * 1.75) ≈ 26.78
      expect(p.bmiCategory, 'Избыток веса');
    });

    test('bmiCategory пуст при незаполненных данных', () {
      final p = UserProfileModel(updatedAt: DateTime(2024));
      expect(p.bmiCategory, '');
    });

    test('isLargeFrame при талии >= 100', () {
      final p = UserProfileModel(
        waist: 100,
        updatedAt: DateTime(2024),
      );
      expect(p.isLargeFrame, isTrue);
    });

    test('isLargeFrame при весе >= 100', () {
      final p = UserProfileModel(
        weight: 100,
        updatedAt: DateTime(2024),
      );
      expect(p.isLargeFrame, isTrue);
    });

    test('isLargeFrame false для стандартных параметров', () {
      final p = UserProfileModel(
        weight: 80,
        waist: 90,
        updatedAt: DateTime(2024),
      );
      expect(p.isLargeFrame, isFalse);
    });

    test('isFilled требует рост и вес', () {
      expect(
        UserProfileModel(
          height: 180,
          weight: 80,
          updatedAt: DateTime(2024),
        ).isFilled,
        isTrue,
      );
      expect(
        UserProfileModel(
          height: 180,
          updatedAt: DateTime(2024),
        ).isFilled,
        isFalse,
      );
      expect(
        UserProfileModel(updatedAt: DateTime(2024)).isFilled,
        isFalse,
      );
    });
  });
}
