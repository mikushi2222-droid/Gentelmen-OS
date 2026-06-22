import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/services/services_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';
import 'package:gentleman_os/features/health/application/health_providers.dart';
import 'package:gentleman_os/features/health/domain/health_marker.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final asyncLatest = ref.watch(latestHealthByTypeProvider);
    final asyncIndex = ref.watch(healthIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мужское здоровье'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'ИИ-анализ показателей',
            onPressed: () => _showAiAnalysis(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Внести анализ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          const _HealthDisclaimer(),
          const SizedBox(height: Spacing.md),
          asyncIndex.when(
            loading: () => const SizedBox(
              height: 140,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox(),
            data: (index) => _HealthIndexCard(index: index),
          ),
          const SizedBox(height: Spacing.sectionGap),
          Text('Показатели', style: tt.titleMedium),
          const SizedBox(height: Spacing.sm),
          asyncLatest.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Ошибка: $e'),
            data: (latest) => Column(
              children: HealthMarkerType.values.map((type) {
                final value = latest[type];
                return _MarkerTile(
                  type: type,
                  value: value,
                  onTap: () => context.push('/health/marker/${type.index}'),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddMarkerSheet(ref: ref),
    );
  }

  void _showAiAnalysis(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => const _AiAnalysisSheet(),
    );
  }
}

/// Лист с ИИ-разбором показателей (RouterAI).
class _AiAnalysisSheet extends ConsumerWidget {
  const _AiAnalysisSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(healthAiAnalysisProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (ctx, scrollController) => ListView(
        controller: scrollController,
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
              Text('ИИ-анализ показателей',
                  style: tt.titleMedium?.copyWith(color: AppColors.gold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Повторить',
                onPressed: () => ref.invalidate(healthAiAnalysisProvider),
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
          const SizedBox(height: Spacing.md),
          Text(
            'Не является медицинской рекомендацией. Консультируйтесь с врачом.',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HealthDisclaimer extends StatelessWidget {
  const _HealthDisclaimer();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Не является медицинской рекомендацией. '
              'Интерпретируйте анализы вместе с врачом.',
              style: tt.bodySmall?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthIndexCard extends StatelessWidget {
  const _HealthIndexCard({required this.index});

  final double index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 0.5),
      ),
      padding: const EdgeInsets.all(Spacing.cardPadding),
      child: Row(
        children: [
          ScoreRing(
            score: index,
            size: 96,
            strokeWidth: 7,
            label: 'ЗДОРОВЬЕ',
            color: AppColors.gold,
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Индекс здоровья', style: tt.titleMedium),
                const SizedBox(height: 4),
                Text(
                  index == 0
                      ? 'Внесите анализы, чтобы увидеть оценку'
                      : index >= 70
                          ? 'Большинство маркеров в норме'
                          : index >= 40
                              ? 'Есть на что обратить внимание'
                              : 'Стоит проконсультироваться с врачом',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerTile extends StatelessWidget {
  const _MarkerTile({required this.type, required this.value, this.onTap});

  final HealthMarkerType type;
  final double? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final status =
        value == null ? HealthStatus.unknown : markerStatus(type, value!);
    final color = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        title: Text(type.label, style: tt.bodyMedium),
        subtitle: Text(
          value == null
              ? 'Нет данных'
              : '${_fmt(value!)} ${type.unit} · ${status.label}',
          style: tt.bodySmall?.copyWith(
            color: value == null ? cs.onSurfaceVariant : color,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static Color _statusColor(HealthStatus s) => switch (s) {
        HealthStatus.normal => AppColors.success,
        HealthStatus.warning => AppColors.warning,
        HealthStatus.risk => AppColors.error,
        HealthStatus.unknown => AppColors.textDisabled,
      };
}

class _AddMarkerSheet extends StatefulWidget {
  const _AddMarkerSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddMarkerSheet> createState() => _AddMarkerSheetState();
}

class _AddMarkerSheetState extends State<_AddMarkerSheet> {
  final _valueCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  HealthMarkerType _type = HealthMarkerType.testosteroneTotal;
  final DateTime _date = DateTime.now();

  @override
  void dispose() {
    _valueCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final markerRef = _type.reference;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Новый показатель', style: tt.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<HealthMarkerType>(
            initialValue: _type,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Показатель'),
            items: HealthMarkerType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _type = v);
            },
          ),
          const SizedBox(height: 4),
          Text(
            _type.hint,
            style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _valueCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Значение, ${_type.unit}',
              helperText: markerRef.min != null || markerRef.max != null
                  ? 'Норма: ${markerRef.min ?? '—'}–${markerRef.max ?? '∞'} ${_type.unit}'
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(labelText: 'Заметка (лаборатория и т.п.)'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final value = double.tryParse(_valueCtrl.text.replaceAll(',', '.'));
    if (value == null) return;

    await widget.ref.read(healthDaoProvider).upsert(
          HealthMarkersCompanion(
            id: Value(const Uuid().v4()),
            type: Value(_type.index),
            value: Value(value),
            date: Value(_date),
            note: Value(
              _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            ),
          ),
        );

    // +15 XP за внесение анализа.
    await widget.ref
        .read(xpServiceProvider)
        .healthMarkerLogged(_type.label);

    if (mounted) Navigator.pop(context);
  }
}
