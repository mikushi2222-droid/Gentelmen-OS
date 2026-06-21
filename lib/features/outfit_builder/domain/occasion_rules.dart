import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

({double score, List<String> notes}) occasionScore(
  List<ClothingItem> items,
  Occasion occasion,
  DressCode dressCode,
) {
  final notes = <String>[];
  var score = 0.5;

  final avgFormality = _avgFormality(items);
  final targetFormality = _targetFormality(occasion, dressCode);
  final diff = (avgFormality - targetFormality).abs();

  if (diff == 0) {
    score += 0.4;
    notes.add('Образ точно соответствует поводу (+)');
  } else if (diff == 1) {
    score += 0.2;
    notes.add('Образ близок к поводу (+)');
  } else if (diff == 2) {
    // приемлемо
    notes.add('Небольшое несоответствие поводу');
  } else {
    score -= 0.3;
    notes.add('Образ не соответствует поводу (${occasion.label}) (−)');
  }

  // Кроссовки на формальном — жёсткий штраф
  if (occasion.formalityLevel >= 4) {
    final hasShoes = items.any((i) => i.category == ClothingCategory.shoes);
    final hasSneakers = items.any(
      (i) =>
          i.category == ClothingCategory.shoes &&
          (i.name.toLowerCase().contains('кроссовк') ||
              i.name.toLowerCase().contains('sneaker')),
    );
    if (hasSneakers) {
      score -= 0.3;
      notes.add('Кроссовки недопустимы для делового/официального повода (−)');
    }
    if (!hasShoes) {
      notes.add('Для делового повода рекомендуется добавить туфли');
    }
  }

  return (score: score.clamp(0.0, 1.0), notes: notes);
}

double _avgFormality(List<ClothingItem> items) {
  if (items.isEmpty) return 0;
  return items.map(_itemFormality).reduce((a, b) => a + b) / items.length;
}

double _itemFormality(ClothingItem item) => switch (item.category) {
      ClothingCategory.coat => 3,
      ClothingCategory.blazer => 4,
      ClothingCategory.jacket => 2,
      ClothingCategory.shirt => 3,
      ClothingCategory.trousers => 3,
      ClothingCategory.polo => 2,
      ClothingCategory.jeans => 1.5,
      ClothingCategory.tShirt => 1,
      ClothingCategory.shoes => 3,
      ClothingCategory.accessory => 2,
    };

double _targetFormality(Occasion occasion, DressCode dressCode) {
  // Средневзвешенное из повода и дресс-кода
  final fromOccasion = occasion.formalityLevel.toDouble();
  final fromDressCode = dressCode.level.toDouble();
  return (fromOccasion + fromDressCode) / 2;
}
