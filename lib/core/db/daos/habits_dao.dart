import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/habits_table.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/core/utils/streak.dart';

part 'habits_dao.g.dart';

@DriftAccessor(tables: [Habits, HabitLogs])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  HabitsDao(super.db);

  static const String _tag = 'Habits';

  Stream<List<HabitsData>> watchActive() =>
      (select(habits)..where((t) => t.active.equals(true))).watch();

  Stream<List<HabitsData>> watchAll() => select(habits).watch();

  Future<void> upsert(HabitsCompanion habit) {
    AppLogger.instance.i(_tag,
        'Сохранение привычки ${habit.id.present ? habit.id.value : '?'}');
    return into(habits).insertOnConflictUpdate(habit);
  }

  Future<void> log(HabitLogsCompanion entry) {
    AppLogger.instance.i(_tag,
        'Отметка привычки ${entry.habitId.present ? entry.habitId.value : '?'}');
    return into(habitLogs).insert(entry, mode: InsertMode.insertOrIgnore);
  }

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
    return computeStreakDays(logs.map((l) => l.date));
  }

  Future<void> updateStreak(String habitId, int streak) {
    AppLogger.instance.i(_tag, 'Стрик привычки $habitId → $streak');
    return (update(habits)..where((t) => t.id.equals(habitId)))
        .write(HabitsCompanion(streak: Value(streak)));
  }

  /// Returns a 7-element list where index 0 = today, index 6 = 6 days ago.
  /// Each element is true if the habit was logged on that day.
  Future<List<bool>> getLast7DaysCompleted(String habitId) async {
    final today = DateTime.now();
    final since = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    final logs = await (select(habitLogs)
          ..where(
            (t) =>
                t.habitId.equals(habitId) &
                t.date.isBiggerOrEqualValue(since),
          ))
        .get();
    final completedDays = logs
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet();
    return List.generate(7, (i) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      return completedDays.contains(day);
    });
  }
}
