import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/utils/image_storage.dart';
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
    final wearForecast = garmentWearForecast(
      category: item.category,
      wearCount: item.wearCount,
      material: item.material,
      wearsPerMonth: wearsPerMonthSince(
        purchaseDate: item.purchaseDate,
        wearCount: item.wearCount,
      ),
    );

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
          const SizedBox(height: Spacing.lg),
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
          const SizedBox(height: Spacing.md),
          _WearForecastCard(forecast: wearForecast),
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
              ref.invalidate(wardrobeItemProvider(item.id));
              ref.invalidate(lastWornAtProvider(item.id));
              ref.invalidate(wearForecastProvider(item.id));
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
              await deleteWardrobeImage(item.imagePath);
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

    final placeholder = Container(
      height: 280,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(Icons.checkroom, size: 96, color: cs.outlineVariant),
      ),
    );

    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(imagePath!),
          height: 280,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder,
        ),
      );
    }
    return placeholder;
  }
}

class _PhotoAnalysisSheet extends ConsumerWidget {
  const _PhotoAnalysisSheet({required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
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
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.gold),
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

/// Карточка прогноза износа: процент, полоса прогресса и объяснение.
/// Цвет шкалы меняется от «спокойного» к тревожному по мере износа.
class _WearForecastCard extends StatelessWidget {
  const _WearForecastCard({required this.forecast});

  final WearForecast forecast;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pct = forecast.wearPercent;
    final color = pct >= 80
        ? AppColors.error
        : pct >= 50
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timelapse, size: 18, color: color),
              const SizedBox(width: 8),
              Text('Прогноз износа', style: tt.titleSmall),
              const Spacer(),
              Text(
                '${forecast.statusLabel} · $pct%',
                style: tt.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: forecast.wearFraction,
              minHeight: 8,
              backgroundColor: AppColors.outline,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          for (final line in forecast.explanation)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• $line',
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
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
