import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/outfit_builder/domain/fit_rules.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/fit.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

ClothingItem _makeItem({
  Fit fit = Fit.regular,
  ClothingCategory category = ClothingCategory.shirt,
  String? material,
}) =>
    ClothingItem(
      id: 'test',
      name: 'Test',
      category: category,
      fit: fit,
      material: material,
      createdAt: DateTime(2024),
    );

UserProfileModel _largeProfile() => UserProfileModel(
      waist: 120,
      weight: 110,
      updatedAt: DateTime(2024),
    );

UserProfileModel _normalProfile() => UserProfileModel(
      waist: 80,
      weight: 75,
      updatedAt: DateTime(2024),
    );

void main() {
  group('fitScore — крупная фигура', () {
    test('slim fit → штраф', () {
      final result = fitScore(_makeItem(fit: Fit.slim), _largeProfile());
      expect(result.score, lessThan(0.5));
      expect(result.notes, isNotEmpty);
    });

    test('regular fit → бонус', () {
      final result = fitScore(_makeItem(fit: Fit.regular), _largeProfile());
      expect(result.score, greaterThan(0.6));
    });

    test('comfort fit → бонус', () {
      final result = fitScore(_makeItem(fit: Fit.comfort), _largeProfile());
      expect(result.score, greaterThan(0.6));
    });

    test('тонкая/блестящая ткань → штраф', () {
      final item = _makeItem(material: 'polyester glossy');
      final result = fitScore(item, _largeProfile());
      expect(result.notes, anyElement(contains('блестящ')));
    });

    test('score всегда в [0, 1]', () {
      for (final fit in Fit.values) {
        final result = fitScore(_makeItem(fit: fit), _largeProfile());
        expect(result.score, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('fitScore — нормальная фигура', () {
    test('slim fit без штрафа', () {
      final result = fitScore(_makeItem(fit: Fit.slim), _normalProfile());
      // нет штрафа за slim при нормальной фигуре
      expect(result.score, greaterThanOrEqualTo(0.5));
    });
  });
}
