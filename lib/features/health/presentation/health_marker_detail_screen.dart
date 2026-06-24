import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/health/application/health_providers.dart';
import 'package:gentleman_os/features/health/domain/health_marker.dart';

class HealthMarkerDetailScreen extends ConsumerWidget {
  const HealthMarkerDetailScreen({required this.typeIndex, super.key});

  final int typeIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (typeIndex < 0 || typeIndex >= HealthMarkerType.values.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Показатель')),
        body: const Center(child: Text('Неизвестный показатель')),
      );
    }
    final type = HealthMarkerType.values[typeIndex];
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final asyncRows = ref.watch(healthMarkersByTypeProvider(type));

    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      body: asyncRows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (rows) {
          final ref0 = type.reference;
          return ListView(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Референс', style: tt.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Норма: ${ref0.min ?? '—'}–${ref0.max ?? '∞'} ${type.unit}',
                        style: tt.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(type.hint,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sectionGap),
              if (rows.length >= 2) ...[
                Text('Динамика', style: tt.titleMedium),
                const SizedBox(height: Spacing.sm),
                _MarkerChart(type: type, rows: rows),
                const SizedBox(height: Spacing.sectionGap),
              ],
              Text('История', style: tt.titleMedium),
              const SizedBox(height: Spacing.sm),
              if (rows.isEmpty)
                Text('Замеров пока нет',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
              else
                ...rows.map((r) => _HistoryRow(type: type, row: r, ref: ref)),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.type, required this.row, required this.ref});

  final HealthMarkerType type;
  final HealthMarkersData row;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final status = markerStatus(type, row.value);
    final color = switch (status) {
      HealthStatus.normal => AppColors.success,
      HealthStatus.warning => AppColors.warning,
      HealthStatus.risk => AppColors.error,
      HealthStatus.unknown => AppColors.textDisabled,
    };
    final fmt = DateFormat('d MMM yyyy', 'ru');

    return ListTile(
      dense: true,
      leading: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text('${row.value} ${type.unit}', style: tt.bodyMedium),
      subtitle: Text(
        [fmt.format(row.date), if (row.note != null) row.note!].join(' · '),
        style: tt.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Удалить замер?'),
              content: const Text(
                'Запись показателя будет удалена безвозвратно.',
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
            await ref.read(healthDaoProvider).remove(row.id);
          }
        },
      ),
    );
  }
}

class _MarkerChart extends StatelessWidget {
  const _MarkerChart({required this.type, required this.rows});

  final HealthMarkerType type;
  final List<HealthMarkersData> rows;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // По возрастанию даты, последние 12.
    final data = rows.reversed.toList();
    final shown = data.length > 12 ? data.sublist(data.length - 12) : data;

    final spots = shown
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final values = shown.map((r) => r.value).toList();
    var minY = values.reduce((a, b) => a < b ? a : b);
    var maxY = values.reduce((a, b) => a > b ? a : b);
    final ref = type.reference;
    if (ref.min != null) minY = minY < ref.min! ? minY : ref.min!;
    if (ref.max != null) maxY = maxY > ref.max! ? maxY : ref.max!;
    final pad = (maxY - minY).abs() * 0.15 + 0.5;
    minY -= pad;
    maxY += pad;

    final fmt = DateFormat('d.MM', 'ru');

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: cs.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(value < 10 ? 1 : 0),
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= shown.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      fmt.format(shown[idx].date),
                      style:
                          tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          // Зоны нормы: горизонтальные линии референса.
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (ref.min != null)
                HorizontalLine(
                  y: ref.min!,
                  color: AppColors.success.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              if (ref.max != null)
                HorizontalLine(
                  y: ref.max!,
                  color: AppColors.warning.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.gold,
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter: (spot, percent, bar, index) {
                  final status = markerStatus(type, spot.y);
                  final c = switch (status) {
                    HealthStatus.normal => AppColors.success,
                    HealthStatus.warning => AppColors.warning,
                    HealthStatus.risk => AppColors.error,
                    HealthStatus.unknown => AppColors.gold,
                  };
                  return FlDotCirclePainter(
                      radius: 4, color: c, strokeWidth: 0);
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.2),
                    AppColors.gold.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
