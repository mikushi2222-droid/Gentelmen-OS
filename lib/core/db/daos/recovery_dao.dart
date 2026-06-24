import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/recovery_logs_table.dart';

part 'recovery_dao.g.dart';

@DriftAccessor(tables: [RecoveryLogs])
class RecoveryDao extends DatabaseAccessor<AppDatabase>
    with _$RecoveryDaoMixin {
  RecoveryDao(super.db);

  Stream<List<RecoveryLogsData>> watchAll() =>
      (select(recoveryLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<RecoveryLogsData?> getForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return (select(recoveryLogs)
          ..where(
            (t) => t.date.isBetweenValues(d, d.add(const Duration(days: 1))),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<RecoveryLogsData?> watchToday() {
    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    return (select(recoveryLogs)
          ..where(
            (t) => t.date.isBetweenValues(d, d.add(const Duration(days: 1))),
          )
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<List<RecoveryLogsData>> getRecent(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(recoveryLogs)
          ..where((t) => t.date.isBiggerThanValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<void> upsert(RecoveryLogsCompanion entry) =>
      into(recoveryLogs).insertOnConflictUpdate(entry);

  Future<void> remove(String id) =>
      (delete(recoveryLogs)..where((t) => t.id.equals(id))).go();
}
