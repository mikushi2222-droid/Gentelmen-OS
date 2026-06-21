import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/dashboard/domain/mission_generator.dart';
import 'package:gentleman_os/features/rpg/application/rpg_providers.dart';
import 'package:gentleman_os/features/rpg/domain/level_calculator.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/shared/enums/xp_type.dart';

final wardrobeCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(wardrobeListProvider).whenData((items) => items.length);
});

final gentlemanScoreProvider = FutureProvider<double>((ref) async {
  final dao = ref.watch(rpgDaoProvider);
  final habitsDao = ref.watch(habitsDaoProvider);

  final since7d = DateTime.now().subtract(const Duration(days: 7));
  final recentEvents = await dao.getXpEventsSince(since7d);

  int styleXp = 0;
  int fitnessXp = 0;
  int readingActions = 0;
  for (final e in recentEvents) {
    if (e.type == XpType.style.index) styleXp += e.amount;
    if (e.type == XpType.fitness.index) fitnessXp += e.amount;
    if (e.type == XpType.reading.index) readingActions++;
  }

  final habits = await habitsDao.watchAll().first;
  var completedToday = 0;
  for (final h in habits) {
    if (await habitsDao.isCompletedToday(h.id)) completedToday++;
  }

  return computeGentlemanScore(
    styleXpLast7d: styleXp,
    fitnessXpLast7d: fitnessXp,
    habitsCompleted: completedToday,
    habitsTotal: habits.length,
    articlesReadLast7d: readingActions,
  );
});

/// Ensures today's missions exist in DB, then streams them.
final dailyMissionsProvider =
    StreamProvider<List<DailyMissionsData>>((ref) async* {
  final dao = ref.watch(dailyMissionsDaoProvider);
  final measurementDao = ref.watch(measurementDaoProvider);
  final knowledgeDao = ref.watch(knowledgeDaoProvider);
  final outfitDao = ref.watch(outfitDaoProvider);
  final wardrobeCount = ref.watch(wardrobeCountProvider).valueOrNull ?? 0;

  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);

  // Seed today's missions if DB has none yet
  final existing = await dao.getForDate(today);
  if (existing.isEmpty) {
    final latest = await measurementDao.getLatest();
    final hasMeasurementToday =
        latest != null && !latest.date.isBefore(startOfDay);

    final outfits = await outfitDao.watchAll().first;
    final hasOutfitToday =
        outfits.any((o) => !o.createdAt.isBefore(startOfDay));

    final articlesReadToday = await knowledgeDao.countReadSince(startOfDay);

    final missions = generateDailyMissions(
      date: today,
      hasMeasurementToday: hasMeasurementToday,
      hasOutfitToday: hasOutfitToday,
      wardrobeCount: wardrobeCount,
      articlesRead: articlesReadToday,
    );
    for (final m in missions) {
      await dao.upsertMission(m);
    }
  }

  yield* dao.watchForDate(today);
});
