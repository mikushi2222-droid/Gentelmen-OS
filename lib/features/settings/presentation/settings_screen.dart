import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/ai/ai_advisor_provider.dart';
import 'package:gentleman_os/core/ai/router_ai_config.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/theme_mode_provider.dart';
import 'package:gentleman_os/features/settings/application/settings_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
            trailing: IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Поделиться',
              onPressed: () => _exportAndShare(context, ref),
            ),
            onTap: () => _export(context, ref),
          ),
          const SizedBox(height: Spacing.md),
          Text('Оформление', style: tt.titleSmall),
          const Divider(height: 16),
          Consumer(
            builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Тёмная'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Светлая'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('Система'),
                    ),
                  ],
                  selected: {mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) =>
                      ref.read(themeModeProvider.notifier).set(s.first),
                ),
              );
            },
          ),
          const SizedBox(height: Spacing.md),
          Text('ИИ-советник', style: tt.titleSmall),
          const Divider(height: 16),
          Consumer(
            builder: (context, ref, _) {
              final enabled = ref.watch(aiCloudEnabledProvider);
              return ListTile(
                leading: Icon(
                  enabled ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  color: enabled ? cs.primary : cs.onSurfaceVariant,
                ),
                title: const Text('RouterAI (облачный ИИ)'),
                subtitle: Text(
                  enabled
                      ? 'Подключён · анализ стиля и здоровья через ИИ'
                      : 'Не подключён · работает оффлайн-движок',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAiKeyDialog(context, ref),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bug_report_outlined, color: cs.onSurfaceVariant),
            title: const Text('Журнал отладки'),
            subtitle: const Text('Логи приложения и запросов к ИИ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/logs'),
          ),
          const SizedBox(height: Spacing.md),
          Text('Философия', style: tt.titleSmall),
          const Divider(height: 16),
          _QuoteCard(
            text:
                'Джентльмен — это человек, который никогда не причиняет боли '
                'непреднамеренно.',
            author: 'Оскар Уайльд',
          ),
          _QuoteCard(
            text:
                'Стиль — это способ сказать «кто ты» без необходимости '
                'говорить это словами.',
            author: 'Рейчел Зои',
          ),
          _QuoteCard(
            text:
                'Хорошо одетый мужчина — это тот, чья одежда так подходит, '
                'что её не замечают.',
            author: 'Джон Т. Моллой',
          ),
          const SizedBox(height: Spacing.md),
          Text('Опасная зона', style: tt.titleSmall),
          Divider(height: 16, color: cs.error),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: cs.error),
            title:
                Text('Очистить все данные', style: TextStyle(color: cs.error)),
            subtitle: const Text('Удалить гардероб, образы и историю'),
            onTap: () => _confirmClear(context, ref),
          ),
          const SizedBox(height: Spacing.xl),
          Text('О приложении', style: tt.titleSmall),
          const Divider(height: 16),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Gentleman OS'),
            subtitle: Text('v1.0.0 · Offline · Private · No cloud'),
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Источники вдохновения'),
            subtitle: const Text(
              'Manson «Мужские правила» · Roetzel «Der Gentleman» · Boyer «Как одеть мужчину»',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = await ref.read(exportServiceProvider).exportToFile(dir.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Экспорт сохранён: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $e')),
        );
      }
    }
  }

  Future<void> _exportAndShare(BuildContext context, WidgetRef ref) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = await ref.read(exportServiceProvider).exportToFile(dir.path);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Gentleman OS — резервная копия данных',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  Future<void> _showAiKeyDialog(BuildContext context, WidgetRef ref) async {
    // Читаем конфиг через .future: valueOrNull мог быть null, если
    // FutureProvider ещё не разрезолвился — и поле ключа было бы пустым.
    final cfg = await ref.read(routerAiConfigProvider.future);
    if (!context.mounted) return;
    final keyCtrl = TextEditingController(text: cfg.apiKey ?? '');
    var model = cfg.model;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('RouterAI'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ключ хранится только на устройстве (secure storage) и '
                  'используется для анализа стиля и здоровья.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keyCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API-ключ',
                    hintText: 'sk-...',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: model,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Модель'),
                  items: RouterAiConfig.availableModels
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => model = v ?? model),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await ref.read(routerAiSettingsProvider).clear();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Удалить ключ'),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(routerAiSettingsProvider).save(
                      apiKey: keyCtrl.text,
                      model: model,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
    keyCtrl.dispose();
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить все данные?'),
        content: const Text(
          'Это удалит весь гардероб, образы, замеры и историю. '
          'Знания и достижения будут сохранены. '
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
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(clearAllDataProvider)();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Данные очищены')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              }
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.text, required this.author});

  final String text;
  final String author;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '«$text»',
              style: tt.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '— $author',
              style: tt.labelSmall?.copyWith(color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}
