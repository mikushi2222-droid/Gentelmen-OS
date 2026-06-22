import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/biohacking/application/biohacking_providers.dart';
import 'package:gentleman_os/features/biohacking/domain/evidence.dart';
import 'package:gentleman_os/features/biohacking/domain/knowledge_base.dart';
import 'package:gentleman_os/features/biohacking/domain/optimization.dart';

/// Уровень 3 — Биохакинг как система принятия решений: что тормозит прогресс
/// и что даст максимальный эффект. См. docs/16-vision-three-levels-and-biohacking.md.
class BiohackingScreen extends ConsumerWidget {
  const BiohackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(biohackingDomainsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Биохакинг')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (domains) {
          final optimization = optimizationScore(domains);
          final bottle = bottlenecks(domains);
          final actions = maxImpactActions(domains);

          return ListView(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            children: [
              _OptimizationCard(percent: optimization),
              const SizedBox(height: Spacing.sectionGap),
              const _SectionTitle('Узкие места'),
              const SizedBox(height: Spacing.sm),
              ...bottle.map((d) => _BottleneckTile(domain: d)),
              const SizedBox(height: Spacing.sectionGap),
              const _SectionTitle('Что даст максимальный результат'),
              const SizedBox(height: Spacing.sm),
              if (actions.isEmpty)
                Text(
                  'Всё оптимизировано — так держать.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...actions.map((a) => _ImpactTile(action: a)),
              const SizedBox(height: Spacing.sectionGap),
              const _SectionTitle('Протоколы'),
              const SizedBox(height: Spacing.sm),
              ...kProtocols.map((p) => _ProtocolCard(protocol: p)),
              const SizedBox(height: Spacing.sectionGap),
              const _SectionTitle('Добавки'),
              const _Disclaimer(),
              const SizedBox(height: Spacing.sm),
              ...kSupplements.map((s) => _SupplementCard(supplement: s)),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: AppColors.textPrimary),
      );
}

class _OptimizationCard extends StatelessWidget {
  const _OptimizationCard({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Text(
            '$percent%',
            style: tt.displaySmall?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Оптимизация', style: tt.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Сводный показатель по отслеживаемым доменам',
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottleneckTile extends StatelessWidget {
  const _BottleneckTile({required this.domain});

  final OptimizationDomain domain;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pct = (domain.score.clamp(0.0, 1.0) * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(domain.name, style: tt.bodyMedium),
              Text('$pct%',
                  style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: domain.score.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceHigh,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  const _ImpactTile({required this.action});

  final ImpactAction action;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Text(
          '+${action.impactPercent}%',
          style: tt.titleMedium?.copyWith(color: AppColors.gold),
        ),
        title: Text(action.title, style: tt.bodyMedium),
        subtitle: Text(action.reason, style: tt.bodySmall),
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({required this.protocol});

  final Protocol protocol;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(protocol.name, style: tt.titleSmall),
            Text(
              protocol.goal,
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: Spacing.sm),
            ...protocol.steps.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s, style: tt.bodySmall)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplementCard extends StatelessWidget {
  const _SupplementCard({required this.supplement});

  final Supplement supplement;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(supplement.name, style: tt.titleSmall)),
                _EvidenceBadge(rating: supplement.evidence),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            _kv(tt, 'Дозировка', supplement.dose),
            _kv(tt, 'Риски', supplement.risks),
            _kv(tt, 'Взаимодействия', supplement.interactions),
          ],
        ),
      ),
    );
  }

  Widget _kv(TextTheme tt, String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$k: ',
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              TextSpan(text: v, style: tt.bodySmall),
            ],
          ),
        ),
      );
}

class _EvidenceBadge extends StatelessWidget {
  const _EvidenceBadge({required this.rating});

  final EvidenceRating rating;

  @override
  Widget build(BuildContext context) {
    final color = switch (rating) {
      EvidenceRating.a => AppColors.success,
      EvidenceRating.b => AppColors.gold,
      EvidenceRating.c => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        rating.code,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: color),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Text(
          'Образовательный материал, не медицинские назначения. '
          'Решения принимайте с врачом.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      );
}
