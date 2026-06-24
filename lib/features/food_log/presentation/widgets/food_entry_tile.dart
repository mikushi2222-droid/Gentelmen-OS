import 'package:flutter/material.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/features/food_log/domain/nutrition_ai_result.dart';

class FoodEntryTile extends StatelessWidget {
  const FoodEntryTile({required this.entry, this.onDelete, super.key});

  final FoodLogsData entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final mealType = MealType.fromValue(entry.mealType);
    final hasAi = entry.kcalEstimate != null || entry.proteinEstimate != null;

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Иконка типа еды
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_mealIcon(mealType), color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            // Контент
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        mealType.label,
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.gold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeStr(entry.loggedAt),
                        style: tt.labelSmall
                            ?.copyWith(color: AppColors.textDisabled),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.description,
                    style: tt.bodyMedium
                        ?.copyWith(color: AppColors.textPrimary),
                  ),
                  if (hasAi) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (entry.kcalEstimate != null)
                          _Chip('~${entry.kcalEstimate} kcal'),
                        if (entry.proteinEstimate != null)
                          _Chip('Protein: ${entry.proteinEstimate}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Удалить
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.textDisabled, size: 18),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  static IconData _mealIcon(MealType type) => switch (type) {
        MealType.breakfast => Icons.wb_sunny_outlined,
        MealType.lunch => Icons.lunch_dining,
        MealType.dinner => Icons.dinner_dining,
        MealType.snack => Icons.local_cafe_outlined,
      };

  static String _timeStr(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
      ),
    );
  }
}
