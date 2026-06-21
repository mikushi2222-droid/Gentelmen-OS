import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/knowledge/data/knowledge_repository_impl.dart';
import 'package:gentleman_os/features/knowledge/domain/knowledge_repository.dart';
import 'package:gentleman_os/shared/enums/knowledge_category.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>(
  (ref) => KnowledgeRepositoryImpl(ref.watch(knowledgeDaoProvider)),
);

final knowledgeListProvider = StreamProvider<List<KnowledgeArticle>>(
  (ref) => ref.watch(knowledgeRepositoryProvider).watchAll(),
);

final knowledgeByCategoryProvider =
    StreamProvider.family<List<KnowledgeArticle>, KnowledgeCategory>(
  (ref, category) =>
      ref.watch(knowledgeRepositoryProvider).watchByCategory(category),
);

final knowledgeFavoritesProvider = StreamProvider<List<KnowledgeArticle>>(
  (ref) => ref.watch(knowledgeRepositoryProvider).watchFavorites(),
);

final knowledgeArticleProvider =
    FutureProvider.family<KnowledgeArticle?, String>((ref, id) {
  return ref.watch(knowledgeRepositoryProvider).getById(id);
});

final knowledgeSearchProvider =
    FutureProvider.family<List<KnowledgeArticle>, String>((ref, query) {
  if (query.isEmpty) return Future.value([]);
  return ref.watch(knowledgeRepositoryProvider).search(query);
});
