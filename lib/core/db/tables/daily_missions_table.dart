import 'package:drift/drift.dart';

class DailyMissions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get xpReward => integer().withDefault(const Constant(10))();
  IntColumn get xpType => integer().withDefault(const Constant(6))(); // XpType.general
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
