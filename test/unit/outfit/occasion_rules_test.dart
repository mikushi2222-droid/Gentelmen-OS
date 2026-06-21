import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/outfit_builder/domain/occasion_rules.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

ClothingItem _item(ClothingCategory cat, {String name = 'Item'}) => ClothingItem(
      id: cat.name,
      name: name,
      category: cat,
      createdAt: DateTime(2024),
    );

void main() {
  group('occasionScore', () {
    test('score в [0, 1] для любых входных данных', () {
      final cases = [
        ([_item(ClothingCategory.shirt), _item(ClothingCategory.trousers)],
            Occasion.work, DressCode.businessCasual),
        ([_item(ClothingCategory.tShirt), _item(ClothingCategory.jeans)],
            Occasion.formal, DressCode.blackTie),
        ([], Occasion.everyday, DressCode.casual),
      ];
      for (final c in cases) {
        final r = occasionScore(c.$1, c.$2, c.$3);
        expect(r.score, inInclusiveRange(0.0, 1.0),
            reason: 'Случай: ${c.$2} / ${c.$3}');
      }
    });

    test('блейзер + брюки → хорошо для business', () {
      final items = [
        _item(ClothingCategory.blazer),
        _item(ClothingCategory.trousers),
        _item(ClothingCategory.shirt),
      ];
      final r = occasionScore(items, Occasion.business, DressCode.business);
      expect(r.score, greaterThan(0.5));
    });

    test('футболка + джинсы → плохо для formal', () {
      final items = [
        _item(ClothingCategory.tShirt),
        _item(ClothingCategory.jeans),
      ];
      final r = occasionScore(items, Occasion.formal, DressCode.blackTie);
      expect(r.score, lessThan(0.5));
    });

    test('кроссовки на формальном → штраф', () {
      final items = [
        _item(ClothingCategory.shirt),
        _item(ClothingCategory.trousers),
        ClothingItem(
          id: 'sneakers',
          name: 'кроссовки белые',
          category: ClothingCategory.shoes,
          createdAt: DateTime(2024),
        ),
      ];
      final formal = occasionScore(items, Occasion.business, DressCode.business);
      final casual = occasionScore(
        [_item(ClothingCategory.shirt), _item(ClothingCategory.trousers),
         _item(ClothingCategory.shoes)],
        Occasion.everyday,
        DressCode.casual,
      );
      expect(formal.notes, anyElement(contains('кроссовки')));
    });

    test('пустой список → score не null', () {
      final r = occasionScore([], Occasion.everyday, DressCode.casual);
      expect(r.score, isNotNull);
    });

    test('notes непустые при ненулевом списке', () {
      final r = occasionScore(
        [_item(ClothingCategory.shirt), _item(ClothingCategory.trousers)],
        Occasion.work,
        DressCode.businessCasual,
      );
      expect(r.notes, isNotEmpty);
    });
  });
}
