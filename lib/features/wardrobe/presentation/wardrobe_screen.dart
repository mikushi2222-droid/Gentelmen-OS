import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/ai/ai_advisor_provider.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/features/wardrobe/domain/wear_forecast.dart';
import 'package:gentleman_os/features/wardrobe/presentation/clothing_card.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

enum _WardrobeSort { newest, urgency }

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  ClothingCategory? _selectedCategory;
  _WardrobeSort _sort = _WardrobeSort.newest;
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: _searching
                ? TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Поиск по названию...',
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  )
                : const Text('Гардероб'),
            actions: [
              if (_searching)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    _searching = false;
                    _query = '';
                    _searchCtrl.clear();
                  }),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Поиск',
                  onPressed: () => setState(() => _searching = true),
                ),
                IconButton(
                  tooltip: _sort == _WardrobeSort.newest
                      ? 'Сортировать по срочности'
                      : 'Сортировать по дате',
                  icon: Icon(
                    _sort == _WardrobeSort.newest
                        ? Icons.sort
                        : Icons.wb_sunny_outlined,
                    color: _sort == _WardrobeSort.urgency
                        ? AppColors.gold
                        : null,
                  ),
                  onPressed: () => setState(
                    () => _sort = _sort == _WardrobeSort.newest
                        ? _WardrobeSort.urgency
                        : _WardrobeSort.newest,
                  ),
                ),
              ],
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: _CategoryFilter(
                selected: _selectedCategory,
                onSelected: (c) => setState(() => _selectedCategory = c),
              ),
            ),
          ),
          if (_selectedCategory == null && !_searching)
            const SliverToBoxAdapter(child: _WardrobeStatsPanel()),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: _WardrobeGrid(
              category: _selectedCategory,
              sort: _sort,
              query: _query,
            ),
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

class _WardrobeStatsPanel extends ConsumerWidget {
  const _WardrobeStatsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(wardrobeListProvider);
    final asyncAdvice = ref.watch(styleAdviceProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return asyncItems.when(
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
      data: (items) {
        if (items.isEmpty) return const SizedBox();

        final totalValue = items.fold<double>(
          0,
          (sum, i) => sum + (i.price ?? 0),
        );
        final mostWorn = items.isEmpty
            ? null
            : items.reduce((a, b) => a.wearCount > b.wearCount ? a : b);
        final bestCpw = items
            .where((i) => i.costPerWear != null)
            .toList()
          ..sort((a, b) => a.costPerWear!.compareTo(b.costPerWear!));

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.screenPadding,
            0,
            Spacing.screenPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Статистика гардероба', style: tt.titleSmall),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          label: 'Вещей',
                          value: '${items.length}',
                          icon: Icons.checkroom_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatChip(
                          label: 'Стоимость',
                          value: totalValue > 0
                              ? '${totalValue.toStringAsFixed(0)} ₽'
                              : '—',
                          icon: Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (mostWorn != null && mostWorn.wearCount > 0)
                    _StatRow(
                      label: 'Самая носимая',
                      value:
                          '${mostWorn.name} (×${mostWorn.wearCount})',
                      icon: Icons.star_outline,
                    ),
                  if (bestCpw.isNotEmpty)
                    _StatRow(
                      label: 'Лучшая цена/носка',
                      value:
                          '${bestCpw.first.name} — ${bestCpw.first.costPerWear!.toStringAsFixed(0)} ₽/раз',
                      icon: Icons.trending_down,
                    ),
                  const SizedBox(height: Spacing.sm),
                  asyncAdvice.when(
                    loading: () => const SizedBox(),
                    error: (_, _) => const SizedBox(),
                    data: (advice) {
                      if (advice.suggestions.isEmpty &&
                          advice.warnings.isEmpty) {
                        return const SizedBox();
                      }
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_outline,
                                    color: AppColors.gold, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Советник',
                                  style: tt.labelSmall
                                      ?.copyWith(color: AppColors.gold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...advice.suggestions.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('• ',
                                        style: tt.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant)),
                                    Expanded(
                                      child: Text(s,
                                          style: tt.bodySmall?.copyWith(
                                              color: cs.onSurface)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ...advice.warnings.map(
                              (w) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.warning_amber_outlined,
                                        size: 14, color: AppColors.warning),
                                    const SizedBox(width: 4),
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
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              Text(value, style: tt.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style:
                tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          Expanded(
            child: Text(
              value,
              style: tt.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _WardrobeGrid extends ConsumerWidget {
  const _WardrobeGrid({
    this.category,
    required this.sort,
    this.query = '',
  });

  final ClothingCategory? category;
  final _WardrobeSort sort;
  final String query;

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
      data: (items) => _ItemsGrid(items: items, sort: sort, query: query),
    );
  }
}

class _ItemsGrid extends StatelessWidget {
  const _ItemsGrid({
    required this.items,
    required this.sort,
    this.query = '',
  });

  final List<ClothingItem> items;
  final _WardrobeSort sort;
  final String query;

  @override
  Widget build(BuildContext context) {
    final filtered = query.isEmpty
        ? items
        : items.where((i) {
            final q = query.toLowerCase();
            return i.name.toLowerCase().contains(q) ||
                (i.brand?.toLowerCase().contains(q) ?? false);
          }).toList();

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: query.isEmpty
            ? EmptyState(
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
              )
            : EmptyState(
                icon: Icons.search_off,
                title: 'Ничего не найдено',
                subtitle: 'По запросу «$query» вещей не найдено',
              ),
      );
    }

    final now = DateTime.now();
    final sorted = sort == _WardrobeSort.urgency
        ? (List.of(filtered)
          ..sort(
            (a, b) => computeWearForecast(item: a, now: now, lastWornAt: null)
                .urgency
                .index
                .compareTo(
                  computeWearForecast(item: b, now: now, lastWornAt: null)
                      .urgency
                      .index,
                ),
          ))
        : filtered;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => ClothingCard(item: sorted[i]),
        childCount: sorted.length,
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
