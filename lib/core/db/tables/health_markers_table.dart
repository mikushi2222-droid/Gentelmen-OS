import 'package:drift/drift.dart';

/// Замеры показателей мужского здоровья (анализы, давление, сон и т.д.).
class HealthMarkers extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()(); // HealthMarkerType.index
  RealColumn get value => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
