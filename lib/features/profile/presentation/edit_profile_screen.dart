import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/features/profile/application/profile_providers.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

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

  int _budgetTier = 1;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final profile = await ref.read(profileRepositoryProvider).getProfile();
    if (profile != null && mounted) {
      _fill(profile);
    }
    setState(() => _loaded = true);
  }

  void _fill(UserProfileModel p) {
    _heightCtrl.text = p.height == 0 ? '' : p.height.toStringAsFixed(0);
    _weightCtrl.text = p.weight == 0 ? '' : p.weight.toStringAsFixed(1);
    _waistCtrl.text = p.waist == 0 ? '' : p.waist.toStringAsFixed(0);
    _chestCtrl.text = p.chest == 0 ? '' : p.chest.toStringAsFixed(0);
    _hipsCtrl.text = p.hips == 0 ? '' : p.hips.toStringAsFixed(0);
    _shouldersCtrl.text = p.shoulders == 0 ? '' : p.shoulders.toStringAsFixed(0);
    _neckCtrl.text = p.neck == 0 ? '' : p.neck.toStringAsFixed(0);
    _shoeSizeCtrl.text = p.shoeSize == 0 ? '' : p.shoeSize.toStringAsFixed(0);
    _budgetTier = p.budgetTier;
  }

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

    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          children: [
            Text('Замеры', style: tt.titleMedium),
            const SizedBox(height: Spacing.sm),
            _MeasureField(controller: _heightCtrl, label: 'Рост', unit: 'см'),
            _MeasureField(controller: _weightCtrl, label: 'Вес', unit: 'кг'),
            _MeasureField(controller: _waistCtrl, label: 'Талия', unit: 'см'),
            _MeasureField(controller: _chestCtrl, label: 'Грудь', unit: 'см'),
            _MeasureField(controller: _hipsCtrl, label: 'Бёдра', unit: 'см'),
            _MeasureField(
                controller: _shouldersCtrl, label: 'Плечи', unit: 'см'),
            _MeasureField(controller: _neckCtrl, label: 'Шея', unit: 'см'),
            _MeasureField(
                controller: _shoeSizeCtrl, label: 'Размер обуви', unit: 'EU'),
            const SizedBox(height: Spacing.lg),
            Text('Бюджет', style: tt.titleMedium),
            const SizedBox(height: Spacing.sm),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Бюджет')),
                ButtonSegment(value: 1, label: Text('Средний')),
                ButtonSegment(value: 2, label: Text('Премиум')),
              ],
              selected: {_budgetTier},
              onSelectionChanged: (s) => setState(() => _budgetTier = s.first),
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
                  : const Text('Сохранить'),
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final profile = UserProfileModel(
      height: _parse(_heightCtrl),
      weight: _parse(_weightCtrl),
      waist: _parse(_waistCtrl),
      chest: _parse(_chestCtrl),
      hips: _parse(_hipsCtrl),
      shoulders: _parse(_shouldersCtrl),
      neck: _parse(_neckCtrl),
      shoeSize: _parse(_shoeSizeCtrl),
      budgetTier: _budgetTier,
      updatedAt: DateTime.now(),
    );

    await ref.read(profileRepositoryProvider).save(profile);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
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
          if (double.tryParse(v.replaceAll(',', '.')) == null) {
            return 'Введите число';
          }
          return null;
        },
      ),
    );
  }
}
