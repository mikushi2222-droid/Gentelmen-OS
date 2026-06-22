import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/wardrobe/application/clothing_ai_providers.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/features/wardrobe/application/wear_forecast_providers.dart';
import 'package:gentleman_os/features/wardrobe/domain/wear_forecast.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItem = ref.watch(wardrobeItemProvider(itemId));

    return asyncItem.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(child: Text('$e')),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Вещь')),
            body: const Center(child: Text('Вещь не найдена')),
          );
        }
        return _ItemBody(item: item, ref: ref);
      },
    );
  }
}

class _ItemBody extends StatelessWidget {
  const _ItemBody({required this.item, required this.ref});

  final ClothingItem item;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = NumberFormat.currency(locale: 'ru', symbol: '₽', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/wardrobe/${item.id}/edit'),
          ),
          IconButton(
            tooltip: 'Удалить',
            icon: Icon(Icons.delete_outline, color: cs.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          _HeroImage(imagePath: item.imagePath),
          const SizedBox(height: Spacing.md),
          _WearForecastCard(itemId: item.id),
          const SizedBox(height: Spacing.sm),
          Text(item.name, style: tt.headlineSmall),
          if (item.brand != null) ...[
            const SizedBox(height: 4),
            Text(
              item.brand!,
              style: tt.titleMedium?.copyWith(color: AppColors.gold),
            ),
          ],
          const SizedBox(height: Spacing.md),
          _AttrRow(label: 'Категория', value: item.category.label),
          if (item.size != null) _AttrRow(label: 'Размер', value: item.size!),
          if (item.color != null) _AttrRow(label: 'Цвет', value: item.color!),
          if (item.material != null) _AttrRow(label: 'Материал', value: item.material!),
          _AttrRow(label: 'Сезон', value: item.season.label),
          _AttrRow(label: 'Посадка', value: item.fit.label),
          _AttrRow(label: 'Состояние', value: item.condition.label),
          if (item.price != null) _AttrRow(label: 'Цена', value: fmt.format(item.price)),
          _AttrRow(label: 'Носок', value: '${item.wearCount} раз'),
          if (item.costPerWear != null)
            _AttrRow(label: 'Стоимость носки', value: fmt.format(item.costPerWear)),
          if (item.rating != null)
            _AttrRow(
              label: 'Удобство',
              value: '${'★' * item.rating!}${'☆' * (5 - item.rating!)}',
            ),
          if (item.notes != null) ...[
            const SizedBox(height: Spacing.md),
            Text('Заметка', style: tt.titleSmall),
            const SizedBox(height: 4),
            Text(item.notes!, style: tt.bodyMedium),
          ],
          const SizedBox(height: Spacing.xl),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(wardrobeRepositoryProvider).incrementWear(item.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Носка отмечена')),
                );
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Отметить носку'),
          ),
          if (item.imagePath != null) ...[
            const SizedBox(height: Spacing.sm),
            FilledButton.tonalIcon(
              onPressed: () => _showPhotoAnalysis(context, item),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('ИИ-анализ фото'),
            ),
          ],
        ],
      ),
    );
  }

  void _showPhotoAnalysis(BuildContext context, ClothingItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _PhotoAnalysisSheet(item: item),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить вещь?'),
        content: const Text('Вещь будет удалена из гардероба.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(wardrobeRepositoryProvider).delete(item.id);
              if (context.mounted) context.pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imagePath != null) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(file, height: 280, width: double.infinity, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(Icons.checkroom, size: 96, color: cs.outlineVariant),
      ),
    );
  }
}

class _PhotoAnalysisSheet extends ConsumerWidget {
  const _PhotoAnalysisSheet({required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(clothingPhotoAnalysisProvider(item));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (ctx, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(
          Spacing.screenPadding,
          0,
          Spacing.screenPadding,
          Spacing.screenPadding,
        ),
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('ИИ-анализ фото',
                  style: tt.titleMedium?.copyWith(color: AppColors.gold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Повторить',
                onPressed: () =>
                    ref.invalidate(clothingPhotoAnalysisProvider(item)),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                e is RouterAiException ? e.message : '$e',
                style: tt.bodyMedium?.copyWith(color: AppColors.warning),
              ),
            ),
            data: (text) => Text(text, style: tt.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _WearForecastCard extends ConsumerWidget {
  const _WearForecastCard({required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncForecast = ref.watch(wearForecastProvider(itemId));

    return asyncForecast.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (forecast) {
        final (bg, fg, icon, label) = _style(forecast);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      forecast.headline,
                      style: TextStyle(
                        fontSize: 15,
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (forecast.detail != null)
                      Text(
                        forecast.detail!,
                        style: TextStyle(
                          fontSize: 12,
                          color: fg.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static (Color bg, Color fg, IconData icon, String label) _style(
      WearForecast f) =>
      switch (f.urgency) {
        WearUrgency.today => (
            AppColors.gold.withValues(alpha: 0.15),
            AppColors.gold,
            Icons.wb_sunny_outlined,
            'ПРОГНОЗ НОСКИ',
          ),
        WearUrgency.soon => (
            AppColors.success.withValues(alpha: 0.12),
            AppColors.success,
            Icons.schedule_outlined,
            'ПРОГНОЗ НОСКИ',
          ),
        WearUrgency.onRotation => (
            const Color(0xFF2D3748),
            const Color(0xFFB0BEC5),
            Icons.check_circle_outline,
            'ПРОГНОЗ НОСКИ',
          ),
        WearUrgency.offSeason => (
            const Color(0xFF2D3748),
            const Color(0xFF718096),
            Icons.ac_unit_outlined,
            'ПРОГНОЗ НОСКИ',
          ),
        WearUrgency.retired => (
            const Color(0xFF2D3748),
            const Color(0xFF718096),
            Icons.block_outlined,
            'СТАТУС',
          ),
      };
}

class _AttrRow extends StatelessWidget {
  const _AttrRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value, style: tt.bodyMedium)),
        ],
      ),
    );
  }
}
