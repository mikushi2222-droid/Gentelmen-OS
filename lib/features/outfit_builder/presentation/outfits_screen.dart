import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';

class OutfitsScreen extends ConsumerWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Образы'),
          ),
          SliverFillRemaining(
            child: EmptyState(
              icon: Icons.style_outlined,
              title: 'Образов пока нет',
              subtitle: 'Соберите первый образ из вашего гардероба',
              action: Builder(
                builder: (ctx) => FilledButton.icon(
                  onPressed: () => ctx.push('/outfits/build'),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Собрать образ'),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/outfits/build'),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Собрать образ'),
      ),
    );
  }
}
