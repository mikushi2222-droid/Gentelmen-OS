import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';
import 'package:gentleman_os/shared/enums/dress_code.dart';
import 'package:gentleman_os/shared/enums/occasion.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/enums/weather_condition.dart';

class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  ConsumerState<OutfitBuilderScreen> createState() =>
      _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState
    extends ConsumerState<OutfitBuilderScreen> {
  Occasion _occasion = Occasion.everyday;
  DressCode _dressCode = DressCode.casual;
  Season _season = Season.all;
  WeatherCondition? _weather;
  int? _temperatureC;
  bool _generated = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Подобрать образ')),
      body: _generated ? _ResultView(onReset: () => setState(() => _generated = false))
          : _FormView(
              occasion: _occasion,
              dressCode: _dressCode,
              season: _season,
              weather: _weather,
              onOccasionChanged: (v) => setState(() => _occasion = v),
              onDressCodeChanged: (v) => setState(() => _dressCode = v),
              onSeasonChanged: (v) => setState(() => _season = v),
              onWeatherChanged: (v) => setState(() => _weather = v),
              onGenerate: () => setState(() => _generated = true),
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

class _ResultView extends StatelessWidget {
  const _ResultView({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      children: [
        Text('Подобранные образы', style: tt.titleMedium),
        const SizedBox(height: Spacing.md),
        // TODO: реальные результаты из OutfitGenerator
        _SuggestionCard(index: 1, score: 87),
        _SuggestionCard(index: 2, score: 74),
        _SuggestionCard(index: 3, score: 62),
        const SizedBox(height: Spacing.lg),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          label: const Text('Изменить параметры'),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.index, required this.score});

  final int index;
  final double score;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Row(
          children: [
            ScoreRing(score: score, size: 72, strokeWidth: 6, label: 'SCORE'),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Вариант $index', style: tt.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Нажмите для подробностей',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
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
