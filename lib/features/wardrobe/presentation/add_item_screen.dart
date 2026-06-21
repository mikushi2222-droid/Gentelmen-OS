import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/services/services_provider.dart';
import 'package:gentleman_os/core/utils/image_storage.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/condition.dart';
import 'package:gentleman_os/shared/enums/fit.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:uuid/uuid.dart';

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
  String? _imagePath;
  bool _saving = false;

  ClothingItem? _original;
  bool get _isEdit => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadItem());
    }
  }

  Future<void> _loadItem() async {
    final item = await ref
        .read(wardrobeRepositoryProvider)
        .getById(widget.itemId!);
    if (item != null && mounted) {
      setState(() {
        _original = item;
        _nameCtrl.text = item.name;
        _brandCtrl.text = item.brand ?? '';
        _sizeCtrl.text = item.size ?? '';
        _colorCtrl.text = item.color ?? '';
        _materialCtrl.text = item.material ?? '';
        _priceCtrl.text = item.price?.toStringAsFixed(0) ?? '';
        _notesCtrl.text = item.notes ?? '';
        _category = item.category;
        _season = item.season;
        _fit = item.fit;
        _condition = item.condition;
        _rating = item.rating;
        _imagePath = item.imagePath;
      });
    }
  }

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
            _PhotoPicker(
              imagePath: _imagePath,
              onPicked: (path) => setState(() => _imagePath = path),
            ),
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
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Сохранить изменения' : 'Добавить в гардероб'),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final item = ClothingItem(
      id: _original?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      category: _category,
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      size: _sizeCtrl.text.trim().isEmpty ? null : _sizeCtrl.text.trim(),
      color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
      material: _materialCtrl.text.trim().isEmpty ? null : _materialCtrl.text.trim(),
      season: _season,
      fit: _fit,
      price: double.tryParse(_priceCtrl.text.replaceAll(',', '.')),
      imagePath: _imagePath,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      condition: _condition,
      rating: _rating,
      wearCount: _original?.wearCount ?? 0,
      isAvailable: _original?.isAvailable ?? true,
      createdAt: _original?.createdAt ?? now,
    );

    await ref.read(wardrobeRepositoryProvider).save(item);

    if (_original == null) {
      // Only award XP for new items, not edits
      await ref.read(xpServiceProvider).wardrobeItemAdded();
      await ref.read(achievementServiceProvider).checkAfterWardrobeAdd();
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({this.imagePath, this.onPicked});

  final String? imagePath;
  final ValueChanged<String>? onPicked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final xfile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1080,
          imageQuality: 85,
        );
        if (xfile == null) return;
        // Копируем во внутреннее хранилище: путь image_picker временный.
        final persisted = await persistWardrobeImage(xfile.path);
        onPicked?.call(persisted);
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: imagePath != null
            ? Image.file(File(imagePath!), fit: BoxFit.cover)
            : Column(
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
