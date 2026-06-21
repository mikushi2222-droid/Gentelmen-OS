import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/daos/outfit_dao.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/services/xp_service.dart';
import 'package:gentleman_os/features/outfit_builder/domain/outfit_generator.dart';
import 'package:gentleman_os/features/profile/application/profile_providers.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/enums/weather_condition.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class OutfitParams {
  const OutfitParams({
    required this.occasion,
    required this.dressCode,
    required this.season,
    this.weather,
    this.temperatureC,
  });

  final Occasion occasion;
  final DressCode dressCode;
  final Season season;
  final WeatherCondition? weather;
  final int? temperatureC;
}

final outfitSuggestionsProvider =
    FutureProvider.family<List<OutfitSuggestion>, OutfitParams>(
  (ref, params) async {
    final wardrobe = await ref.watch(wardrobeListProvider.future);
    final profile =
        await ref.watch(profileProvider.future) ??
        UserProfileModel(updatedAt: DateTime.now());

    return generateOutfits(
      wardrobe: wardrobe,
      profile: profile,
      occasion: params.occasion,
      dressCode: params.dressCode,
      season: params.season,
      weather: params.weather,
      temperatureC: params.temperatureC,
    );
  },
);

final savedOutfitsProvider = StreamProvider<List<OutfitsData>>(
  (ref) => ref.watch(outfitDaoProvider).watchAll(),
);

Future<void> saveOutfitSuggestion({
  required OutfitSuggestion suggestion,
  required String name,
  required OutfitParams params,
  required OutfitDao dao,
  XpService? xpService,
}) async {
  final id = const Uuid().v4();
  final score = suggestion.score;

  await dao.saveOutfit(
    OutfitsCompanion(
      id: Value(id),
      name: Value(name),
      occasion: Value(params.occasion.index),
      weather: Value(params.weather?.index),
      temperatureC: Value(params.temperatureC),
      dressCode: Value(params.dressCode.index),
      season: Value(params.season.index),
      score: Value(score.totalScaled),
      createdAt: Value(DateTime.now()),
    ),
    suggestion.items.map((i) => i.id).toList(),
  );
  await xpService?.outfitSaved();
}
