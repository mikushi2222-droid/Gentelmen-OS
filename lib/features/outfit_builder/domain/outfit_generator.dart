import 'package:gentleman_os/features/outfit_builder/domain/outfit_scorer.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/enums/weather_condition.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/outfit.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

class OutfitSuggestion {
  const OutfitSuggestion({required this.items, required this.score});
  final List<ClothingItem> items;
  final OutfitScore score;
}

/// Генерирует топ-3 образа из доступного гардероба.
List<OutfitSuggestion> generateOutfits({
  required List<ClothingItem> wardrobe,
  required UserProfileModel profile,
  required Occasion occasion,
  required DressCode dressCode,
  required Season season,
  WeatherCondition? weather,
  int? temperatureC,
  int maxSuggestions = 3,
}) {
  final available = wardrobe.where((i) => i.isAvailable).toList();

  final tops =
      available.where((i) => i.category.isTop).toList();
  final bottoms =
      available.where((i) => i.category.isBottom).toList();
  final layers =
      available.where((i) => i.category.isLayer).toList();
  final shoes =
      available.where((i) => i.category == ClothingCategory.shoes).toList();

  if (tops.isEmpty || bottoms.isEmpty) return [];

  final candidates = <OutfitSuggestion>[];

  // Генерируем комбинации: top + bottom + optional layer + optional shoes
  for (final top in tops) {
    for (final bottom in bottoms) {
      final base = [top, bottom];

      // Вариант без слоя и без обуви
      _addCandidate(
        candidates,
        base,
        profile,
        occasion,
        dressCode,
        season,
        weather,
        temperatureC,
      );

      // С обувью
      for (final shoe in shoes) {
        _addCandidate(
          candidates,
          [...base, shoe],
          profile,
          occasion,
          dressCode,
          season,
          weather,
          temperatureC,
        );

        // С обувью и слоем
        for (final layer in layers) {
          _addCandidate(
            candidates,
            [...base, shoe, layer],
            profile,
            occasion,
            dressCode,
            season,
            weather,
            temperatureC,
          );
        }
      }

      // Лимит перебора — защита от O(n^4)
      if (candidates.length > 200) break;
    }
    if (candidates.length > 200) break;
  }

  // Сортируем по score и берём разнообразные топ-N
  candidates.sort((a, b) => b.score.total.compareTo(a.score.total));
  return _diversify(candidates, maxSuggestions);
}

void _addCandidate(
  List<OutfitSuggestion> out,
  List<ClothingItem> items,
  UserProfileModel profile,
  Occasion occasion,
  DressCode dressCode,
  Season season,
  WeatherCondition? weather,
  int? temperatureC,
) {
  final score = scoreOutfit(
    items: items,
    profile: profile,
    occasion: occasion,
    dressCode: dressCode,
    season: season,
    weather: weather,
    temperatureC: temperatureC,
  );
  out.add(OutfitSuggestion(items: items, score: score));
}

/// Возвращает N образов с разными «верхами» (разнообразие).
List<OutfitSuggestion> _diversify(
  List<OutfitSuggestion> sorted,
  int n,
) {
  final result = <OutfitSuggestion>[];
  final usedTopIds = <String>{};

  for (final s in sorted) {
    if (result.length >= n) break;
    final topId = s.items
        .where((i) => i.category.isTop)
        .map((i) => i.id)
        .firstOrNull;
    if (topId == null || !usedTopIds.contains(topId)) {
      result.add(s);
      if (topId != null) usedTopIds.add(topId);
    }
  }

  // Если разнообразных не хватило — добавляем оставшиеся лучшие
  if (result.length < n) {
    for (final s in sorted) {
      if (result.length >= n) break;
      if (!result.contains(s)) result.add(s);
    }
  }

  return result;
}
