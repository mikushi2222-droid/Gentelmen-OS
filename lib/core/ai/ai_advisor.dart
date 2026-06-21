import 'package:gentleman_os/core/ai/style_advice.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

/// Abstract interface for AI-powered style advice.
/// Implementations: LocalAiAdvisor (rule-based, offline),
/// OpenAiAdvisor, GeminiAdvisor.
abstract interface class AiAdvisor {
  /// Returns style advice based on wardrobe and profile context.
  Future<StyleAdvice> getStyleAdvice({
    required List<ClothingItem> wardrobe,
    String? occasion,
  });

  /// Returns article recommendations from knowledge base.
  Future<List<KnowledgeArticle>> recommendArticles({
    required List<KnowledgeArticle> articles,
    required List<ClothingItem> wardrobe,
    int limit = 3,
  });
}
