import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/outfit_builder/domain/outfit_generator.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

ClothingItem _item(String id, ClothingCategory cat, {String? color}) =>
    ClothingItem(
      id: id,
      name: 'Item $id',
      category: cat,
      color: color,
      createdAt: DateTime(2024),
    );

final _profile = UserProfileModel(updatedAt: DateTime(2024));

List<OutfitSuggestion> _generate(
  List<ClothingItem> wardrobe, {
  Occasion occasion = Occasion.everyday,
  DressCode dressCode = DressCode.casual,
  Season season = Season.all,
  int max = 3,
}) =>
    generateOutfits(
      wardrobe: wardrobe,
      profile: _profile,
      occasion: occasion,
      dressCode: dressCode,
      season: season,
      maxSuggestions: max,
    );

void main() {
  final shirt = _item('s1', ClothingCategory.shirt, color: 'white');
  final polo = _item('s2', ClothingCategory.polo, color: 'navy');
  final trousers = _item('b1', ClothingCategory.trousers, color: 'grey');
  final jeans = _item('b2', ClothingCategory.jeans, color: 'dark blue');
  final shoes = _item('sh1', ClothingCategory.shoes, color: 'brown');
  final blazer = _item('l1', ClothingCategory.blazer, color: 'navy');

  group('generateOutfits', () {
    test('пустой гардероб → пустой список', () {
      expect(_generate([]), isEmpty);
    });

    test('только верх без низа → пустой список', () {
      expect(_generate([shirt]), isEmpty);
    });

    test('только низ без верха → пустой список', () {
      expect(_generate([trousers]), isEmpty);
    });

    test('минимальный гардероб (верх + низ) → 1 образ', () {
      final result = _generate([shirt, trousers]);
      expect(result, isNotEmpty);
      expect(result.first.items, hasLength(2));
    });

    test('не превышает maxSuggestions', () {
      final wardrobe = [shirt, polo, trousers, jeans, shoes, blazer];
      final result = _generate(wardrobe, max: 2);
      expect(result.length, lessThanOrEqualTo(2));
    });

    test('каждый образ содержит верх и низ', () {
      final result = _generate([shirt, polo, trousers, jeans, shoes]);
      for (final s in result) {
        final hasTop = s.items.any((i) => i.category.isTop);
        final hasBottom = s.items.any((i) => i.category.isBottom);
        expect(hasTop, isTrue, reason: 'Образ без верха: ${s.items.map((i) => i.id)}');
        expect(hasBottom, isTrue, reason: 'Образ без низа: ${s.items.map((i) => i.id)}');
      }
    });

    test('score каждого образа в [0, 100]', () {
      final result = _generate([shirt, polo, trousers, jeans, shoes, blazer]);
      for (final s in result) {
        expect(s.score.totalScaled, inInclusiveRange(0.0, 100.0));
      }
    });

    test('недоступные вещи не включаются', () {
      final unavailable = ClothingItem(
        id: 'unavail',
        name: 'Unavailable',
        category: ClothingCategory.shirt,
        isAvailable: false,
        createdAt: DateTime(2024),
      );
      final result = _generate([unavailable, trousers]);
      expect(result, isEmpty);
    });

    test('образы разнообразны (разные верха)', () {
      final wardrobe = [shirt, polo, trousers, shoes];
      final result = _generate(wardrobe, max: 3);
      final topIds = result
          .map((s) => s.items.firstWhere((i) => i.category.isTop).id)
          .toSet();
      expect(topIds.length, greaterThanOrEqualTo(1));
    });

    test('результаты отсортированы по убыванию score', () {
      final result = _generate([shirt, polo, trousers, jeans, shoes, blazer]);
      for (var i = 1; i < result.length; i++) {
        expect(
          result[i - 1].score.total,
          greaterThanOrEqualTo(result[i].score.total - 0.001),
        );
      }
    });
  });
}
