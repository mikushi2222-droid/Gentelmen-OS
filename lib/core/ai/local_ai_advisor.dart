import 'package:gentleman_os/core/ai/ai_advisor.dart';
import 'package:gentleman_os/core/ai/style_advice.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

/// Offline rule-based implementation. No network required.
final class LocalAiAdvisor implements AiAdvisor {
  const LocalAiAdvisor();

  @override
  Future<StyleAdvice> getStyleAdvice({
    required List<ClothingItem> wardrobe,
    String? occasion,
  }) async {
    final suggestions = <String>[];
    final warnings = <String>[];

    // Wardrobe gaps
    final cats = wardrobe.map((i) => i.category).toSet();
    if (!cats.contains(ClothingCategory.shirt) &&
        !cats.contains(ClothingCategory.polo)) {
      suggestions.add('Добавьте базовые рубашки или поло в гардероб');
    }
    if (!cats.contains(ClothingCategory.trousers) &&
        !cats.contains(ClothingCategory.jeans)) {
      suggestions.add('Нет базовых брюк — добавьте chino или джинсы');
    }
    if (!cats.contains(ClothingCategory.shoes)) {
      suggestions.add('Добавьте классические туфли или чистые кеды');
    }

    // Shiny/thin fabrics warning
    final shinyItems = wardrobe.where((i) => i.isShinyOrThin).toList();
    if (shinyItems.isNotEmpty) {
      warnings.add(
        'В гардеробе есть синтетические/блестящие вещи: '
        '${shinyItems.map((i) => i.name).take(2).join(", ")}. '
        'Они выглядят менее качественно.',
      );
    }

    // Wear count insight
    final mostWorn = wardrobe.isEmpty
        ? null
        : wardrobe.reduce((a, b) => a.wearCount > b.wearCount ? a : b);
    if (mostWorn != null && mostWorn.wearCount > 5) {
      suggestions.add(
        '"${mostWorn.name}" — ваша самая любимая вещь. '
        'Убедитесь, что она в хорошем состоянии.',
      );
    }

    final summary = suggestions.isEmpty && warnings.isEmpty
        ? 'Гардероб выглядит сбалансированно. Продолжайте в том же духе!'
        : 'Есть ${suggestions.length} рекомендаций по гардеробу.';

    return StyleAdvice(
      summary: summary,
      suggestions: suggestions,
      warnings: warnings,
    );
  }

  @override
  Future<List<KnowledgeArticle>> recommendArticles({
    required List<KnowledgeArticle> articles,
    required List<ClothingItem> wardrobe,
    int limit = 3,
  }) async {
    // Prefer unread, non-bookmarked articles first
    final unread = articles.where((a) => !a.bookmarked).toList();
    if (unread.isEmpty) return articles.take(limit).toList();

    // Prioritize articles matching wardrobe gaps
    final cats = wardrobe.map((i) => i.category).toSet();
    final hasSuits = cats.contains(ClothingCategory.blazer);

    final sorted = [...unread]..sort((a, b) {
        int score(KnowledgeArticle art) {
          var s = 0;
          if (!hasSuits && art.tags.contains('пиджак')) s += 2;
          if (art.tags.contains('посадка')) s += 1;
          return s;
        }
        return score(b).compareTo(score(a));
      });

    return sorted.take(limit).toList();
  }
}
