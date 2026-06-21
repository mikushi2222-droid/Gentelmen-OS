import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вещь'),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/wardrobe/$itemId/edit'),
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
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(Icons.checkroom,
                  size: 96, color: cs.outlineVariant),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text('Вещь #$itemId', style: tt.headlineSmall),
          const SizedBox(height: Spacing.md),
          // TODO: показывать атрибуты из репозитория
          _AttrRow(label: 'Категория', value: '—'),
          _AttrRow(label: 'Бренд', value: '—'),
          _AttrRow(label: 'Размер', value: '—'),
          _AttrRow(label: 'Цвет', value: '—'),
          _AttrRow(label: 'Материал', value: '—'),
          _AttrRow(label: 'Сезон', value: '—'),
          _AttrRow(label: 'Посадка', value: '—'),
          _AttrRow(label: 'Состояние', value: '—'),
          _AttrRow(label: 'Цена', value: '—'),
          _AttrRow(label: 'Носок', value: '— раз'),
          _AttrRow(label: 'Cost-per-wear', value: '—'),
          const SizedBox(height: Spacing.xl),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: добавить WearLog
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
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
              // TODO: удалить через репозиторий
            },
            child: const Text('Удалить'),
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
            width: 120,
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
