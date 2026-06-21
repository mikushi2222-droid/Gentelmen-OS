import 'package:flutter/material.dart';
import 'package:gentleman_os/core/constants/spacing.dart';

class OutfitDetailScreen extends StatelessWidget {
  const OutfitDetailScreen({required this.outfitId, super.key});

  final String outfitId;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Образ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Оценить',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          Text('Образ #$outfitId', style: tt.headlineSmall),
          const SizedBox(height: Spacing.md),
          // TODO: вещи образа и разбивка score
          Text('Score breakdown', style: tt.titleSmall),
          const SizedBox(height: Spacing.sm),
          _ScoreRow(label: 'Посадка', value: 0.85),
          _ScoreRow(label: 'Цвет', value: 0.70),
          _ScoreRow(label: 'Повод', value: 0.90),
          _ScoreRow(label: 'Погода', value: 0.80),
          _ScoreRow(label: 'Комфорт', value: 0.75),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pct = (value * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: tt.bodySmall),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: cs.surfaceContainerHighest,
              color: cs.primary,
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$pct%',
              style: tt.labelSmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
