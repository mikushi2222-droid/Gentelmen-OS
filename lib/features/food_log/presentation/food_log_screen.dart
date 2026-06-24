import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';
import 'package:gentleman_os/features/food_log/application/food_log_providers.dart';
import 'package:gentleman_os/features/food_log/presentation/widgets/add_food_sheet.dart';
import 'package:gentleman_os/features/food_log/presentation/widgets/food_entry_tile.dart';

class FoodLogScreen extends ConsumerWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final logsAsync = ref.watch(todayFoodLogsProvider);
    final kcalTotal = ref.watch(todayKcalTotalProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GENTLEMAN OS',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
                Text('Питание', style: tt.titleMedium),
              ],
            ),
          ),
          // Сводка дня
          if (kcalTotal != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.screenPadding,
                  Spacing.sm,
                  Spacing.screenPadding,
                  0,
                ),
                child: _DailySummaryCard(kcalTotal: kcalTotal),
              ),
            ),
          // Список приёмов пищи
          logsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Ошибка: $e')),
            ),
            data: (logs) {
              if (logs.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.restaurant_outlined,
                    title: 'Нет записей',
                    subtitle: 'Добавьте первый приём пищи сегодня',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(Spacing.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => FoodEntryTile(
                      entry: logs[i],
                      onDelete: () => ref
                          .read(foodLogDaoProvider)
                          .remove(logs[i].id),
                    ),
                    childCount: logs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddFoodSheet(),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({required this.kcalTotal});
  final int kcalTotal;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.gold, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сегодня (приблизительно)',
                style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '~$kcalTotal kcal',
                style: tt.titleMedium?.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
