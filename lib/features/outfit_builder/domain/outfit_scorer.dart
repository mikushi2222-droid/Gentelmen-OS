import 'package:gentleman_os/features/outfit_builder/domain/color_harmony.dart';
import 'package:gentleman_os/features/outfit_builder/domain/fit_rules.dart';
import 'package:gentleman_os/features/outfit_builder/domain/occasion_rules.dart';
import 'package:gentleman_os/features/outfit_builder/domain/weather_rules.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/enums/weather_condition.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/outfit.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

/// Главная функция оценки образа.
/// Чистая функция — тривиально тестируется.
OutfitScore scoreOutfit({
  required List<ClothingItem> items,
  required UserProfileModel profile,
  required Occasion occasion,
  required DressCode dressCode,
  required Season season,
  WeatherCondition? weather,
  int? temperatureC,
}) {
  if (items.isEmpty) {
    return const OutfitScore(
      explanation: ['Образ пуст'],
    );
  }

  final allNotes = <String>[];

  // --- Ось 1: посадка (fit) ---
  final fitResults = items.map((i) => fitScore(i, profile));
  final avgFit =
      fitResults.map((r) => r.score).reduce((a, b) => a + b) / items.length;
  for (final r in fitResults) {
    allNotes.addAll(r.notes);
  }

  // --- Ось 2: цветовая гармония ---
  final colorResult = colorHarmonyScore(
    items.map((i) => i.color).toList(),
    profile.colorPreferences,
  );
  allNotes.addAll(colorResult.notes);

  // --- Ось 3: повод ---
  final occasionResult = occasionScore(items, occasion, dressCode);
  allNotes.addAll(occasionResult.notes);

  // --- Ось 4: погода/сезон ---
  final weatherResult = weatherScore(items, weather, temperatureC, season);
  allNotes.addAll(weatherResult.notes);

  // --- Ось 5: комфорт ---
  final comfortResult = _comfortScore(items, profile);
  allNotes.addAll(comfortResult.notes);

  return OutfitScore(
    fitScore: avgFit,
    colorScore: colorResult.score,
    occasionScore: occasionResult.score,
    weatherScore: weatherResult.score,
    comfortScore: comfortResult.score,
    explanation: allNotes,
  );
}

({double score, List<String> notes}) _comfortScore(
  List<ClothingItem> items,
  UserProfileModel profile,
) {
  final notes = <String>[];
  var score = 0.6;

  final ratings = items.where((i) => i.rating != null).toList();
  if (ratings.isNotEmpty) {
    final avg = ratings.map((i) => i.rating!).reduce((a, b) => a + b) /
        ratings.length;
    final bonus = (avg - 3) * 0.1; // 1..5 → [-0.2, +0.2]
    score += bonus;
    notes.add(
      'Средний рейтинг удобства: ${avg.toStringAsFixed(1)}/5 '
      '${bonus >= 0 ? "(+)" : "(−)"}',
    );
  }

  final shinyCnt = items.where((i) => i.isShinyOrThin).length;
  if (shinyCnt > 0 && profile.isLargeFrame) {
    score -= 0.1 * shinyCnt;
    notes.add('Тонкие/блестящие материалы снижают комфорт (−)');
  }

  return (score: score.clamp(0.0, 1.0), notes: notes);
}
