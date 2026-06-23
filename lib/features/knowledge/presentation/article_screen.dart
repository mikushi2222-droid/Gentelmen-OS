import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/services/services_provider.dart';
import 'package:gentleman_os/features/knowledge/application/knowledge_providers.dart';
import 'package:gentleman_os/features/knowledge/domain/reading_time.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({required this.articleId, super.key});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncArticle = ref.watch(knowledgeArticleProvider(articleId));

    return asyncArticle.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(child: Text('$e')),
      ),
      data: (article) {
        if (article == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Статья')),
            body: const Center(child: Text('Статья не найдена')),
          );
        }
        return _ArticleBody(article: article, ref: ref);
      },
    );
  }
}

class _ArticleBody extends StatefulWidget {
  const _ArticleBody({required this.article, required this.ref});

  final KnowledgeArticle article;
  final WidgetRef ref;

  @override
  State<_ArticleBody> createState() => _ArticleBodyState();
}

class _ArticleBodyState extends State<_ArticleBody> {
  bool _xpAwarded = false;

  KnowledgeArticle get article => widget.article;
  WidgetRef get ref => widget.ref;

  @override
  void initState() {
    super.initState();
    // XP начисляется только за ПЕРВОЕ прочтение. Флаг `_xpAwarded` защищал
    // лишь в пределах жизни экрана — повторный заход в статью каждый раз давал
    // +15 XP и фармил ачивку «Читатель». Источник истины — `readAt`.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_xpAwarded || article.readAt != null) return;
      _xpAwarded = true;
      await ref.read(knowledgeRepositoryProvider).markAsRead(article.id);
      await ref.read(xpServiceProvider).articleRead();
      await ref.read(achievementServiceProvider).checkAfterArticleRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final repo = ref.read(knowledgeRepositoryProvider);

    final minutes = readingMinutes(article.contentMarkdown);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        actions: [
          IconButton(
            icon: Icon(
              article.bookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: article.bookmarked ? cs.primary : null,
            ),
            tooltip: 'Закладка',
            onPressed: () =>
                repo.toggleBookmark(article.id, !article.bookmarked),
          ),
          IconButton(
            icon: Icon(
              article.favorite ? Icons.favorite : Icons.favorite_outline,
              color: article.favorite ? cs.error : null,
            ),
            tooltip: 'В избранное',
            onPressed: () =>
                repo.toggleFavorite(article.id, !article.favorite),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.screenPadding,
              Spacing.sm,
              Spacing.screenPadding,
              0,
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Chip(
                  avatar: Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  label: Text(
                    '~$minutes мин',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                ...article.tags.map(
                  (t) => Chip(
                    label: Text(t),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    labelStyle: tt.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Markdown(
              data: article.contentMarkdown,
              padding: const EdgeInsets.all(Spacing.screenPadding),
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: Theme.of(context).textTheme.bodyMedium,
                h1: Theme.of(context).textTheme.headlineMedium,
                h2: Theme.of(context).textTheme.headlineSmall,
                h3: Theme.of(context).textTheme.titleLarge,
                blockquoteDecoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  border: Border(
                    left: BorderSide(color: cs.primary, width: 3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
