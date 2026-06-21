import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/condition.dart';
import 'package:gentleman_os/shared/enums/fit.dart';
import 'package:gentleman_os/shared/enums/season.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({this.itemId, super.key});

  final String? itemId;

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _materialCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  ClothingCategory _category = ClothingCategory.shirt;
  Season _season = Season.all;
  Fit _fit = Fit.regular;
  Condition _condition = Condition.brandNew;
  int? _rating;

  bool get _isEdit => widget.itemId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _sizeCtrl.dispose();
    _colorCtrl.dispose();
    _materialCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Редактировать вещь' : 'Новая вещь'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          children: [
            _PhotoPicker(),
            const SizedBox(height: Spacing.lg),
            Text('Основные', style: tt.titleSmall),
            const SizedBox(height: Spacing.sm),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Название*'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Обязательное поле' : null,
            ),
            const SizedBox(height: Spacing.sm),
            _EnumDropdown<ClothingCategory>(
              label: 'Категория',
              value: _category,
              values: ClothingCategory.values,
              labelOf: (v) => v.label,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: Spacing.sm),
            TextFormField(
              controller: _brandCtrl,
              decoration: const InputDecoration(labelText: 'Бренд'),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeCtrl,
                    decoration: const InputDecoration(labelText: 'Размер'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _colorCtrl,
                    decoration: const InputDecoration(labelText: 'Цвет'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Text('Характеристики', style: tt.titleSmall),
            const SizedBox(height: Spacing.sm),
            TextFormField(
              controller: _materialCtrl,
              decoration: const InputDecoration(labelText: 'Материал'),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: _EnumDropdown<Season>(
                    label: 'Сезон',
                    value: _season,
                    values: Season.values,
                    labelOf: (v) => v.label,
                    onChanged: (v) => setState(() => _season = v),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _EnumDropdown<Fit>(
                    label: 'Посадка',
                    value: _fit,
                    values: Fit.values,
                    labelOf: (v) => v.label,
                    onChanged: (v) => setState(() => _fit = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: _EnumDropdown<Condition>(
                    label: 'Состояние',
                    value: _condition,
                    values: Condition.values,
                    labelOf: (v) => v.label,
                    onChanged: (v) => setState(() => _condition = v),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Цена, ₽',
                      prefixText: '₽ ',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            _RatingRow(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: Spacing.sm),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Заметка'),
            ),
            const SizedBox(height: Spacing.xl),
            FilledButton(
              onPressed: _save,
              child: Text(_isEdit ? 'Сохранить изменения' : 'Добавить в гардероб'),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: сохранить через WardrobeRepository
    Navigator.of(context).pop();
  }
}

class _PhotoPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        // TODO: image_picker
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 48, color: cs.outline),
            const SizedBox(height: 8),
            Text('Добавить фото',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((v) => DropdownMenuItem(value: v, child: Text(labelOf(v))))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({this.value, this.onChanged});

  final int? value;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Text('Удобство:', style: tt.bodyMedium),
        const SizedBox(width: 12),
        ...List.generate(
          5,
          (i) => GestureDetector(
            onTap: () => onChanged?.call(i + 1 == value ? null : i + 1),
            child: Icon(
              i < (value ?? 0) ? Icons.star : Icons.star_border,
              color: cs.primary,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}
