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

class OutfitsScreen extends ConsumerWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOutfits = ref.watch(savedOutfitsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Образы'),
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
              data: (outfits) => outfits.isEmpty
                  ? SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.style_outlined,
                        title: 'Образов пока нет',
                        subtitle:
                            'Соберите первый образ из вашего гардероба',
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
                        (ctx, i) => _OutfitCard(outfit: outfits[i]),
                        childCount: outfits.length,
                      ),
                    ),
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
          backgroundColor: _scoreColor(score).withOpacity(0.2),
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
              await ref.read(outfitDaoProvider).remove(outfit.id);
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
