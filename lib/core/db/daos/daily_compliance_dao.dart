import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/daily_compliances_table.dart';

part 'daily_compliance_dao.g.dart';

@DriftAccessor(tables: [DailyCompliances])
class DailyComplianceDao extends DatabaseAccessor<AppDatabase>
    with _$DailyComplianceDaoMixin {
  DailyComplianceDao(super.db);

  Future<DailyCompliancesData?> getForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return (select(dailyCompliances)
          ..where(
            (t) => t.date.isBetweenValues(d, d.add(const Duration(days: 1))),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<DailyCompliancesData?> watchToday() {
    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    return (select(dailyCompliances)
          ..where(
            (t) => t.date.isBetweenValues(d, d.add(const Duration(days: 1))),
          )
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<List<DailyCompliancesData>> getRecent(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(dailyCompliances)
          ..where((t) => t.date.isBiggerThanValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<void> upsert(DailyCompliancesCompanion entry) =>
      into(dailyCompliances).insertOnConflictUpdate(entry);
}
