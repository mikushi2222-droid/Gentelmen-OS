import 'package:gentleman_os/core/db/daos/knowledge_dao.dart';
import 'package:gentleman_os/features/knowledge/data/knowledge_mapper.dart';
import 'package:gentleman_os/features/knowledge/domain/knowledge_repository.dart';
import 'package:gentleman_os/shared/enums/knowledge_category.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

class KnowledgeRepositoryImpl implements KnowledgeRepository {
  const KnowledgeRepositoryImpl(this._dao);

  final KnowledgeDao _dao;

  @override
  Stream<List<KnowledgeArticle>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Stream<List<KnowledgeArticle>> watchByCategory(KnowledgeCategory category) =>
      _dao
          .watchByCategory(category.index)
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Stream<List<KnowledgeArticle>> watchFavorites() =>
      _dao.watchFavorites().map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Future<KnowledgeArticle?> getById(String id) async {
    final row = await _dao.getById(id);
    return row?.toDomain();
  }

  @override
  Future<List<KnowledgeArticle>> search(String query) async {
    final rows = await _dao.search(query);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> toggleFavorite(String id, bool value) =>
      _dao.toggleFavorite(id, value);

  @override
  Future<void> toggleBookmark(String id, bool value) =>
      _dao.toggleBookmark(id, value);

  @override
  Future<void> markAsRead(String id) => _dao.markAsRead(id);
}
