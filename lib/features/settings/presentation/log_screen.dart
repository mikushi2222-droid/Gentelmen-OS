import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Экран журнала отладки: показывает последние записи [AppLogger],
/// обновляется в реальном времени, позволяет скопировать/очистить лог.
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  LogLevel? _filter;

  @override
  void initState() {
    super.initState();
    log.addListener(_onLog);
  }

  @override
  void dispose() {
    log.removeListener(_onLog);
    super.dispose();
  }

  void _onLog() {
    if (mounted) setState(() {});
  }

  /// Пишет весь журнал в .md-файл и открывает системный «Поделиться».
  Future<void> _exportMarkdown() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ts =
          DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final file = File('${dir.path}/gentleman-os-log-$ts.md');
      await file.writeAsString(log.dumpMarkdown());
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Gentleman OS — журнал отладки',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка экспорта: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final all = log.entries.toList().reversed.toList();
    final entries =
        _filter == null ? all : all.where((e) => e.level == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал отладки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Выгрузить в .md',
            onPressed: _exportMarkdown,
          ),
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Скопировать',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: log.dumpText()));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Лог скопирован')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Очистить',
            onPressed: () => log.clear(),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.screenPadding, vertical: 8),
              children: [
                _FilterChip(
                  label: 'Все',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                ...LogLevel.values.map(
                  (l) => _FilterChip(
                    label: l.label,
                    selected: _filter == l,
                    onTap: () => setState(() => _filter = l),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text('Записей нет',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(Spacing.sm),
                    itemCount: entries.length,
                    itemBuilder: (ctx, i) => _LogTile(entry: entries[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.level) {
      LogLevel.debug => AppColors.textSecondary,
      LogLevel.info => AppColors.success,
      LogLevel.warning => AppColors.warning,
      LogLevel.error => AppColors.error,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, right: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              entry.formatted,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: cs.primaryContainer,
      ),
    );
  }
}
