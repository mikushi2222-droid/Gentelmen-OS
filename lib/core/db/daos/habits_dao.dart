import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/habits_table.dart';

part 'habits_dao.g.dart';

@DriftAccessor(tables: [Habits, HabitLogs])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  HabitsDao(super.db);

  Stream<List<HabitsData>> watchActive() =>
      (select(habits)..where((t) => t.active.equals(true))).watch();

  Stream<List<HabitsData>> watchAll() => select(habits).watch();

  Future<void> upsert(HabitsCompanion habit) =>
      into(habits).insertOnConflictUpdate(habit);

  Future<void> log(HabitLogsCompanion entry) =>
      into(habitLogs).insert(entry, mode: InsertMode.insertOrIgnore);

  Future<List<HabitLogsData>> getLogsForHabit(String habitId) =>
      (select(habitLogs)
            ..where((t) => t.habitId.equals(habitId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<bool> isCompletedToday(String habitId) async {
    final today = DateTime.now();
    final logs = await (select(habitLogs)
          ..where(
            (t) =>
                t.habitId.equals(habitId) &
                t.date.isBiggerOrEqualValue(
                  DateTime(today.year, today.month, today.day),
                ),
          ))
        .get();
    return logs.isNotEmpty;
  }

  /// Множество id привычек, отмеченных выполненными за день [day].
  /// Один запрос вместо N вызовов [isCompletedToday] (устраняет N+1).
  Future<Set<String>> completedHabitIdsOn(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final logs = await (select(habitLogs)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          ))
        .get();
    return logs.map((l) => l.habitId).toSet();
  }

  Future<int> computeStreak(String habitId) async {
    final logs = await getLogsForHabit(habitId);
    if (logs.isEmpty) return 0;

    final dates = logs
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Календарный предыдущий день: DateTime(...-1) корректно переносит месяц/год
    // и не страдает от переходов на летнее время (в отличие от subtract(days:1)).
    DateTime prevDay(DateTime d) => DateTime(d.year, d.month, d.day - 1);

    var streak = 0;
    final now = DateTime.now();
    var expected = DateTime(now.year, now.month, now.day);

    for (final date in dates) {
      if (date == expected || date == prevDay(expected)) {
        streak++;
        expected = prevDay(date);
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> updateStreak(String habitId, int streak) =>
      (update(habits)..where((t) => t.id.equals(habitId)))
          .write(HabitsCompanion(streak: Value(streak)));
}
