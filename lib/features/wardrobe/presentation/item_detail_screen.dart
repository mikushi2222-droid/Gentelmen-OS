import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
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
        ],
      ),
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
