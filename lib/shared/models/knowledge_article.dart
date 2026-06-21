import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gentleman_os/shared/enums/knowledge_category.dart';

part 'knowledge_article.freezed.dart';
part 'knowledge_article.g.dart';

@freezed
abstract class KnowledgeArticle with _$KnowledgeArticle {
  const factory KnowledgeArticle({
    required String id,
    required String title,
    required KnowledgeCategory category,
    @Default([]) List<String> tags,
    required String contentMarkdown,
    String? sourceRef,
    @Default(false) bool favorite,
    @Default(false) bool bookmarked,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _KnowledgeArticle;

  const KnowledgeArticle._();

  bool get isRead => readAt != null;

  factory KnowledgeArticle.fromJson(Map<String, dynamic> json) =>
      _$KnowledgeArticleFromJson(json);
}
