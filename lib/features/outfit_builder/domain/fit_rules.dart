import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/fit.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

/// Правила посадки под фигуру пользователя.
/// Источник философии: Roetzel «Der Gentleman» + Boyer.
/// Основной принцип: структура, пропорциональность, комфорт.
({double score, List<String> notes}) fitScore(
  ClothingItem item,
  UserProfileModel profile,
) {
  var score = 0.6;
  final notes = <String>[];

  if (profile.isLargeFrame) {
    score += _largeFrameRules(item, notes);
  }

  // Личные ограничения пользователя
  final material = item.material?.toLowerCase() ?? '';
  for (final r in profile.restrictions) {
    if (material.contains(r.toLowerCase()) ||
        item.name.toLowerCase().contains(r.toLowerCase())) {
      score -= 0.3;
      notes.add('Нежелательный материал/тип: $r (−)');
    }
  }

  return (score: score.clamp(0.0, 1.0), notes: notes);
}

double _largeFrameRules(ClothingItem item, List<String> notes) {
  var delta = 0.0;

  // Посадка
  switch (item.fit) {
    case Fit.slim:
      delta -= 0.35;
      notes.add('Slim fit не подходит крупной фигуре (−)');
    case Fit.regular:
      delta += 0.25;
      notes.add('Regular fit: хорошо структурирует фигуру (+)');
    case Fit.straight:
      delta += 0.20;
      notes.add('Straight fit: пропорциональный крой (+)');
    case Fit.comfort:
      delta += 0.15;
      notes.add('Comfort fit: хорошая посадка для крупной фигуры (+)');
    case Fit.relaxed:
      delta += 0.05;
      notes.add('Relaxed fit: допустимо, но следите за пропорциями');
  }

  // Тонкие/блестящие ткани — акцентируют объём
  if (item.isShinyOrThin) {
    delta -= 0.20;
    notes.add('Тонкая/блестящая ткань нежелательна для крупной фигуры (−)');
  }

  // Брюки: только намёк на посадку через категорию (rise нет в модели)
  if (item.category == ClothingCategory.trousers ||
      item.category == ClothingCategory.jeans) {
    delta += 0.10;
    notes.add('Брюки/джинсы: предпочтительна средняя/высокая посадка (+)');
  }

  return delta;
}
