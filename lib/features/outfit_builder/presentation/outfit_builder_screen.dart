import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/services/achievement_service.dart';
import 'package:gentleman_os/core/services/services_provider.dart';
import 'package:gentleman_os/core/services/xp_service.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';
import 'package:gentleman_os/features/outfit_builder/application/outfit_providers.dart';
import 'package:gentleman_os/features/outfit_builder/domain/outfit_generator.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/enums/weather_condition.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  ConsumerState<OutfitBuilderScreen> createState() =>
      _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends ConsumerState<OutfitBuilderScreen> {
  Occasion _occasion = Occasion.everyday;
  DressCode _dressCode = DressCode.casual;
  Season _season = Season.all;
  WeatherCondition? _weather;
  OutfitParams? _params;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подобрать образ')),
      body: _params != null
          ? _ResultView(
              params: _params!,
              onReset: () => setState(() => _params = null),
            )
          : _FormView(
              occasion: _occasion,
              dressCode: _dressCode,
              season: _season,
              weather: _weather,
              onOccasionChanged: (v) => setState(() => _occasion = v),
              onDressCodeChanged: (v) => setState(() => _dressCode = v),
              onSeasonChanged: (v) => setState(() => _season = v),
              onWeatherChanged: (v) => setState(() => _weather = v),
              onGenerate: () => setState(
                () => _params = OutfitParams(
                  occasion: _occasion,
                  dressCode: _dressCode,
                  season: _season,
                  weather: _weather,
                ),
              ),
            ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.occasion,
    required this.dressCode,
    required this.season,
    required this.weather,
    required this.onOccasionChanged,
    required this.onDressCodeChanged,
    required this.onSeasonChanged,
    required this.onWeatherChanged,
    required this.onGenerate,
  });

  final Occasion occasion;
  final DressCode dressCode;
  final Season season;
  final WeatherCondition? weather;
  final ValueChanged<Occasion> onOccasionChanged;
  final ValueChanged<DressCode> onDressCodeChanged;
  final ValueChanged<Season> onSeasonChanged;
  final ValueChanged<WeatherCondition?> onWeatherChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      children: [
        Text('Параметры образа', style: tt.titleMedium),
        const SizedBox(height: Spacing.md),
        _EnumSelector<Occasion>(
          label: 'Повод',
          values: Occasion.values,
          selected: occasion,
          labelOf: (v) => v.label,
          onSelected: onOccasionChanged,
        ),
        const SizedBox(height: Spacing.md),
        _EnumSelector<DressCode>(
          label: 'Дресс-код',
          values: DressCode.values,
          selected: dressCode,
          labelOf: (v) => v.label,
          onSelected: onDressCodeChanged,
        ),
        const SizedBox(height: Spacing.md),
        _EnumSelector<Season>(
          label: 'Сезон',
          values: Season.values,
          selected: season,
          labelOf: (v) => v.label,
          onSelected: onSeasonChanged,
        ),
        const SizedBox(height: Spacing.md),
        _WeatherSelector(
          selected: weather,
          onSelected: onWeatherChanged,
        ),
        const SizedBox(height: Spacing.xl),
        FilledButton.icon(
          onPressed: onGenerate,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Подобрать образы'),
        ),
      ],
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.params, required this.onReset});

  final OutfitParams params;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final asyncSuggestions = ref.watch(outfitSuggestionsProvider(params));

    return asyncSuggestions.when(
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Подбираем образы...'),
          ],
        ),
      ),
      error: (e, _) => Center(child: Text('Ошибка: $e')),
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checkroom_outlined, size: 64, color: cs.outline),
                const SizedBox(height: 16),
                Text(
                  'Образы не найдены',
                  style: tt.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Добавьте больше вещей в гардероб:\nнужны верхние и нижние части одежды',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Изменить параметры'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          children: [
            Text('Подобранные образы', style: tt.titleMedium),
            const SizedBox(height: Spacing.md),
            ...suggestions.asMap().entries.map(
              (e) => _SuggestionCard(
                suggestion: e.value,
                index: e.key + 1,
                params: params,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Изменить параметры'),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestionCard extends ConsumerWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.index,
    required this.params,
  });

  final OutfitSuggestion suggestion;
  final int index;
  final OutfitParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final score = suggestion.score.totalScaled;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ScoreRing(
                  score: score,
                  size: 72,
                  strokeWidth: 6,
                  label: 'SCORE',
                  color: _scoreColor(score),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Вариант $index', style: tt.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        '${suggestion.items.length} предметов',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => _saveDialog(context, ref),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Сохранить'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            _ItemsRow(items: suggestion.items),
            if (suggestion.score.explanation.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              ExpansionTile(
                title: Text('Объяснение',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                children: suggestion.score.explanation
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ',
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                            Expanded(
                              child: Text(e,
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant)),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  void _saveDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: 'Образ $index');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сохранить образ'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Название'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await saveOutfitSuggestion(
                suggestion: suggestion,
                name: ctrl.text.trim().isEmpty ? 'Образ $index' : ctrl.text.trim(),
                params: params,
                dao: ref.read(outfitDaoProvider),
                xpService: ref.read(xpServiceProvider),
              );
              await ref
                  .read(achievementServiceProvider)
                  .checkAfterOutfitSave();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Образ сохранён')),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class _ItemsRow extends StatelessWidget {
  const _ItemsRow({required this.items});

  final List<ClothingItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final item = items[i];
          return Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.imagePath != null
                    ? Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          _categoryIcon(item.category),
                          color: cs.outline,
                          size: 28,
                        ),
                      )
                    : Icon(
                        _categoryIcon(item.category),
                        color: cs.outline,
                        size: 28,
                      ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 56,
                child: Text(
                  item.category.label,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _categoryIcon(ClothingCategory c) => switch (c) {
        ClothingCategory.shirt ||
        ClothingCategory.tshirt ||
        ClothingCategory.polo =>
          Icons.dry_cleaning,
        ClothingCategory.trousers ||
        ClothingCategory.jeans ||
        ClothingCategory.shorts =>
          Icons.straighten,
        ClothingCategory.shoes => Icons.do_not_step,
        ClothingCategory.jacket ||
        ClothingCategory.coat ||
        ClothingCategory.blazer =>
          Icons.checkroom,
        _ => Icons.checkroom_outlined,
      };
}

class _EnumSelector<T extends Enum> extends StatelessWidget {
  const _EnumSelector({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.bodySmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: values
              .map(
                (v) => ChoiceChip(
                  label: Text(labelOf(v)),
                  selected: v == selected,
                  onSelected: (_) => onSelected(v),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _WeatherSelector extends StatelessWidget {
  const _WeatherSelector({this.selected, this.onSelected});

  final WeatherCondition? selected;
  final ValueChanged<WeatherCondition?>? onSelected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Погода (необязательно)', style: tt.bodySmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Не задано'),
              selected: selected == null,
              onSelected: (_) => onSelected?.call(null),
            ),
            ...WeatherCondition.values.map(
              (v) => ChoiceChip(
                label: Text(v.label),
                selected: v == selected,
                onSelected: (_) =>
                    onSelected?.call(selected == v ? null : v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
