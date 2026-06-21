import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/services/achievement_service.dart';
import 'package:gentleman_os/core/services/xp_service.dart';

export 'package:gentleman_os/core/services/xp_service.dart';
export 'package:gentleman_os/core/services/achievement_service.dart';

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService(
    rpgDao: ref.watch(rpgDaoProvider),
    wardrobeDao: ref.watch(wardrobeDaoProvider),
    outfitDao: ref.watch(outfitDaoProvider),
    knowledgeDao: ref.watch(knowledgeDaoProvider),
    habitsDao: ref.watch(habitsDaoProvider),
  );
});
