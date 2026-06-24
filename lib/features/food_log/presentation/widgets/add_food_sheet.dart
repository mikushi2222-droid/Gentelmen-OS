import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/ai/ai_advisor_provider.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/food_log/application/food_log_providers.dart';
import 'package:gentleman_os/features/food_log/domain/nutrition_ai_result.dart';

/// Bottomsheet для ввода нового приёма пищи.
/// Анализирует описание через RouterAI (если ключ задан), затем сохраняет.
class AddFoodSheet extends ConsumerStatefulWidget {
  const AddFoodSheet({super.key});

  @override
  ConsumerState<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<AddFoodSheet> {
  final _ctrl = TextEditingController();
  MealType _mealType = MealType.lunch;
  NutritionAiResult? _result;
  bool _analyzing = false;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _analyzing = true;
      _result = null;
    });
    final client = ref.read(routerAiClientProvider);
    final r = await analyzeFood(description: text, client: client);
    if (mounted) {
      setState(() {
        _result = r;
        _analyzing = false;
      });
    }
  }

  Future<void> _save() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    await saveFoodEntry(
      dao: ref.read(foodLogDaoProvider),
      description: text,
      mealType: _mealType,
      analysis: _result,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final aiEnabled = ref.watch(aiCloudEnabledProvider);
    final canSave = _ctrl.text.trim().isNotEmpty && !_saving;

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.md,
        right: Spacing.md,
        top: Spacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок
          Row(
            children: [
              Text('Добавить приём пищи',
                  style: tt.titleMedium?.copyWith(color: AppColors.textPrimary)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textSecondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Тип еды
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MealType.values.map((t) {
                final selected = t == _mealType;
                return Padding(
                  padding: const EdgeInsets.only(right: Spacing.xs),
                  child: FilterChip(
                    label: Text(t.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _mealType = t),
                    selectedColor: AppColors.gold.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.gold,
                    labelStyle: tt.labelSmall?.copyWith(
                      color: selected
                          ? AppColors.gold
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Поле описания
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            minLines: 2,
            style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Опишите еду: «Стейк 200г, картошка, салат»',
              hintStyle:
                  tt.bodyMedium?.copyWith(color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Spacing.sm),

          // Результат AI
          if (_analyzing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Анализирую...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          else if (_result != null && _result != NutritionAiResult.empty)
            _AiResultCard(result: _result!),

          const SizedBox(height: Spacing.sm),

          // Кнопки
          Row(
            children: [
              if (aiEnabled) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _ctrl.text.trim().isNotEmpty && !_analyzing
                        ? _analyze
                        : null,
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: const Text('Анализ AI'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
              ],
              Expanded(
                flex: aiEnabled ? 1 : 2,
                child: FilledButton(
                  onPressed: canSave ? _save : null,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiResultCard extends StatelessWidget {
  const _AiResultCard({required this.result});
  final NutritionAiResult result;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high,
                  color: AppColors.gold, size: 14),
              const SizedBox(width: 4),
              Text(
                'AI-оценка (приблизительно)',
                style: tt.labelSmall?.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (result.kcalEstimate != null)
                _InfoChip('~${result.kcalEstimate} kcal'),
              if (result.proteinLevel != null)
                _InfoChip('Protein: ${result.proteinLevel}'),
              if (result.processingLevel != null)
                _InfoChip(result.processingLevel!),
            ],
          ),
          if (result.satietyNote != null) ...[
            const SizedBox(height: 4),
            Text(
              result.satietyNote!,
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (result.insights.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...result.insights.map(
              (s) => Text(
                '• $s',
                style: tt.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
      ),
    );
  }
}
