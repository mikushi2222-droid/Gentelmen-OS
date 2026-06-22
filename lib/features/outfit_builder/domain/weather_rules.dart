import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/enums/weather_condition.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

({double score, List<String> notes}) weatherScore(
  List<ClothingItem> items,
  WeatherCondition? weather,
  int? temperatureC,
  Season targetSeason,
) {
  final notes = <String>[];
  var score = 0.6;

  // Сезонность вещей
  final wrongSeason = items.where(
    (i) => i.season != Season.all && i.season != targetSeason,
  );
  if (wrongSeason.isNotEmpty) {
    score -= 0.2 * wrongSeason.length / items.length;
    notes.add(
      'Несезонные вещи в образе: ${wrongSeason.map((i) => i.name).join(', ')} (−)',
    );
  } else {
    score += 0.2;
    notes.add('Все вещи соответствуют сезону (+)');
  }

  // Температура (если задана)
  if (temperatureC != null) {
    score += _temperatureBonus(items, temperatureC, notes);
  }

  // Погодные условия
  if (weather != null) {
    score += _weatherBonus(items, weather, notes);
  }

  return (score: score.clamp(0.0, 1.0), notes: notes);
}

double _temperatureBonus(
  List<ClothingItem> items,
  int temp,
  List<String> notes,
) {
  if (temp < 5) {
    final hasCoat = items.any(
      (i) =>
          i.category.name == 'coat' ||
          i.category.name == 'jacket',
    );
    if (!hasCoat) {
      notes.add('При температуре $temp°C рекомендуется верхняя одежда (−)');
      return -0.15;
    }
    notes.add('Верхний слой присутствует для холодной погоды (+)');
    return 0.1;
  }
  if (temp > 25) {
    final hasHeavy = items.any(
      (i) =>
          i.material != null &&
          (i.material!.toLowerCase().contains('wool') ||
              i.material!.toLowerCase().contains('шерсть')),
    );
    if (hasHeavy) {
      notes.add('Шерстяные вещи при жаре ($temp°C) неуместны (−)');
      return -0.1;
    }
  }
  return 0.0;
}

double _weatherBonus(
  List<ClothingItem> items,
  WeatherCondition weather,
  List<String> notes,
) {
  if (weather == WeatherCondition.rain || weather == WeatherCondition.snow) {
    final hasProtection = items.any(
      (i) =>
          i.category.name == 'coat' ||
          i.category.name == 'jacket' ||
          (i.material != null &&
              (i.material!.toLowerCase().contains('wool') ||
                  i.material!.toLowerCase().contains('шерсть'))),
    );
    if (!hasProtection) {
      notes.add('При осадках рекомендуется защитный слой (−)');
      return -0.1;
    }
    notes.add('Защитный слой есть — хорошо для погоды (+)');
    return 0.05;
  }
  return 0.0;
}
