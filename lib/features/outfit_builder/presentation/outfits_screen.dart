import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';
import 'package:gentleman_os/features/outfit_builder/application/outfit_providers.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';

class OutfitsScreen extends ConsumerStatefulWidget {
  const OutfitsScreen({super.key});

  @override
  ConsumerState<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends ConsumerState<OutfitsScreen> {
  Occasion? _occasion;

  @override
  Widget build(BuildContext context) {
    final asyncOutfits = ref.watch(savedOutfitsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Образы'),
          ),
          SliverToBoxAdapter(
            child: _OccasionFilter(
              selected: _occasion,
              onSelected: (o) => setState(() => _occasion = o),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: asyncOutfits.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Ошибка: $e')),
              ),
              data: (outfits) {
                final filtered = _occasion == null
                    ? outfits
                    : outfits
                        .where((o) => o.occasion == _occasion!.index)
                        .toList();
                return filtered.isEmpty
                    ? SliverFillRemaining(
                        child: EmptyState(
                          icon: Icons.style_outlined,
                          title: _occasion == null
                              ? 'Образов пока нет'
                              : 'Нет образов для «${_occasion!.label}»',
                          subtitle: _occasion == null
                              ? 'Соберите первый образ из вашего гардероба'
                              : 'Соберите образ для этого повода',
                          action: Builder(
                            builder: (ctx) => FilledButton.icon(
                              onPressed: () => ctx.push('/outfits/build'),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Собрать образ'),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _OutfitCard(outfit: filtered[i]),
                          childCount: filtered.length,
                        ),
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/outfits/build'),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Собрать образ'),
      ),
    );
  }
}

class _OccasionFilter extends StatelessWidget {
  const _OccasionFilter({this.selected, this.onSelected});

  final Occasion? selected;
  final ValueChanged<Occasion?>? onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenPadding,
          vertical: 8,
        ),
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Все'),
              selected: selected == null,
              onSelected: (_) => onSelected?.call(null),
              selectedColor: cs.primaryContainer,
              checkmarkColor: cs.onPrimaryContainer,
            ),
          ),
          ...Occasion.values.map(
            (o) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(o.label),
                selected: selected == o,
                onSelected: (_) =>
                    onSelected?.call(selected == o ? null : o),
                selectedColor: cs.primaryContainer,
                checkmarkColor: cs.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutfitCard extends ConsumerWidget {
  const _OutfitCard({required this.outfit});

  final OutfitsData outfit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('dd MMM yyyy', 'ru');
    final score = outfit.score;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _scoreColor(score).withValues(alpha: 0.2),
          child: Text(
            score.toStringAsFixed(0),
            style: TextStyle(
              color: _scoreColor(score),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(outfit.name, style: tt.bodyMedium),
        subtitle: Text(
          '${Occasion.values[outfit.occasion].label} • ${fmt.format(outfit.createdAt)}',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'delete') {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Удалить образ?'),
                  content: const Text(
                    'Образ будет удалён без возможности восстановления.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.error,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(outfitDaoProvider).remove(outfit.id);
              }
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Удалить'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => context.push('/outfits/${outfit.id}'),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
}
