import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/ai/ai_advisor_provider.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/shared/models/knowledge_article.dart';

class StyleAdvisorScreen extends ConsumerWidget {
  const StyleAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Советник стиля'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checkroom_outlined),
            tooltip: 'Подобрать образ',
            onPressed: () => context.push('/outfits/build'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(styleAdviceProvider);
          ref.invalidate(recommendedArticlesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          children: const [
            _WardrobeSummaryCard(),
            SizedBox(height: Spacing.sectionGap),
            _StyleAdviceCard(),
            SizedBox(height: Spacing.sectionGap),
            _RecommendedArticlesCard(),
            SizedBox(height: Spacing.sectionGap),
            _QuickActionsCard(),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _WardrobeSummaryCard extends ConsumerWidget {
  const _WardrobeSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWardrobe = ref.watch(wardrobeListProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return asyncWardrobe.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
      data: (items) {
        final categoryCount = items
            .map((i) => i.category)
            .toSet()
            .length;
        final totalWears = items.fold(0, (sum, i) => sum + i.wearCount);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.checkroom_outlined, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Text('Ваш гардероб', style: tt.titleSmall),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        value: '${items.length}',
                        label: 'вещей',
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        value: '$categoryCount',
                        label: 'категорий',
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        value: '$totalWears',
                        label: 'носок',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                OutlinedButton.icon(
                  onPressed: () => context.push('/wardrobe'),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Открыть гардероб'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(value,
            style: tt.headlineSmall?.copyWith(color: AppColors.gold)),
        Text(label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _StyleAdviceCard extends ConsumerWidget {
  const _StyleAdviceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAdvice = ref.watch(styleAdviceProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('Персональные советы', style: tt.titleSmall),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            asyncAdvice.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) =>
                  const Text('Не удалось загрузить советы'),
              data: (advice) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      advice.summary,
                      style: tt.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (advice.suggestions.isNotEmpty) ...[
                    const SizedBox(height: Spacing.sm),
                    Text('Рекомендации', style: tt.labelMedium),
                    const SizedBox(height: 6),
                    ...advice.suggestions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 16, color: AppColors.gold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(s, style: tt.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (advice.warnings.isNotEmpty) ...[
                    const SizedBox(height: Spacing.sm),
                    Text('Обратите внимание',
                        style: tt.labelMedium?.copyWith(
                            color: AppColors.warning)),
                    const SizedBox(height: 6),
                    ...advice.warnings.map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_outlined,
                                size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(w,
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedArticlesCard extends ConsumerWidget {
  const _RecommendedArticlesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecs = ref.watch(recommendedArticlesProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return asyncRecs.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (articles) {
        if (articles.isEmpty) return const SizedBox();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined, color: cs.primary),
                    const SizedBox(width: 8),
                    Text('Читать дальше', style: tt.titleSmall),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                ...articles.map(
                  (a) => _ArticleRow(article: a),
                ),
                const SizedBox(height: Spacing.sm),
                TextButton.icon(
                  onPressed: () => context.push('/knowledge'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Вся база знаний'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article});

  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: cs.surfaceContainerLow,
        child: Icon(Icons.article_outlined, size: 16, color: cs.primary),
      ),
      title: Text(article.title, style: tt.bodySmall),
      subtitle: Text(article.category.label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () => context.push('/knowledge/${article.id}'),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Быстрые действия', style: tt.titleSmall),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Подобрать образ'),
                  onPressed: () => context.push('/outfits/build'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text('Добавить вещь'),
                  onPressed: () => context.push('/wardrobe/add'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.person_outline, size: 16),
                  label: const Text('Мой профиль'),
                  onPressed: () => context.push('/profile'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.trending_up, size: 16),
                  label: const Text('Прогресс'),
                  onPressed: () => context.go('/progress'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
