import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/outfit_builder/domain/outfit_scorer.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/fit.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

ClothingItem _item({
  required String id,
  required ClothingCategory cat,
  Fit fit = Fit.regular,
  String? color,
}) =>
    ClothingItem(
      id: id,
      name: 'Item $id',
      category: cat,
      fit: fit,
      color: color,
      createdAt: DateTime(2024),
    );

void main() {
  final profile = UserProfileModel(
    waist: 120,
    weight: 110,
    colorPreferences: ['navy'],
    updatedAt: DateTime(2024),
  );

  final shirt = _item(id: '1', cat: ClothingCategory.shirt, color: 'white');
  final trousers = _item(id: '2', cat: ClothingCategory.trousers, color: 'navy');
  final shoes = _item(id: '3', cat: ClothingCategory.shoes, color: 'brown');

  test('пустой образ → score = OutfitScore() без краша', () {
    final score = scoreOutfit(
      items: [],
      profile: profile,
      occasion: Occasion.everyday,
      dressCode: DressCode.casual,
      season: Season.all,
    );
    expect(score.totalScaled, 0);
    expect(score.explanation, isNotEmpty);
  });

  test('total всегда в [0, 100]', () {
    final score = scoreOutfit(
      items: [shirt, trousers, shoes],
      profile: profile,
      occasion: Occasion.everyday,
      dressCode: DressCode.casual,
      season: Season.all,
    );
    expect(score.totalScaled, inInclusiveRange(0.0, 100.0));
  });

  test('explanation непустой при любом образе', () {
    final score = scoreOutfit(
      items: [shirt, trousers],
      profile: profile,
      occasion: Occasion.work,
      dressCode: DressCode.businessCasual,
      season: Season.autumn,
    );
    expect(score.explanation, isNotEmpty);
  });

  test('нейтральные цвета → colorScore выше', () {
    final neutralItem = _item(
      id: 'n',
      cat: ClothingCategory.shirt,
      color: 'white',
    );
    final loudItem = _item(
      id: 'l',
      cat: ClothingCategory.shirt,
      color: 'bright red',
    );

    final neutral = scoreOutfit(
      items: [neutralItem, trousers],
      profile: profile,
      occasion: Occasion.everyday,
      dressCode: DressCode.casual,
      season: Season.all,
    );

    final loud = scoreOutfit(
      items: [loudItem, trousers],
      profile: profile,
      occasion: Occasion.everyday,
      dressCode: DressCode.casual,
      season: Season.all,
    );

    expect(neutral.colorScore, greaterThanOrEqualTo(loud.colorScore));
  });
}
