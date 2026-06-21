import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/services/services_provider.dart';
import 'package:uuid/uuid.dart';

class AddMeasurementScreen extends ConsumerStatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  ConsumerState<AddMeasurementScreen> createState() =>
      _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends ConsumerState<AddMeasurementScreen> {
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

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
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Добавить замер')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.screenPadding),
        children: [
          Text(
            'Дата: ${now.day}.${now.month}.${now.year}',
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
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Сохранить замер'),
          ),
        ],
      ),
    );
  }

  double? _parse(TextEditingController c) =>
      c.text.isEmpty ? null : double.tryParse(c.text.replaceAll(',', '.'));

  Future<void> _save() async {
    final weight = _parse(_weightCtrl);
    final waist = _parse(_waistCtrl);
    final chest = _parse(_chestCtrl);
    final hips = _parse(_hipsCtrl);

    if (weight == null && waist == null && chest == null && hips == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите хотя бы один замер')),
      );
      return;
    }

    setState(() => _saving = true);

    await ref.read(measurementDaoProvider).insert(
          MeasurementLogsCompanion(
            id: Value(const Uuid().v4()),
            date: Value(DateTime.now()),
            weight: Value(weight),
            waist: Value(waist),
            chest: Value(chest),
            hips: Value(hips),
            notes: Value(
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
            ),
          ),
        );

    await ref.read(xpServiceProvider).measurementLogged();
    await ref.read(achievementServiceProvider).checkAfterMeasurement();

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
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
