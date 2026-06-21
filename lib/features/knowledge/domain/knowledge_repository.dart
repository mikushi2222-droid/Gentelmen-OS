import 'package:gentleman_os/shared/enums/knowledge_category.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

abstract interface class KnowledgeRepository {
  Stream<List<KnowledgeArticle>> watchAll();
  Stream<List<KnowledgeArticle>> watchByCategory(KnowledgeCategory category);
  Stream<List<KnowledgeArticle>> watchFavorites();
  Future<KnowledgeArticle?> getById(String id);
  Future<List<KnowledgeArticle>> search(String query);
  Future<void> toggleFavorite(String id, bool value);
  Future<void> toggleBookmark(String id, bool value);
  Future<void> markAsRead(String id);
}
