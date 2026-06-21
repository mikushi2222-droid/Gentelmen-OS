import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/measurement_logs_table.dart';

part 'measurement_dao.g.dart';

@DriftAccessor(tables: [MeasurementLogs])
class MeasurementDao extends DatabaseAccessor<AppDatabase>
    with _$MeasurementDaoMixin {
  MeasurementDao(super.db);

  Stream<List<MeasurementLogsData>> watchAll() =>
      (select(measurementLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<MeasurementLogsData>> getAll() =>
      (select(measurementLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<MeasurementLogsData?> getLatest() =>
      (select(measurementLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> insert(MeasurementLogsCompanion entry) =>
      into(measurementLogs).insert(entry);
}
