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

  Future<int> computeStreak(String habitId) async {
    final logs = await getLogsForHabit(habitId);
    if (logs.isEmpty) return 0;

    final dates = logs
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    var streak = 0;
    var expected = DateTime.now();
    expected = DateTime(expected.year, expected.month, expected.day);

    for (final date in dates) {
      if (date == expected || date == expected.subtract(const Duration(days: 1))) {
        streak++;
        expected = date.subtract(const Duration(days: 1));
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
