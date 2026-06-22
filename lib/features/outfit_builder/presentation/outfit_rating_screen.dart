import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/features/outfit_builder/application/outfit_providers.dart';

class OutfitRatingScreen extends ConsumerStatefulWidget {
  const OutfitRatingScreen({required this.outfitId, super.key});

  final String outfitId;

  @override
  ConsumerState<OutfitRatingScreen> createState() => _OutfitRatingScreenState();
}

class _OutfitRatingScreenState extends ConsumerState<OutfitRatingScreen> {
  int _rating = 0;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  Future<void> _loadExisting() async {
    final dao = ref.read(outfitDaoProvider);
    final outfit = await dao.getById(widget.outfitId);
    if (outfit?.notes == null || !mounted) return;
    try {
      final map = jsonDecode(outfit!.notes!) as Map<String, dynamic>;
      setState(() {
        _rating = (map['rating'] as int?) ?? 0;
        _noteCtrl.text = (map['note'] as String?) ?? '';
      });
    } catch (_) {
      _noteCtrl.text = outfit!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Оценка образа')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Оцените образ', style: tt.titleMedium),
            const SizedBox(height: Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: starIndex <= _rating
                        ? AppColors.gold
                        : cs.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _rating = starIndex),
                );
              }),
            ),
            if (_rating > 0)
              Center(
                child: Text(
                  _ratingLabel(_rating),
                  style: tt.bodyMedium?.copyWith(color: AppColors.gold),
                ),
              ),
            const SizedBox(height: Spacing.sectionGap),
            Text('Заметка', style: tt.titleSmall),
            const SizedBox(height: Spacing.sm),
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Как ощущался образ? Что можно улучшить?',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _rating == 0 || _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сохранить оценку'),
              ),
            ),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final dao = ref.read(outfitDaoProvider);
      final outfit = await dao.getById(widget.outfitId);
      if (outfit == null) return;

      final notes = jsonEncode({
        'rating': _rating,
        'note': _noteCtrl.text.trim(),
      });
      await dao.updateNotes(widget.outfitId, notes);

      // Blend user rating into the AI score (70% original, 30% user)
      final adjustedScore =
          outfit.score * 0.7 + (_rating / 5 * 100) * 0.3;
      await dao.updateScore(widget.outfitId, adjustedScore);

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _ratingLabel(int rating) => switch (rating) {
        1 => 'Не понравилось',
        2 => 'Средне',
        3 => 'Нормально',
        4 => 'Хорошо',
        _ => 'Отлично!',
      };
}
