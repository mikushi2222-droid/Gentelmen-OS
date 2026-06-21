import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';

class AddMeasurementScreen extends ConsumerStatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  ConsumerState<AddMeasurementScreen> createState() =>
      _AddMeasurementScreenState();
}

class _AddMeasurementScreenState
    extends ConsumerState<AddMeasurementScreen> {
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    _chestCtrl.dispose();
    _hipsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Добавить замер')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          Text(
            'Дата: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
            style: tt.bodySmall,
          ),
          const SizedBox(height: Spacing.md),
          _Field(controller: _weightCtrl, label: 'Вес', unit: 'кг'),
          _Field(controller: _waistCtrl, label: 'Талия', unit: 'см'),
          _Field(controller: _chestCtrl, label: 'Грудь', unit: 'см'),
          _Field(controller: _hipsCtrl, label: 'Бёдра', unit: 'см'),
          const SizedBox(height: Spacing.sm),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Заметка'),
          ),
          const SizedBox(height: Spacing.xl),
          FilledButton(
            onPressed: _save,
            child: const Text('Сохранить замер'),
          ),
        ],
      ),
    );
  }

  void _save() {
    // TODO: MeasurementRepository.add(...)
    Navigator.of(context).pop();
  }
}

class _Field extends StatelessWidget {
  const _Field({
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
        decoration: InputDecoration(labelText: label, suffixText: unit),
      ),
    );
  }
}
