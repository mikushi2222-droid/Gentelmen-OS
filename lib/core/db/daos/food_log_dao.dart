import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/food_logs_table.dart';

part 'food_log_dao.g.dart';

@DriftAccessor(tables: [FoodLogs])
class FoodLogDao extends DatabaseAccessor<AppDatabase>
    with _$FoodLogDaoMixin {
  FoodLogDao(super.db);

  Stream<List<FoodLogsData>> watchAll() =>
      (select(foodLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
          .watch();

  Future<List<FoodLogsData>> getForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return (select(foodLogs)
          ..where(
            (t) =>
                t.loggedAt.isBetweenValues(d, d.add(const Duration(days: 1))),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
        .get();
  }

  Stream<List<FoodLogsData>> watchForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return (select(foodLogs)
          ..where(
            (t) =>
                t.loggedAt.isBetweenValues(d, d.add(const Duration(days: 1))),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
        .watch();
  }

  Future<void> insert(FoodLogsCompanion entry) =>
      into(foodLogs).insert(entry);

  Future<void> upsert(FoodLogsCompanion entry) =>
      into(foodLogs).insertOnConflictUpdate(entry);

  Future<void> remove(String id) =>
      (delete(foodLogs)..where((t) => t.id.equals(id))).go();
}
