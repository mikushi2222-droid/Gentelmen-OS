import 'package:drift/drift.dart';

@DataClassName('HabitsData')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get target => integer().withDefault(const Constant(1))();
  IntColumn get period => integer().withDefault(const Constant(0))(); // 0=daily, 1=weekly
  IntColumn get streak => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('HabitLogsData')
class HabitLogs extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text().references(Habits, #id)();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
