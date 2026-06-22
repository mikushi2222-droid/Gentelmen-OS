import 'package:gentleman_os/core/ai/style_advice.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

abstract interface class AiAdvisor {
  Future<StyleAdvice> getStyleAdvice({
    required List<ClothingItem> wardrobe,
    String? occasion,
    List<ClothingItem> urgentItems,
    String? currentSeason,
  });

  Future<List<KnowledgeArticle>> recommendArticles({
    required List<KnowledgeArticle> articles,
    required List<ClothingItem> wardrobe,
    int limit = 3,
  });
}
