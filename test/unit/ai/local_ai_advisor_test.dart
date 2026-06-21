import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/core/ai/local_ai_advisor.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';
import 'package:gentleman_os/shared/enums/knowledge_category.dart';

ClothingItem _item(String id, ClothingCategory cat, {String? material}) =>
    ClothingItem(
      id: id,
      name: 'Item $id',
      category: cat,
      material: material,
      createdAt: DateTime(2024),
    );

KnowledgeArticle _article(String id, String title, List<String> tags) =>
    KnowledgeArticle(
      id: id,
      title: title,
      category: KnowledgeCategory.style,
      tags: tags,
      contentMarkdown: '',
      createdAt: DateTime(2024),
    );

void main() {
  const advisor = LocalAiAdvisor();

  group('getStyleAdvice', () {
    test('пустой гардероб — предлагает базовые категории', () async {
      final advice = await advisor.getStyleAdvice(wardrobe: []);
      expect(advice.suggestions, isNotEmpty);
    });

    test('гардероб без обуви — предупреждение об обуви', () async {
      final wardrobe = [
        _item('1', ClothingCategory.shirt),
        _item('2', ClothingCategory.trousers),
      ];
      final advice = await advisor.getStyleAdvice(wardrobe: wardrobe);
      expect(
        advice.suggestions.any((s) => s.contains('туфл') || s.contains('кед')),
        isTrue,
      );
    });

    test('блестящий материал → предупреждение', () async {
      final wardrobe = [
        _item('1', ClothingCategory.shirt, material: 'полиэстер'),
        _item('2', ClothingCategory.trousers),
        _item('3', ClothingCategory.shoes),
      ];
      final advice = await advisor.getStyleAdvice(wardrobe: wardrobe);
      expect(advice.warnings, isNotEmpty);
    });

    test('полный базовый гардероб — warnings пуст', () async {
      final wardrobe = [
        _item('1', ClothingCategory.shirt),
        _item('2', ClothingCategory.trousers),
        _item('3', ClothingCategory.shoes),
      ];
      final advice = await advisor.getStyleAdvice(wardrobe: wardrobe);
      expect(advice.warnings, isEmpty);
    });
  });

  group('recommendArticles', () {
    final articles = [
      _article('a1', 'Посадка пиджака', ['пиджак', 'посадка']),
      _article('a2', 'Цвет и стиль', ['цвет']),
      _article('a3', 'Этикет', ['этикет']),
    ];

    test('возвращает не более limit статей', () async {
      final result = await advisor.recommendArticles(
        articles: articles,
        wardrobe: [],
        limit: 2,
      );
      expect(result.length, lessThanOrEqualTo(2));
    });

    test('пустой список статей → пустой результат', () async {
      final result = await advisor.recommendArticles(
        articles: [],
        wardrobe: [],
      );
      expect(result, isEmpty);
    });

    test('статьи о пиджаке в приоритете для гардероба без blazer', () async {
      final result = await advisor.recommendArticles(
        articles: articles,
        wardrobe: [_item('1', ClothingCategory.shirt)],
        limit: 3,
      );
      // a1 (пиджак) should rank high
      expect(result.any((a) => a.id == 'a1'), isTrue);
    });
  });
}
