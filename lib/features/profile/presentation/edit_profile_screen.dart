import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _shouldersCtrl = TextEditingController();
  final _neckCtrl = TextEditingController();
  final _shoeSizeCtrl = TextEditingController();

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    _chestCtrl.dispose();
    _hipsCtrl.dispose();
    _shouldersCtrl.dispose();
    _neckCtrl.dispose();
    _shoeSizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          children: [
            Text('Замеры', style: tt.titleMedium),
            const SizedBox(height: Spacing.sm),
            _MeasureField(
              controller: _heightCtrl,
              label: 'Рост',
              unit: 'см',
            ),
            _MeasureField(
              controller: _weightCtrl,
              label: 'Вес',
              unit: 'кг',
            ),
            _MeasureField(
              controller: _waistCtrl,
              label: 'Талия',
              unit: 'см',
            ),
            _MeasureField(
              controller: _chestCtrl,
              label: 'Грудь',
              unit: 'см',
            ),
            _MeasureField(
              controller: _hipsCtrl,
              label: 'Бёдра',
              unit: 'см',
            ),
            _MeasureField(
              controller: _shouldersCtrl,
              label: 'Плечи',
              unit: 'см',
            ),
            _MeasureField(
              controller: _neckCtrl,
              label: 'Шея',
              unit: 'см',
            ),
            _MeasureField(
              controller: _shoeSizeCtrl,
              label: 'Размер обуви',
              unit: 'EU',
            ),
            const SizedBox(height: Spacing.xl),
            FilledButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: сохранить через ProfileRepository, создать MeasurementLog
    Navigator.of(context).pop();
  }
}

class _MeasureField extends StatelessWidget {
  const _MeasureField({
    required this.controller,
    required this.label,
    required this.unit,
  });

  final TextEditingController controller;
  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return null;
          if (double.tryParse(v) == null) return 'Введите число';
          return null;
        },
      ),
    );
  }
}
