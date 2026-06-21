import 'package:drift/drift.dart';

@DataClassName('PurchaseWishesData')
class PurchaseWishes extends Table {
  TextColumn get id => text()();
  TextColumn get itemName => text()();
  IntColumn get category => integer()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  RealColumn get budget => real().nullable()();
  TextColumn get reason => text().nullable()();
  IntColumn get status => integer().withDefault(const Constant(0))(); // WishStatus.index
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
