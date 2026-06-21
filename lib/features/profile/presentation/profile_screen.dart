import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редактировать',
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          // Аватар
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.person, size: 48, color: cs.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          _Section(
            title: 'Замеры',
            children: [
              _MeasureRow(label: 'Рост', value: '—', unit: 'см'),
              _MeasureRow(label: 'Вес', value: '—', unit: 'кг'),
              _MeasureRow(label: 'Талия', value: '—', unit: 'см'),
              _MeasureRow(label: 'Грудь', value: '—', unit: 'см'),
              _MeasureRow(label: 'Бёдра', value: '—', unit: 'см'),
              _MeasureRow(label: 'Плечи', value: '—', unit: 'см'),
              _MeasureRow(label: 'Шея', value: '—', unit: 'см'),
              _MeasureRow(label: 'Обувь', value: '—', unit: 'EU'),
            ],
          ),
          const SizedBox(height: Spacing.sectionGap),
          _Section(
            title: 'Рекомендации для вашей фигуры',
            children: [
              _RecommendationCard(
                icon: Icons.straighten,
                text: 'Предпочтительный крой: Regular, Straight, Comfort Fit',
              ),
              _RecommendationCard(
                icon: Icons.format_align_center,
                text: 'Брюки: средняя или высокая посадка',
              ),
              _RecommendationCard(
                icon: Icons.palette_outlined,
                text: 'Приоритет: спокойные нейтральные цвета',
              ),
              _RecommendationCard(
                icon: Icons.texture,
                text: 'Ткань: плотные, матовые, структурированные',
              ),
            ],
          ),
          const SizedBox(height: Spacing.sectionGap),
          _Section(
            title: 'Предпочтения',
            children: [
              _AttrRow(label: 'Стиль', value: '—'),
              _AttrRow(label: 'Цвета', value: '—'),
              _AttrRow(label: 'Бюджет', value: '—'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tt.titleMedium),
        Divider(color: cs.outlineVariant, height: 16),
        ...children,
      ],
    );
  }
}

class _MeasureRow extends StatelessWidget {
  const _MeasureRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Text(
            value == '—' ? '—' : '$value $unit',
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
            width: 100,
            child: Text(label,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: tt.bodyMedium)),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: tt.bodySmall),
          ),
        ],
      ),
    );
  }
}
