import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/rpg/application/rpg_providers.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/features/rpg/domain/level_calculator.dart';
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
  for (final e in recentEvents) {
    if (e.type == XpType.style.index) styleXp += e.amount;
    if (e.type == XpType.fitness.index) fitnessXp += e.amount;
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
    articlesReadLast7d: 0,
  );
});
