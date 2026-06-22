import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/settings/domain/export_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    profileDao: ref.watch(profileDaoProvider),
    wardrobeDao: ref.watch(wardrobeDaoProvider),
    outfitDao: ref.watch(outfitDaoProvider),
    measurementDao: ref.watch(measurementDaoProvider),
    knowledgeDao: ref.watch(knowledgeDaoProvider),
    habitsDao: ref.watch(habitsDaoProvider),
    rpgDao: ref.watch(rpgDaoProvider),
    purchasesDao: ref.watch(purchasesDaoProvider),
    healthDao: ref.watch(healthDaoProvider),
  );
});

final clearAllDataProvider = Provider<Future<void> Function()>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return () async {
    await db.transaction(() async {
      await db.delete(db.clothingItems).go();
      await db.delete(db.outfits).go();
      await db.delete(db.outfitItems).go();
      await db.delete(db.wearLogs).go();
      await db.delete(db.measurementLogs).go();
      await db.delete(db.habits).go();
      await db.delete(db.habitLogs).go();
      await db.delete(db.xpEvents).go();
      await db.delete(db.purchaseWishes).go();
      await db.delete(db.dailyMissions).go();
      await db.delete(db.healthMarkers).go();
      // Reset achievements to unlocked=false
      await (db.update(db.achievements)).write(
        const AchievementsCompanion(
          unlocked: Value(false),
          unlockedAt: Value(null),
        ),
      );
    });
  };
});
