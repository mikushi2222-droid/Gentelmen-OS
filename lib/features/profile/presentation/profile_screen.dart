import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/features/profile/application/profile_providers.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final asyncProfile = ref.watch(profileProvider);

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
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (profile) => _ProfileBody(profile: profile),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({this.profile});

  final UserProfileModel? profile;

  String _fmt(double v, {int digits = 0}) =>
      v == 0 ? '—' : v.toStringAsFixed(digits);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = profile;

    final budgetLabels = ['Бюджетный', 'Средний', 'Премиум'];

    return ListView(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.person, size: 48, color: cs.onPrimaryContainer),
          ),
        ),
        if (p != null && !p.isFilled) ...[
          const SizedBox(height: Spacing.md),
          Card(
            color: cs.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: cs.onTertiaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Заполните замеры, чтобы получить персональные рекомендации',
                      style: tt.bodySmall?.copyWith(color: cs.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: Spacing.lg),
        _Section(
          title: 'Замеры',
          children: [
            _MeasureRow(label: 'Рост', value: _fmt(p?.height ?? 0), unit: 'см'),
            _MeasureRow(label: 'Вес', value: _fmt(p?.weight ?? 0), unit: 'кг'),
            if (p?.bmi != null)
              _MeasureRow(
                label: 'ИМТ',
                value: p!.bmi!.toStringAsFixed(1),
                unit: p.bmiCategory,
              ),
            _MeasureRow(label: 'Талия', value: _fmt(p?.waist ?? 0), unit: 'см'),
            _MeasureRow(label: 'Грудь', value: _fmt(p?.chest ?? 0), unit: 'см'),
            _MeasureRow(label: 'Бёдра', value: _fmt(p?.hips ?? 0), unit: 'см'),
            _MeasureRow(label: 'Плечи', value: _fmt(p?.shoulders ?? 0), unit: 'см'),
            _MeasureRow(label: 'Шея', value: _fmt(p?.neck ?? 0), unit: 'см'),
            _MeasureRow(label: 'Обувь', value: _fmt(p?.shoeSize ?? 0, digits: 0), unit: 'EU'),
          ],
        ),
        const SizedBox(height: Spacing.sectionGap),
        _Section(
          title: 'Рекомендации для вашей фигуры',
          children: _buildRecs(p),
        ),
        const SizedBox(height: Spacing.sectionGap),
        _Section(
          title: 'Предпочтения',
          children: [
            _AttrRow(
              label: 'Стиль',
              value: p == null || p.stylePreferences.isEmpty
                  ? '—'
                  : p.stylePreferences.join(', '),
            ),
            _AttrRow(
              label: 'Цвета',
              value: p == null || p.colorPreferences.isEmpty
                  ? '—'
                  : p.colorPreferences.join(', '),
            ),
            _AttrRow(
              label: 'Бюджет',
              value: budgetLabels[p?.budgetTier ?? 1],
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildRecs(UserProfileModel? p) {
    if (p == null || !p.isFilled) {
      return [
        const _RecommendationCard(
          icon: Icons.lock_outline,
          text: 'Заполните замеры для персональных советов',
        ),
      ];
    }

    final recs = <_RecommendationCard>[];

    if (p.isLargeFrame) {
      recs.addAll([
        const _RecommendationCard(
          icon: Icons.straighten,
          text: 'Крой: Regular, Straight или Comfort Fit — избегайте Slim',
        ),
        const _RecommendationCard(
          icon: Icons.format_align_center,
          text: 'Брюки: средняя или высокая посадка',
        ),
        const _RecommendationCard(
          icon: Icons.texture,
          text: 'Ткань: плотные, матовые, структурированные',
        ),
        const _RecommendationCard(
          icon: Icons.block,
          text: 'Избегайте: атлас, полиэстер, блестящие ткани',
        ),
      ]);
    } else {
      recs.addAll([
        const _RecommendationCard(
          icon: Icons.straighten,
          text: 'Крой: любой, экспериментируйте с силуэтом',
        ),
        const _RecommendationCard(
          icon: Icons.palette_outlined,
          text: 'Больше возможностей в цвете и фактуре',
        ),
      ]);
    }

    recs.add(const _RecommendationCard(
      icon: Icons.palette_outlined,
      text: 'Нейтральные цвета — основа, 1-2 акцента',
    ));

    return recs;
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
          Expanded(child: Text(text, style: tt.bodySmall)),
        ],
      ),
    );
  }
}
