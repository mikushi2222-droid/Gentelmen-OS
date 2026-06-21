import 'package:drift/drift.dart';

@DataClassName('UserProfileData')
class UserProfile extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  RealColumn get height => real().withDefault(const Constant(0))();
  RealColumn get weight => real().withDefault(const Constant(0))();
  RealColumn get waist => real().withDefault(const Constant(0))();
  RealColumn get chest => real().withDefault(const Constant(0))();
  RealColumn get hips => real().withDefault(const Constant(0))();
  RealColumn get shoulders => real().withDefault(const Constant(0))();
  RealColumn get neck => real().withDefault(const Constant(0))();
  RealColumn get shoeSize => real().withDefault(const Constant(0))();
  TextColumn get stylePreferences => text().withDefault(const Constant('[]'))(); // JSON list
  TextColumn get colorPreferences => text().withDefault(const Constant('[]'))(); // JSON list
  IntColumn get budgetTier => integer().withDefault(const Constant(1))(); // 0=low,1=med,2=high
  TextColumn get restrictions => text().withDefault(const Constant('[]'))(); // JSON list
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
