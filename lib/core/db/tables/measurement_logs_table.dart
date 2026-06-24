import 'package:drift/drift.dart';

@DataClassName('MeasurementLogsData')
class MeasurementLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weight => real().nullable()();
  RealColumn get waist => real().nullable()();
  RealColumn get chest => real().nullable()();
  RealColumn get hips => real().nullable()();
  IntColumn get steps => integer().nullable()();
  RealColumn get proteinGrams => real().nullable()();
  IntColumn get hydrationMl => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
