import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/services/services_provider.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';
import 'package:gentleman_os/features/purchases/application/purchases_providers.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/wish_status.dart';
import 'package:uuid/uuid.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // Tab order: All | Wish | Planned | Bought | Rejected
  static const _tabStatuses = [-1, 0, 1, 2, 3];
  static const _tabLabels = ['Все', 'Хочу', 'Планирую', 'Куплено', 'Отклонено'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabStatuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(purchasesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Покупки'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (all) {
          if (all.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Список желаний пуст',
              subtitle:
                  'Добавьте вещи, которые хотите купить,\nчтобы принимать осознанные решения',
            );
          }
          final pendingBudget = all
              .where((i) => i.status < 2 && i.budget != null)
              .fold<double>(0, (sum, i) => sum + i.budget!);

          return Column(
            children: [
              if (pendingBudget > 0) _BudgetSummary(total: pendingBudget),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: _tabStatuses.map((status) {
                    final items = status == -1
                        ? all
                        : all.where((i) => i.status == status).toList();
                    return items.isEmpty
                        ? const Center(
                            child: Text('Список пуст'),
                          )
                        : _WishList(items: items, ref: ref);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWishDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  void _showAddWishDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddWishSheet(ref: ref),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = NumberFormat.currency(locale: 'ru', symbol: '₽', decimalDigits: 0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        Spacing.screenPadding,
        Spacing.screenPadding,
        Spacing.screenPadding,
        0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text('Планируемые расходы: ', style: tt.bodySmall),
          Text(
            fmt.format(total),
            style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishList extends StatelessWidget {
  const _WishList({required this.items, required this.ref});

  final List<PurchaseWishesData> items;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _WishCard(item: items[i], ref: ref),
    );
  }
}

class _WishCard extends StatelessWidget {
  const _WishCard({required this.item, required this.ref});

  final PurchaseWishesData item;
  final WidgetRef ref;

  static const _statusColors = {
    0: Colors.grey,
    1: Colors.orange,
    2: Colors.green,
    3: Colors.red,
  };

  static const _statusLabels = {
    0: 'Хочу',
    1: 'Планирую',
    2: 'Куплено',
    3: 'Отклонено',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = NumberFormat.currency(locale: 'ru', symbol: '₽', decimalDigits: 0);
    final color = _statusColors[item.status] ?? Colors.grey;

    final now = DateTime.now();
    final cooldownEnd = item.createdAt.add(const Duration(hours: 48));
    final inCooldown = item.status == 0 && now.isBefore(cooldownEnd);
    final hoursLeft = inCooldown ? cooldownEnd.difference(now).inHours + 1 : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(
            '${item.priority}',
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(item.itemName, style: tt.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ClothingCategory.values[item.category].label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (item.reason != null) Text(item.reason!, style: tt.bodySmall),
            if (inCooldown)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_bottom,
                        size: 12, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Правило 48ч: подождите ещё $hoursLeft ч',
                      style: tt.labelSmall?.copyWith(
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item.budget != null)
              Text(fmt.format(item.budget), style: tt.bodySmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabels[item.status] ?? '—',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onLongPress: () => _showOptions(context),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...WishStatus.values.map(
              (s) => ListTile(
                title: Text(s.label),
                leading: Icon(
                  item.status == s.index
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                onTap: () async {
                  await ref
                      .read(purchasesDaoProvider)
                      .updateStatus(item.id, s.index);
                  await ref
                      .read(achievementServiceProvider)
                      .checkAfterPurchaseStatusChange();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Удалить'),
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              onTap: () {
                ref.read(purchasesDaoProvider).remove(item.id);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddWishSheet extends StatefulWidget {
  const _AddWishSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddWishSheet> createState() => _AddWishSheetState();
}

class _AddWishSheetState extends State<_AddWishSheet> {
  final _nameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  ClothingCategory _category = ClothingCategory.shirt;
  int _priority = 3;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Новая желаемая покупка', style: tt.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Название*'),
            autofocus: true,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ClothingCategory>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Категория'),
            items: ClothingCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Бюджет, ₽',
                    prefixText: '₽ ',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Приоритет: $_priority', style: tt.bodySmall),
                  Slider(
                    value: _priority.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (v) => setState(() => _priority = v.round()),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonCtrl,
            decoration: const InputDecoration(labelText: 'Причина (зачем нужно)'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Добавить в список'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    await widget.ref.read(purchasesDaoProvider).upsert(
          PurchaseWishesCompanion(
            id: Value(const Uuid().v4()),
            itemName: Value(_nameCtrl.text.trim()),
            category: Value(_category.index),
            priority: Value(_priority),
            budget: Value(double.tryParse(_budgetCtrl.text.replaceAll(',', '.'))),
            reason: Value(
              _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
            ),
            status: const Value(0),
            createdAt: Value(DateTime.now()),
          ),
        );

    if (mounted) Navigator.pop(context);
  }
}
