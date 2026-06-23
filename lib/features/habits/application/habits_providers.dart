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

/// Выполнение привычки за последние 7 дней ([0]=сегодня … [6]=6 дней назад).
final habitLast7DaysProvider =
    FutureProvider.family<List<bool>, String>((ref, habitId) {
  return ref.watch(habitsDaoProvider).getLast7DaysCompleted(habitId);
});
