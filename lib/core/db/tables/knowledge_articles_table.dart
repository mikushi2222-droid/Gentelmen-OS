import 'package:drift/drift.dart';

class KnowledgeArticles extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get category => integer()();
  TextColumn get tags => text().withDefault(const Constant('[]'))(); // JSON list
  TextColumn get contentMarkdown => text()();
  TextColumn get sourceRef => text().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get bookmarked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
