import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/ai/ai_advisor_provider.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';
import 'package:gentleman_os/features/knowledge/application/knowledge_providers.dart';
import 'package:gentleman_os/shared/enums/knowledge_category.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  KnowledgeCategory? _category;
  bool _searching = false;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_searching) {
      return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Поиск статей...',
              border: InputBorder.none,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() {
              _searching = false;
              _query = '';
              _searchCtrl.clear();
            }),
          ),
        ),
        body: _SearchResults(query: _query),
      );
    }

    final asyncItems = _category == null
        ? ref.watch(knowledgeListProvider)
        : ref.watch(knowledgeByCategoryProvider(_category!));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('База знаний'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => setState(() => _searching = true),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: _CategoryFilter(
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
            ),
          ),
          if (_category == null)
            const SliverToBoxAdapter(child: _RecommendedSection()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.screenPadding,
              0,
              Spacing.screenPadding,
              Spacing.screenPadding,
            ),
            sliver: asyncItems.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Ошибка: $e')),
              ),
              data: (articles) => articles.isEmpty
                  ? const SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Нет статей',
                        subtitle: 'В этой категории пока нет статей',
                      ),
                    )
                  : _ArticleList(articles: articles),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedSection extends ConsumerWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecs = ref.watch(recommendedArticlesProvider);
    final tt = Theme.of(context).textTheme;

    return asyncRecs.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (articles) {
        if (articles.isEmpty) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.screenPadding,
            Spacing.sm,
            Spacing.screenPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    'Рекомендуем прочитать',
                    style: tt.titleSmall?.copyWith(color: AppColors.gold),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              ...articles.map(
                (a) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                      child: Icon(Icons.auto_awesome,
                          size: 16, color: AppColors.gold),
                    ),
                    title: Text(a.title, style: tt.bodyMedium),
                    subtitle: Text(a.category.label, style: tt.bodySmall),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/knowledge/${a.id}'),
                  ),
                ),
              ),
              const Divider(height: Spacing.sectionGap),
            ],
          ),
        );
      },
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Введите поисковый запрос'),
      );
    }

    final asyncResults = ref.watch(knowledgeSearchProvider(query));
    return asyncResults.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Ошибка: $e')),
      data: (articles) {
        if (articles.isEmpty) {
          return Center(child: Text('По запросу «$query» ничего не найдено'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          itemCount: articles.length,
          itemBuilder: (ctx, i) => _ArticleCard(article: articles[i]),
        );
      },
    );
  }
}

class _ArticleList extends StatelessWidget {
  const _ArticleList({required this.articles});

  final List<KnowledgeArticle> articles;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => _ArticleCard(article: articles[i]),
        childCount: articles.length,
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({this.selected, this.onSelected});

  final KnowledgeCategory? selected;
  final ValueChanged<KnowledgeCategory?>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenPadding,
          vertical: 8,
        ),
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'Все',
            selected: selected == null,
            onTap: () => onSelected?.call(null),
          ),
          ...KnowledgeCategory.values.map(
            (c) => _Chip(
              label: c.label,
              selected: selected == c,
              onTap: () => onSelected?.call(selected == c ? null : c),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap?.call(),
        selectedColor: cs.primaryContainer,
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: article.favorite
              ? cs.primaryContainer
              : cs.surfaceContainerLow,
          child: Icon(
            article.favorite ? Icons.favorite : Icons.menu_book,
            color: article.favorite ? cs.primary : cs.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(article.title, style: tt.bodyMedium),
        subtitle: Row(
          children: [
            Text(article.category.label, style: tt.bodySmall),
            if (article.isRead) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle,
                  size: 12, color: cs.primary.withValues(alpha: 0.7)),
              const SizedBox(width: 2),
              Text(
                'Прочитано',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (article.bookmarked)
              Icon(Icons.bookmark, size: 16, color: cs.primary),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.push('/knowledge/${article.id}'),
      ),
    );
  }
}
