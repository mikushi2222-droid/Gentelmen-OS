import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

ClothingItem _item({
  String material = '',
  double? price,
  int wearCount = 0,
  ClothingCategory category = ClothingCategory.shirt,
}) =>
    ClothingItem(
      id: 'test',
      name: 'Test',
      category: category,
      material: material.isEmpty ? null : material,
      price: price,
      wearCount: wearCount,
      createdAt: DateTime(2024),
    );

void main() {
  group('ClothingItem.costPerWear', () {
    test('null при отсутствии цены', () {
      expect(_item(wearCount: 5).costPerWear, isNull);
    });

    test('null при нулевом количестве надеваний', () {
      expect(_item(price: 3000, wearCount: 0).costPerWear, isNull);
    });

    test('корректно считает cost-per-wear', () {
      final item = _item(price: 3000, wearCount: 10);
      expect(item.costPerWear, closeTo(300.0, 0.01));
    });

    test('дробное значение при нечётном делении', () {
      final item = _item(price: 1000, wearCount: 3);
      expect(item.costPerWear, closeTo(333.33, 0.1));
    });
  });

  group('ClothingItem.isShinyOrThin', () {
    test('false при натуральном материале', () {
      expect(_item(material: 'cotton').isShinyOrThin, isFalse);
      expect(_item(material: 'шерсть').isShinyOrThin, isFalse);
    });

    test('true для polyester', () {
      expect(_item(material: 'polyester').isShinyOrThin, isTrue);
      expect(_item(material: 'Polyester 100%').isShinyOrThin, isTrue);
    });

    test('true для полиэстер (ru)', () {
      expect(_item(material: '100% полиэстер').isShinyOrThin, isTrue);
    });

    test('true для nylon', () {
      expect(_item(material: 'nylon blend').isShinyOrThin, isTrue);
    });

    test('true для нейлон (ru)', () {
      expect(_item(material: 'нейлон').isShinyOrThin, isTrue);
    });

    test('true для satin', () {
      expect(_item(material: 'satin').isShinyOrThin, isTrue);
    });

    test('true для атлас (ru)', () {
      expect(_item(material: 'атлас').isShinyOrThin, isTrue);
    });

    test('false при пустом материале', () {
      expect(_item(material: '').isShinyOrThin, isFalse);
    });

    test('false при null материале', () {
      final item = ClothingItem(
        id: 'x',
        name: 'X',
        category: ClothingCategory.shirt,
        createdAt: DateTime(2024),
      );
      expect(item.isShinyOrThin, isFalse);
    });
  });

  group('ClothingCategory helpers', () {
    test('isTop для рубашки, поло, футболки', () {
      expect(ClothingCategory.shirt.isTop, isTrue);
      expect(ClothingCategory.polo.isTop, isTrue);
      expect(ClothingCategory.tShirt.isTop, isTrue);
      expect(ClothingCategory.blazer.isTop, isFalse);
      expect(ClothingCategory.shoes.isTop, isFalse);
    });

    test('isBottom для брюк и джинсов', () {
      expect(ClothingCategory.trousers.isBottom, isTrue);
      expect(ClothingCategory.jeans.isBottom, isTrue);
      expect(ClothingCategory.shirt.isBottom, isFalse);
    });

    test('isLayer для верхней одежды', () {
      expect(ClothingCategory.blazer.isLayer, isTrue);
      expect(ClothingCategory.jacket.isLayer, isTrue);
      expect(ClothingCategory.coat.isLayer, isTrue);
      expect(ClothingCategory.tShirt.isLayer, isFalse);
    });

    test('label не пустой для всех категорий', () {
      for (final cat in ClothingCategory.values) {
        expect(cat.label, isNotEmpty, reason: '${cat.name} должна иметь label');
      }
    });
  });
}
