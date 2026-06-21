import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';
import 'package:gentleman_os/shared/enums/wish_status.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Покупки')),
      body: const EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Список желаний пуст',
        subtitle:
            'Добавьте вещи, которые хотите купить,\nчтобы принимать осознанные решения',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: добавить PurchaseWish
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}
