import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/rpg/domain/level_calculator.dart';

final rpgTotalXpProvider = FutureProvider<int>(
  (ref) => ref.watch(rpgDaoProvider).getTotalXp(),
);

final rpgLevelInfoProvider = FutureProvider<LevelInfo>((ref) async {
  final xp = await ref.watch(rpgTotalXpProvider.future);
  return computeLevel(xp);
});

final rpgAchievementsProvider = StreamProvider<List<AchievementsData>>(
  (ref) => ref.watch(rpgDaoProvider).watchAchievements(),
);

final rpgXpByTypeProvider = FutureProvider<Map<int, int>>(
  (ref) => ref.watch(rpgDaoProvider).getXpByType(),
);
