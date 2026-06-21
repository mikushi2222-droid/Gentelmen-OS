import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/ai/ai_advisor.dart';
import 'package:gentleman_os/core/ai/local_ai_advisor.dart';
import 'package:gentleman_os/core/ai/style_advice.dart';
import 'package:gentleman_os/features/knowledge/application/knowledge_providers.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

final aiAdvisorProvider = Provider<AiAdvisor>((ref) {
  return const LocalAiAdvisor();
});

/// Computes style advice from the current wardrobe.
final styleAdviceProvider = FutureProvider<StyleAdvice>((ref) async {
  final wardrobe = await ref.watch(wardrobeListProvider.future);
  final advisor = ref.watch(aiAdvisorProvider);
  return advisor.getStyleAdvice(wardrobe: wardrobe);
});

/// Returns AI-recommended articles based on wardrobe gaps.
final recommendedArticlesProvider =
    FutureProvider<List<KnowledgeArticle>>((ref) async {
  final articles = await ref.watch(knowledgeListProvider.future);
  final wardrobe = await ref.watch(wardrobeListProvider.future);
  final advisor = ref.watch(aiAdvisorProvider);
  return advisor.recommendArticles(
    articles: articles,
    wardrobe: wardrobe,
    limit: 3,
  );
});
