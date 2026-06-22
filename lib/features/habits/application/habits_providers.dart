import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';

final habitsListProvider = StreamProvider<List<HabitsData>>(
  (ref) => ref.watch(habitsDaoProvider).watchAll(),
);

final activeHabitsProvider = StreamProvider<List<HabitsData>>(
  (ref) => ref.watch(habitsDaoProvider).watchActive(),
);

final habitCompletedTodayProvider =
    FutureProvider.family<bool, String>((ref, habitId) {
  return ref.watch(habitsDaoProvider).isCompletedToday(habitId);
});

final habitLast7DaysProvider =
    FutureProvider.family<List<bool>, String>((ref, habitId) {
  return ref.watch(habitsDaoProvider).getLast7DaysCompleted(habitId);
});

typedef HabitsTodaySummary = ({int completed, int total, int maxStreak});

/// Today's completion count, total active habits, and highest stored streak.
final habitsTodaySummaryProvider =
    FutureProvider.autoDispose<HabitsTodaySummary>((ref) async {
  final dao = ref.watch(habitsDaoProvider);
  final habits = await dao.watchActive().first;
  if (habits.isEmpty) return (completed: 0, total: 0, maxStreak: 0);

  final completedResults =
      await Future.wait(habits.map((h) => dao.isCompletedToday(h.id)));
  final completed = completedResults.where((done) => done).length;
  final maxStreak = habits.fold<int>(0, (m, h) => h.streak > m ? h.streak : m);

  return (completed: completed, total: habits.length, maxStreak: maxStreak);
});
