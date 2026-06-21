import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/daos/daily_missions_dao.dart';
import 'package:gentleman_os/core/db/daos/habits_dao.dart';
import 'package:gentleman_os/core/db/daos/health_dao.dart';
import 'package:gentleman_os/core/db/daos/knowledge_dao.dart';
import 'package:gentleman_os/core/db/daos/measurement_dao.dart';
import 'package:gentleman_os/core/db/daos/outfit_dao.dart';
import 'package:gentleman_os/core/db/daos/profile_dao.dart';
import 'package:gentleman_os/core/db/daos/purchases_dao.dart';
import 'package:gentleman_os/core/db/daos/rpg_dao.dart';
import 'package:gentleman_os/core/db/daos/wardrobe_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override appDatabaseProvider in main.dart');
});

final profileDaoProvider = Provider<ProfileDao>(
  (ref) => ref.watch(appDatabaseProvider).profileDao,
);

final wardrobeDaoProvider = Provider<WardrobeDao>(
  (ref) => ref.watch(appDatabaseProvider).wardrobeDao,
);

final outfitDaoProvider = Provider<OutfitDao>(
  (ref) => ref.watch(appDatabaseProvider).outfitDao,
);

final measurementDaoProvider = Provider<MeasurementDao>(
  (ref) => ref.watch(appDatabaseProvider).measurementDao,
);

final knowledgeDaoProvider = Provider<KnowledgeDao>(
  (ref) => ref.watch(appDatabaseProvider).knowledgeDao,
);

final habitsDaoProvider = Provider<HabitsDao>(
  (ref) => ref.watch(appDatabaseProvider).habitsDao,
);

final rpgDaoProvider = Provider<RpgDao>(
  (ref) => ref.watch(appDatabaseProvider).rpgDao,
);

final purchasesDaoProvider = Provider<PurchasesDao>(
  (ref) => ref.watch(appDatabaseProvider).purchasesDao,
);

final dailyMissionsDaoProvider = Provider<DailyMissionsDao>(
  (ref) => ref.watch(appDatabaseProvider).dailyMissionsDao,
);

final healthDaoProvider = Provider<HealthDao>(
  (ref) => ref.watch(appDatabaseProvider).healthDao,
);
