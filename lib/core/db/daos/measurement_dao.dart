import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/measurement_logs_table.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';

part 'measurement_dao.g.dart';

@DriftAccessor(tables: [MeasurementLogs])
class MeasurementDao extends DatabaseAccessor<AppDatabase>
    with _$MeasurementDaoMixin {
  MeasurementDao(super.db);

  static const String _tag = 'Fitness';

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

  Future<void> insert(MeasurementLogsCompanion entry) {
    AppLogger.instance.i(_tag,
        'Новый замер${entry.weight.present ? ' вес=${entry.weight.value}' : ''}'
        '${entry.waist.present ? ' талия=${entry.waist.value}' : ''}');
    return into(measurementLogs).insert(entry);
  }
}
