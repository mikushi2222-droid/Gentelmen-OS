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
typedef HabitWithCompletion = ({HabitsData habit, bool doneToday});

/// Active habits with today's completion status (for dashboard quick-check).
final activeHabitsWithCompletionProvider =
    FutureProvider.autoDispose<List<HabitWithCompletion>>((ref) async {
  final dao = ref.watch(habitsDaoProvider);
  final habits = await dao.watchActive().first;
  if (habits.isEmpty) return [];
  final done = await Future.wait(habits.map((h) => dao.isCompletedToday(h.id)));
  return [
    for (var i = 0; i < habits.length; i++)
      (habit: habits[i], doneToday: done[i]),
  ];
});

/// Today's completion count, total active habits, and highest stored streak.
final habitsTodaySummaryProvider =
    FutureProvider.autoDispose<HabitsTodaySummary>((ref) async {
  final list = await ref.watch(activeHabitsWithCompletionProvider.future);
  if (list.isEmpty) return (completed: 0, total: 0, maxStreak: 0);
  final completed = list.where((e) => e.doneToday).length;
  final maxStreak =
      list.fold<int>(0, (m, e) => e.habit.streak > m ? e.habit.streak : m);
  return (completed: completed, total: list.length, maxStreak: maxStreak);
});
