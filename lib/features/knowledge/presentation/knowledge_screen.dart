import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/shared/enums/knowledge_category.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  KnowledgeCategory? _category;

  static const _seedArticles = [
    (id: 'fit-blazer', title: 'Как должен сидеть пиджак', category: KnowledgeCategory.suits),
    (id: 'collar-types', title: 'Типы воротников: какой вам подходит', category: KnowledgeCategory.style),
    (id: 'fabrics-guide', title: 'Какие ткани выбирать', category: KnowledgeCategory.fabrics),
    (id: 'what-not-to-buy', title: 'Что не покупать', category: KnowledgeCategory.style),
    (id: 'color-combo', title: 'Как сочетать цвета', category: KnowledgeCategory.style),
    (id: 'look-expensive', title: 'Выглядеть дороже без дорогих вещей', category: KnowledgeCategory.style),
    (id: 'large-fit-trousers', title: 'Посадка брюк для крупной фигуры', category: KnowledgeCategory.style),
    (id: 'grooming-basics', title: 'Базовый груминг', category: KnowledgeCategory.grooming),
    (id: 'etiquette-basics', title: 'Этикет: базовые правила', category: KnowledgeCategory.etiquette),
    (id: 'discipline-habits', title: 'Дисциплина и привычки', category: KnowledgeCategory.discipline),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _category == null
        ? _seedArticles
        : _seedArticles.where((a) => a.category == _category).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('База знаний'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: _CategoryFilter(
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final a = filtered[i];
                  return _ArticleCard(
                    title: a.title,
                    category: a.category,
                    onTap: () => ctx.push('/knowledge/${a.id}'),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
        ],
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
  const _ArticleCard({
    required this.title,
    required this.category,
    this.onTap,
  });

  final String title;
  final KnowledgeCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.menu_book, color: cs.onPrimaryContainer, size: 20),
        ),
        title: Text(title, style: tt.bodyMedium),
        subtitle: Text(category.label, style: tt.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
