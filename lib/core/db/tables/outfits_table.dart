import 'package:drift/drift.dart';

@DataClassName('OutfitsData')
class Outfits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get occasion => integer()();
  IntColumn get weather => integer().nullable()();
  IntColumn get temperatureC => integer().nullable()();
  IntColumn get dressCode => integer()();
  IntColumn get season => integer()();
  RealColumn get score => real().withDefault(const Constant(0))();
  TextColumn get scoreBreakdown => text().withDefault(const Constant('{}'))(); // JSON
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OutfitItemsData')
class OutfitItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get outfitId => text().references(Outfits, #id)();
  TextColumn get itemId => text()();
}

@DataClassName('WearLogsData')
class WearLogs extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get outfitId => text().nullable()();
  DateTimeColumn get wornAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
