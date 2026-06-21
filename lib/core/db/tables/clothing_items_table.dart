import 'package:drift/drift.dart';

class ClothingItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get category => integer()(); // ClothingCategory.index
  TextColumn get brand => text().nullable()();
  TextColumn get size => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get material => text().nullable()();
  IntColumn get season => integer().withDefault(const Constant(4))(); // Season.all
  IntColumn get fit => integer().withDefault(const Constant(1))(); // Fit.regular
  RealColumn get price => real().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get condition => integer().withDefault(const Constant(1))(); // Condition.good
  IntColumn get rating => integer().nullable()();
  IntColumn get wearCount => integer().withDefault(const Constant(0))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
