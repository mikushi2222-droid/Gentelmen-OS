import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/features/wardrobe/presentation/clothing_card.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  ClothingCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Гардероб'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: _CategoryFilter(
                selected: _selectedCategory,
                onSelected: (c) =>
                    setState(() => _selectedCategory = c),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: _WardrobeGrid(category: _selectedCategory),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/wardrobe/add'),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({this.selected, this.onSelected});

  final ClothingCategory? selected;
  final ValueChanged<ClothingCategory?>? onSelected;

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
          ...ClothingCategory.values.map(
            (c) => _Chip(
              label: c.label,
              selected: selected == c,
              onTap: () =>
                  onSelected?.call(selected == c ? null : c),
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
        checkmarkColor: cs.onPrimaryContainer,
      ),
    );
  }
}

class _WardrobeGrid extends ConsumerWidget {
  const _WardrobeGrid({this.category});

  final ClothingCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = category == null
        ? ref.watch(wardrobeListProvider)
        : ref.watch(wardrobeByCategoryProvider(category!));

    return asyncItems.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Ошибка: $e')),
      ),
      data: (items) => _ItemsGrid(items: items),
    );
  }
}

class _ItemsGrid extends StatelessWidget {
  const _ItemsGrid({required this.items});

  final List<ClothingItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.checkroom_outlined,
          title: 'Гардероб пуст',
          subtitle:
              'Добавьте первую вещь, чтобы начать\nстроить ваш цифровой гардероб',
          action: Builder(
            builder: (context) => FilledButton.icon(
              onPressed: () => context.push('/wardrobe/add'),
              icon: const Icon(Icons.add),
              label: const Text('Добавить вещь'),
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => ClothingCard(item: items[i]),
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
    );
  }
}
