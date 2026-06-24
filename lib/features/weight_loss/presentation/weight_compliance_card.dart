import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/weight_loss/application/weight_loss_providers.dart';
import 'package:gentleman_os/features/weight_loss/domain/weight_trend.dart';

/// Dashboard-карточка V3.0: тренд веса + System Compliance.
///
/// Показывается под Gentleman Score, только если есть хотя бы 2 замера веса.
/// Если данных нет — не рендерится (SizedBox.shrink).
class WeightComplianceCard extends ConsumerWidget {
  const WeightComplianceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(weightTrendProvider);
    final compliance = ref.watch(todayComplianceProvider);
    final snapshot = ref.watch(progressSnapshotProvider);

    if (trend == null ||
        trend.status == WeightTrendStatus.insufficient) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final trendColor = _trendColor(trend.status, cs);
    final trendIcon = _trendIcon(trend.status);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline, width: 0.5),
      ),
      padding: const EdgeInsets.all(Spacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight_outlined,
                  color: trendColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'System Status',
                style:
                    tt.titleSmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: trendIcon,
                  iconColor: trendColor,
                  label: 'Тренд веса',
                  value: _trendLabel(trend),
                  sublabel: trend.status.message,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _MetricTile(
                  icon: Icons.bar_chart_rounded,
                  iconColor: _complianceColor(compliance, cs),
                  label: 'Compliance',
                  value: '${compliance.round()}%',
                  sublabel: _complianceSublabel(compliance),
                ),
              ),
            ],
          ),
          if (snapshot != null && snapshot.insights.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                snapshot.insights.first,
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (snapshot != null && snapshot.beltNotchesRecovered > 0) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                const Icon(Icons.trending_down,
                    color: AppColors.gold, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Belt notches recovered: ${snapshot.beltNotchesRecovered}',
                  style: tt.labelSmall?.copyWith(color: AppColors.gold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _trendColor(WeightTrendStatus status, ColorScheme cs) =>
      switch (status) {
        WeightTrendStatus.optimal => Colors.green,
        WeightTrendStatus.aggressive => cs.error,
        WeightTrendStatus.plateau => cs.tertiary,
        WeightTrendStatus.insufficient => cs.onSurfaceVariant,
      };

  IconData _trendIcon(WeightTrendStatus status) => switch (status) {
        WeightTrendStatus.optimal => Icons.trending_down,
        WeightTrendStatus.aggressive => Icons.warning_amber_outlined,
        WeightTrendStatus.plateau => Icons.horizontal_rule,
        WeightTrendStatus.insufficient => Icons.help_outline,
      };

  String _trendLabel(WeightTrendResult trend) {
    final rate = trend.weeklyRatekgPerWeek;
    final sign = rate >= 0 ? '+' : '';
    return '$sign${rate.toStringAsFixed(2)} кг/нед';
  }

  Color _complianceColor(double score, ColorScheme cs) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return cs.tertiary;
    return cs.error;
  }

  String _complianceSublabel(double score) {
    if (score >= 85) return 'optimal';
    if (score >= 65) return 'stable';
    if (score >= 40) return 'degraded';
    return 'visibility lost';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sublabel,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: tt.labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: tt.titleMedium?.copyWith(color: iconColor),
          ),
          Text(
            sublabel,
            style: tt.bodySmall
                ?.copyWith(color: AppColors.textSecondary, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
