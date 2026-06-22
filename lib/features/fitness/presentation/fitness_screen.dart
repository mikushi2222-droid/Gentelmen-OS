import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/fitness/application/fitness_providers.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final asyncLatest = ref.watch(latestMeasurementProvider);
    final asyncAll = ref.watch(measurementListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Прогресс'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                asyncLatest.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                  data: (latest) => Column(
                    children: [
                      _MetricCard(
                        label: 'Вес',
                        value: latest?.weight != null
                            ? latest!.weight!.toStringAsFixed(1)
                            : '—',
                        unit: 'кг',
                        icon: Icons.monitor_weight_outlined,
                        trend: null,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _MetricCard(
                        label: 'Талия',
                        value: latest?.waist != null
                            ? latest!.waist!.toStringAsFixed(0)
                            : '—',
                        unit: 'см',
                        icon: Icons.straighten,
                        trend: null,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _MetricCard(
                        label: 'Грудь',
                        value: latest?.chest != null
                            ? latest!.chest!.toStringAsFixed(0)
                            : '—',
                        unit: 'см',
                        icon: Icons.fitness_center,
                        trend: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.sectionGap),
                asyncAll.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (logs) {
                    if (logs.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WeightChart(logs: logs),
                        const SizedBox(height: Spacing.sectionGap),
                        _WaistChart(logs: logs),
                        const SizedBox(height: Spacing.sectionGap),
                        _HistoryList(logs: logs),
                      ],
                    );
                  },
                ),
                const SizedBox(height: Spacing.sectionGap),
                Text('Навигация', style: tt.titleMedium),
                const SizedBox(height: Spacing.sm),
                ListTile(
                  leading: Icon(Icons.auto_awesome, color: cs.primary),
                  title: const Text('RPG: уровень и навыки'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/progress/rpg'),
                ),
                ListTile(
                  leading: Icon(Icons.add_chart, color: cs.primary),
                  title: const Text('Добавить замер'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/progress/add-measurement'),
                ),
                ListTile(
                  leading: Icon(Icons.repeat, color: cs.primary),
                  title: const Text('Привычки'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/progress/habits'),
                ),
                ListTile(
                  leading: Icon(Icons.favorite_outline, color: AppColors.success),
                  title: const Text('Мужское здоровье'),
                  subtitle: const Text('Анализы, маркеры, индекс здоровья'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/health'),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.logs});

  final List<MeasurementLogsData> logs;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final weightLogs = logs
        .where((l) => l.weight != null)
        .toList()
        .reversed
        .take(10)
        .toList();

    if (weightLogs.length < 2) return const SizedBox();

    final spots = weightLogs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight!);
    }).toList();

    final minY =
        weightLogs.map((l) => l.weight!).reduce((a, b) => a < b ? a : b) - 2;
    final maxY =
        weightLogs.map((l) => l.weight!).reduce((a, b) => a > b ? a : b) + 2;

    final fmt = DateFormat('d.MM', 'ru');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Динамика веса', style: tt.titleMedium),
        const SizedBox(height: Spacing.sm),
        Container(
          height: 180,
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
                getDrawingHorizontalLine: (v) => FlLine(
                  color: cs.outlineVariant.withOpacity(0.4),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= weightLogs.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          fmt.format(weightLogs[idx].date),
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: AppColors.gold,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.gold,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withOpacity(0.25),
                        AppColors.gold.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map(
                        (s) => LineTooltipItem(
                          '${s.y.toStringAsFixed(1)} кг',
                          tt.labelSmall?.copyWith(color: AppColors.gold) ??
                              const TextStyle(),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaistChart extends StatelessWidget {
  const _WaistChart({required this.logs});

  final List<MeasurementLogsData> logs;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final waistLogs = logs
        .where((l) => l.waist != null)
        .toList()
        .reversed
        .take(10)
        .toList();

    if (waistLogs.length < 2) return const SizedBox();

    final spots = waistLogs.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.waist!))
        .toList();

    final minY = waistLogs.map((l) => l.waist!).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = waistLogs.map((l) => l.waist!).reduce((a, b) => a > b ? a : b) + 2;

    final fmt = DateFormat('d.MM', 'ru');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Динамика талии', style: tt.titleMedium),
        const SizedBox(height: Spacing.sm),
        Container(
          height: 160,
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
                getDrawingHorizontalLine: (v) => FlLine(
                  color: cs.outlineVariant.withOpacity(0.4),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
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
                      if (idx < 0 || idx >= waistLogs.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          fmt.format(waistLogs[idx].date),
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: AppColors.success,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.success,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withOpacity(0.2),
                        AppColors.success.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map(
                        (s) => LineTooltipItem(
                          '${s.y.toStringAsFixed(0)} см',
                          tt.labelSmall?.copyWith(color: AppColors.success) ??
                              const TextStyle(),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.logs});

  final List<MeasurementLogsData> logs;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('dd MMM yyyy', 'ru');
    final shown = logs.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('История замеров', style: tt.titleMedium),
        const SizedBox(height: Spacing.sm),
        ...shown.map(
          (log) => ListTile(
            dense: true,
            title: Text(fmt.format(log.date)),
            subtitle: Text(
              [
                if (log.weight != null) '${log.weight!.toStringAsFixed(1)} кг',
                if (log.waist != null) 'талия ${log.waist!.toStringAsFixed(0)} см',
              ].join(' • '),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.trend,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: Spacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                Text(
                  value == '—' ? '—' : '$value $unit',
                  style: tt.headlineSmall,
                ),
              ],
            ),
            const Spacer(),
            if (trend != null)
              Chip(
                label: Text(trend!),
                backgroundColor: cs.primaryContainer,
              ),
          ],
        ),
      ),
    );
  }
}
