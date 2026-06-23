import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/knowledge_articles_table.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';

part 'knowledge_dao.g.dart';

@DriftAccessor(tables: [KnowledgeArticles])
class KnowledgeDao extends DatabaseAccessor<AppDatabase>
    with _$KnowledgeDaoMixin {
  KnowledgeDao(super.db);

  static const String _tag = 'Knowledge';

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

  Future<void> toggleFavorite(String id, bool value) {
    AppLogger.instance.i(_tag, 'Избранное $id → $value');
    return (update(knowledgeArticles)..where((t) => t.id.equals(id)))
        .write(KnowledgeArticlesCompanion(favorite: Value(value)));
  }

  Future<void> toggleBookmark(String id, bool value) {
    AppLogger.instance.i(_tag, 'Закладка $id → $value');
    return (update(knowledgeArticles)..where((t) => t.id.equals(id)))
        .write(KnowledgeArticlesCompanion(bookmarked: Value(value)));
  }

  Future<void> markAsRead(String id) {
    AppLogger.instance.i(_tag, 'Статья прочитана: $id');
    return (update(knowledgeArticles)..where((t) => t.id.equals(id))).write(
      KnowledgeArticlesCompanion(readAt: Value(DateTime.now())),
    );
  }

  Future<int> countRead() async {
    final all = await select(knowledgeArticles).get();
    return all.where((a) => a.readAt != null).length;
  }

  /// Сколько статей прочитано не раньше [since] (по последней дате чтения).
  Future<int> countReadSince(DateTime since) async {
    final all = await select(knowledgeArticles).get();
    return all
        .where((a) => a.readAt != null && !a.readAt!.isBefore(since))
        .length;
  }
}
