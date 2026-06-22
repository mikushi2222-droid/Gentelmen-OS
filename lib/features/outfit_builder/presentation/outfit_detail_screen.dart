import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/models/outfit.dart';

final _outfitDetailProvider =
    FutureProvider.family<(OutfitsData?, List<ClothingItem>), String>(
  (ref, outfitId) async {
    final dao = ref.watch(outfitDaoProvider);
    final outfit = await dao.getById(outfitId);
    if (outfit == null) return (null, []);

    final itemRows = await dao.getItemsForOutfit(outfitId);
    final wardrobeRepo = ref.watch(wardrobeRepositoryProvider);
    final items = <ClothingItem>[];
    for (final row in itemRows) {
      final item = await wardrobeRepo.getById(row.itemId);
      if (item != null) items.add(item);
    }
    return (outfit, items);
  },
);

class OutfitDetailScreen extends ConsumerWidget {
  const OutfitDetailScreen({required this.outfitId, super.key});

  final String outfitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_outfitDetailProvider(outfitId));

    return asyncData.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(child: Text('$e')),
      ),
      data: ((outfit, items)) {
        if (outfit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Образ')),
            body: const Center(child: Text('Образ не найден')),
          );
        }
        return _OutfitBody(outfit: outfit, items: items);
      },
    );
  }
}

class _OutfitBody extends ConsumerWidget {
  const _OutfitBody({required this.outfit, required this.items});

  final OutfitsData outfit;
  final List<ClothingItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    OutfitScore? score;
    try {
      final map = jsonDecode(outfit.scoreBreakdown) as Map<String, dynamic>;
      if (map.isNotEmpty) score = OutfitScore.fromJson(map);
    } catch (_) {}

    final hasBreakdown = score != null &&
        (score.fitScore + score.colorScore + score.occasionScore +
                score.weatherScore + score.comfortScore) >
            0;

    return Scaffold(
      appBar: AppBar(title: Text(outfit.name)),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          Row(
            children: [
              _ScoreCircle(score: outfit.score),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Occasion.values[outfit.occasion].label,
                      style: tt.titleSmall,
                    ),
                    Text(
                      '${items.length} вещей',
                      style:
                          tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sectionGap),
          Text('Вещи образа', style: tt.titleMedium),
          const SizedBox(height: Spacing.sm),
          ...items.map((item) => _ItemRow(item: item)),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _wearAll(context, ref),
                  icon: const Icon(Icons.checkroom_outlined),
                  label: const Text('Надеть весь образ'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/outfits/${outfit.id}/rate'),
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text('Оценить'),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sectionGap),
          Text('Оценка образа', style: tt.titleMedium),
          const SizedBox(height: Spacing.sm),
          if (hasBreakdown) ...[
            _ScoreRow(
                label: 'Посадка (×0.30)',
                value: score!.fitScore),
            _ScoreRow(
                label: 'Повод (×0.25)',
                value: score.occasionScore),
            _ScoreRow(
                label: 'Погода/сезон (×0.20)',
                value: score.weatherScore),
            _ScoreRow(
                label: 'Цветовая гармония (×0.15)',
                value: score.colorScore),
            _ScoreRow(
                label: 'Комфорт (×0.10)',
                value: score.comfortScore),
            const Divider(height: Spacing.lg),
          ],
          _ScoreRow(label: 'Итого', value: outfit.score / 100),
          if (score != null && score.explanation.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text('Детали', style: tt.titleSmall),
            const SizedBox(height: Spacing.sm),
            ...score.explanation.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    Expanded(
                      child: Text(e,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _wearAll(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(wardrobeRepositoryProvider);
    for (final item in items) {
      await repo.incrementWear(item.id);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Отмечено ${items.length} вещей как надетые'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = score >= 70
        ? const Color(0xFF4CAF50)
        : score >= 40
            ? const Color(0xFFFFA726)
            : const Color(0xFFEF5350);

    return CircleAvatar(
      radius: 36,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        score.toStringAsFixed(0),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: item.imagePath != null && File(item.imagePath!).existsSync()
            ? Image.file(File(item.imagePath!), fit: BoxFit.cover)
            : Icon(Icons.checkroom_outlined, color: cs.outline),
      ),
      title: Text(item.name, style: tt.bodyMedium),
      subtitle: Text(
        '${item.category.label} • ${item.fit.label}',
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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
              value: value.clamp(0.0, 1.0),
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
