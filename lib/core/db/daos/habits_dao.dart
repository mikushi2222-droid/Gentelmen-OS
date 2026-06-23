import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/habits_table.dart';
import 'package:gentleman_os/core/utils/streak.dart';

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

  /// Выполнена ли привычка в каждый из последних 7 дней.
  /// Индекс 0 — сегодня, 6 — шесть дней назад. Один запрос (без N+1);
  /// раскладку по дням считает чистая [completionByDay].
  Future<List<bool>> getLast7DaysCompleted(String habitId) async {
    final now = DateTime.now();
    final rangeStart = DateTime(now.year, now.month, now.day - 6);
    final logs = await (select(habitLogs)
          ..where(
            (t) =>
                t.habitId.equals(habitId) &
                t.date.isBiggerOrEqualValue(rangeStart),
          ))
        .get();
    return completionByDay(logs.map((l) => l.date), now: now);
  }

  Future<int> computeStreak(String habitId) async {
    final logs = await getLogsForHabit(habitId);
    return computeStreakDays(logs.map((l) => l.date));
  }

  Future<void> updateStreak(String habitId, int streak) =>
      (update(habits)..where((t) => t.id.equals(habitId)))
          .write(HabitsCompanion(streak: Value(streak)));
}
