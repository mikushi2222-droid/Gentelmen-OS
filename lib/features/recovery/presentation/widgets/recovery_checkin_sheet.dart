import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/recovery/application/recovery_providers.dart';
import 'package:gentleman_os/features/recovery/domain/recovery_state.dart';

/// Bottomsheet: ежедневный чек-ин самочувствия.
/// Заполняет поля из существующей записи (если уже был check-in сегодня).
class RecoveryCheckInSheet extends ConsumerStatefulWidget {
  const RecoveryCheckInSheet({super.key});

  @override
  ConsumerState<RecoveryCheckInSheet> createState() =>
      _RecoveryCheckInSheetState();
}

class _RecoveryCheckInSheetState
    extends ConsumerState<RecoveryCheckInSheet> {
  int? _energy;
  int? _hunger;
  int? _stress;
  double? _sleep;
  int? _water;
  String? _existingId;
  bool _saving = false;

  final _sleepCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill from today's record if it exists.
    final existing = ref.read(todayRecoveryProvider).asData?.value;
    if (existing != null) {
      _existingId = existing.id;
      _energy = existing.energyLevel;
      _hunger = existing.hungerLevel;
      _stress = existing.stressLevel;
      _sleep = existing.sleepHours;
      _water = existing.waterMl;
      if (existing.sleepHours != null) {
        _sleepCtrl.text = existing.sleepHours!.toString();
      }
      if (existing.waterMl != null) {
        _waterCtrl.text = existing.waterMl!.toString();
      }
    }
  }

  @override
  void dispose() {
    _sleepCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await saveRecoveryEntry(
      dao: ref.read(recoveryDaoProvider),
      existingId: _existingId,
      energyLevel: _energy,
      hungerLevel: _hunger,
      sleepHours: _sleep,
      stressLevel: _stress,
      waterMl: _water,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final preview = computeRecoveryState(
      // Строим временный объект только для превью статуса
      _energy != null || _stress != null || _sleep != null
          ? _FakeRecovery(
              energy: _energy,
              stress: _stress,
              sleep: _sleep,
            )
          : null,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.md,
        right: Spacing.md,
        top: Spacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Самочувствие сегодня',
                    style: tt.titleMedium
                        ?.copyWith(color: AppColors.textPrimary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),

            // Превью статуса
            if (_energy != null || _stress != null || _sleep != null)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: _StatePreview(state: preview),
              ),

            _LevelRow(
              label: 'Энергия',
              sublabel: '1 = истощён · 5 = отлично',
              value: _energy,
              color: AppColors.success,
              onChanged: (v) => setState(() => _energy = v),
            ),
            _LevelRow(
              label: 'Голод',
              sublabel: '1 = нет аппетита · 5 = сильный',
              value: _hunger,
              color: AppColors.warning,
              onChanged: (v) => setState(() => _hunger = v),
            ),
            _LevelRow(
              label: 'Стресс',
              sublabel: '1 = спокойно · 5 = высокий',
              value: _stress,
              color: AppColors.error,
              onChanged: (v) => setState(() => _stress = v),
            ),
            const SizedBox(height: Spacing.sm),

            // Сон и вода
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _sleepCtrl,
                    label: 'Сон (ч)',
                    hint: '7.5',
                    onChanged: (v) => _sleep = double.tryParse(v),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _NumberField(
                    controller: _waterCtrl,
                    label: 'Вода (мл)',
                    hint: '2000',
                    onChanged: (v) => _water = int.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.background,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final String sublabel;
  final int? value;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
          Text(sublabel,
              style: tt.labelSmall?.copyWith(
                  color: AppColors.textDisabled, fontSize: 10)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (i) {
              final v = i + 1;
              final selected = value == v;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => onChanged(v),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.25)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              selected ? color : AppColors.outline,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$v',
                        style: tt.titleSmall?.copyWith(
                          color: selected ? color : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: tt.bodyMedium
                ?.copyWith(color: AppColors.textDisabled),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _StatePreview extends StatelessWidget {
  const _StatePreview({required this.state});
  final RecoveryState state;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = switch (state) {
      RecoveryState.optimal => AppColors.success,
      RecoveryState.stable => AppColors.gold,
      RecoveryState.mildFatigue => AppColors.warning,
      RecoveryState.stressElevated => AppColors.error,
      RecoveryState.recoveryNeeded => AppColors.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.radio_button_checked, color: color, size: 12),
          const SizedBox(width: 8),
          Text(state.label,
              style: tt.labelMedium?.copyWith(color: color)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(state.guidance,
                style: tt.labelSmall
                    ?.copyWith(color: AppColors.textSecondary, fontSize: 10),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// Temporary holder for preview computation — avoids creating a DB row.
class _FakeRecovery implements RecoveryLogsData {
  _FakeRecovery({
    required int? energy,
    required int? stress,
    required double? sleep,
  })  : energyLevel = energy,
        stressLevel = stress,
        sleepHours = sleep;

  @override
  final int? energyLevel;
  @override
  final int? stressLevel;
  @override
  final double? sleepHours;

  @override
  String get id => '';
  @override
  DateTime get date => DateTime.now();
  @override
  int? get hungerLevel => null;
  @override
  int? get waterMl => null;
  @override
  int? get steps => null;
  @override
  String? get notes => null;
}
