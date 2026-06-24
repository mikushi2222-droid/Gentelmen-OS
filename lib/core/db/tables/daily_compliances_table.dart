import 'package:drift/drift.dart';

/// Дневная запись System Compliance: итоговый score + исходные компоненты.
/// Одна строка на дату (уникальность обеспечивается upsert по дате в DAO).
@DataClassName('DailyCompliancesData')
class DailyCompliances extends Table {
  TextColumn get id => text()();

  /// Нормализованная дата (полночь UTC).
  DateTimeColumn get date => dateTime()();

  /// Итоговый compliance score 0–100.
  RealColumn get score => real()();

  BoolColumn get weightLogged =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get mealsLogged =>
      boolean().withDefault(const Constant(false))();

  /// мл воды за день.
  IntColumn get waterMl => integer().nullable()();
  RealColumn get sleepHours => real().nullable()();
  IntColumn get steps => integer().nullable()();
  IntColumn get habitsCompleted =>
      integer().withDefault(const Constant(0))();
  IntColumn get habitsTotal => integer().withDefault(const Constant(0))();
  BoolColumn get checkInDone =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
