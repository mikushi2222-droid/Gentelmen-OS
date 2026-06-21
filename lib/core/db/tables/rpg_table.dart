import 'package:drift/drift.dart';

@DataClassName('XpEventsData')
class XpEvents extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()(); // XpType.index
  IntColumn get amount => integer()();
  TextColumn get reason => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AchievementsData')
class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
