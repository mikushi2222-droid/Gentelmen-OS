import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                _MetricCard(
                  label: 'Вес',
                  value: '—',
                  unit: 'кг',
                  icon: Icons.monitor_weight_outlined,
                  trend: null,
                ),
                const SizedBox(height: Spacing.sm),
                _MetricCard(
                  label: 'Талия',
                  value: '—',
                  unit: 'см',
                  icon: Icons.straighten,
                  trend: null,
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
              ]),
            ),
          ),
        ],
      ),
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
