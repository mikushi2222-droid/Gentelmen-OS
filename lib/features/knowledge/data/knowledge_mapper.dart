import 'dart:convert';

import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/shared/enums/knowledge_category.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

extension KnowledgeArticleRowMapper on KnowledgeArticlesData {
  KnowledgeArticle toDomain() => KnowledgeArticle(
        id: id,
        title: title,
        category: KnowledgeCategory.values[category],
        tags: List<String>.from(
          (jsonDecode(tags) as List).cast<String>(),
        ),
        contentMarkdown: contentMarkdown,
        sourceRef: sourceRef,
        favorite: favorite,
        bookmarked: bookmarked,
        createdAt: createdAt,
      );
}
