import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/knowledge_articles_table.dart';

part 'knowledge_dao.g.dart';

@DriftAccessor(tables: [KnowledgeArticles])
class KnowledgeDao extends DatabaseAccessor<AppDatabase>
    with _$KnowledgeDaoMixin {
  KnowledgeDao(super.db);

  Stream<List<KnowledgeArticlesData>> watchAll() =>
      (select(knowledgeArticles)
            ..orderBy([(t) => OrderingTerm.asc(t.title)]))
          .watch();

  Stream<List<KnowledgeArticlesData>> watchByCategory(int categoryIndex) =>
      (select(knowledgeArticles)
            ..where((t) => t.category.equals(categoryIndex))
            ..orderBy([(t) => OrderingTerm.asc(t.title)]))
          .watch();

  Stream<List<KnowledgeArticlesData>> watchFavorites() =>
      (select(knowledgeArticles)
            ..where((t) => t.favorite.equals(true)))
          .watch();

  Future<KnowledgeArticlesData?> getById(String id) =>
      (select(knowledgeArticles)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<KnowledgeArticlesData>> search(String query) async {
    final q = query.toLowerCase();
    final all = await select(knowledgeArticles).get();
    return all
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              a.tags.toLowerCase().contains(q) ||
              a.contentMarkdown.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> upsert(KnowledgeArticlesCompanion article) =>
      into(knowledgeArticles).insertOnConflictUpdate(article);

  Future<void> toggleFavorite(String id, bool value) =>
      (update(knowledgeArticles)..where((t) => t.id.equals(id)))
          .write(KnowledgeArticlesCompanion(favorite: Value(value)));

  Future<void> toggleBookmark(String id, bool value) =>
      (update(knowledgeArticles)..where((t) => t.id.equals(id)))
          .write(KnowledgeArticlesCompanion(bookmarked: Value(value)));
}
