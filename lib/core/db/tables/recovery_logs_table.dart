import 'package:drift/drift.dart';

/// Ежедневный журнал самочувствия: энергия, голод, стресс, вода, шаги, сон.
/// Одна запись в день (upsert по date-ключу в DAO).
@DataClassName('RecoveryLogsData')
class RecoveryLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();

  /// 1–5: 1 = истощён, 5 = отличная энергия.
  IntColumn get energyLevel => integer().nullable()();

  /// 1–5: 1 = нет голода (важно для GLP-1), 5 = сильный голод.
  IntColumn get hungerLevel => integer().nullable()();

  RealColumn get sleepHours => real().nullable()();

  /// 1–5: 1 = спокойно, 5 = высокий стресс.
  IntColumn get stressLevel => integer().nullable()();

  IntColumn get waterMl => integer().nullable()();
  IntColumn get steps => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
