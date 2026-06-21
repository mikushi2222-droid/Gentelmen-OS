import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          Text('Данные', style: tt.titleSmall),
          const Divider(height: 16),
          ListTile(
            leading: Icon(Icons.upload_outlined, color: cs.primary),
            title: const Text('Экспортировать данные'),
            subtitle: const Text('Сохранить резервную копию (JSON)'),
            onTap: () {
              // TODO: ExportUseCase
            },
          ),
          ListTile(
            leading: Icon(Icons.download_outlined, color: cs.primary),
            title: const Text('Импортировать данные'),
            subtitle: const Text('Восстановить из резервной копии'),
            onTap: () {
              // TODO: ImportUseCase
            },
          ),
          const SizedBox(height: Spacing.md),
          Text('Опасная зона', style: tt.titleSmall),
          Divider(height: 16, color: cs.error),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: cs.error),
            title: Text('Очистить все данные',
                style: TextStyle(color: cs.error)),
            subtitle: const Text('Удалить гардероб, образы и историю'),
            onTap: () => _confirmClear(context),
          ),
          const SizedBox(height: Spacing.xl),
          Text('О приложении', style: tt.titleSmall),
          const Divider(height: 16),
          const ListTile(
            title: Text('Gentleman OS'),
            subtitle: Text('v1.0.0 · Offline · Private'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить все данные?'),
        content: const Text(
          'Это удалит весь гардероб, образы, замеры и историю. '
          'Действие необратимо. Сделайте экспорт перед очисткой.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: ClearAllDataUseCase
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
}
