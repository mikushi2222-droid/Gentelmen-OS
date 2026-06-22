import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/biohacking/domain/optimization.dart';
import 'package:gentleman_os/shared/enums/xp_type.dart';

/// Домены оптимизации, выведенные из реально отслеживаемой активности
/// (офлайн, объяснимо). По мере появления данных по сну/стрессу домены
/// расширим в следующих фазах (см. docs/16, V2.2+).
final biohackingDomainsProvider =
    FutureProvider<List<OptimizationDomain>>((ref) async {
  final rpgDao = ref.watch(rpgDaoProvider);
  final habitsDao = ref.watch(habitsDaoProvider);

  final since7d = DateTime.now().subtract(const Duration(days: 7));
  final events = await rpgDao.getXpEventsSince(since7d);

  var styleXp = 0;
  var fitnessXp = 0;
  var reading = 0;
  for (final e in events) {
    if (e.type == XpType.style.index) styleXp += e.amount;
    if (e.type == XpType.fitness.index) fitnessXp += e.amount;
    if (e.type == XpType.reading.index) reading++;
  }

  final habits = await habitsDao.watchAll().first;
  final completedIds = await habitsDao.completedHabitIdsOn(DateTime.now());
  final completedToday =
      habits.where((h) => completedIds.contains(h.id)).length;

  double norm(num value, num target) =>
      target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);

  final discipline =
      habits.isEmpty ? 0.5 : completedToday / habits.length;

  return [
    OptimizationDomain(
        name: 'Тело и активность', score: norm(fitnessXp, 100), weight: 1.2),
    OptimizationDomain(name: 'Дисциплина', score: discipline, weight: 1.0),
    OptimizationDomain(name: 'Стиль', score: norm(styleXp, 100), weight: 0.8),
    OptimizationDomain(name: 'Развитие', score: norm(reading, 3), weight: 0.6),
  ];
});
