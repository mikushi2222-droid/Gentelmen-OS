import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/empty_state.dart';
import 'package:gentleman_os/features/habits/application/habits_providers.dart';
import 'package:uuid/uuid.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHabits = ref.watch(habitsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Привычки')),
      body: asyncHabits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (habits) => habits.isEmpty
            ? EmptyState(
                icon: Icons.repeat,
                title: 'Нет привычек',
                subtitle: 'Добавьте ежедневные ритуалы джентльмена',
                action: FilledButton.icon(
                  onPressed: () => _showAddHabitSheet(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить привычку'),
                ),
              )
            : _HabitsList(habits: habits),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddHabitSheet(ref: ref),
    );
  }
}

class _HabitsList extends ConsumerWidget {
  const _HabitsList({required this.habits});

  final List<HabitsData> habits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      children: [
        Text('Сегодня', style: tt.titleMedium),
        const SizedBox(height: Spacing.sm),
        ...habits.where((h) => h.active).map(
          (h) => _HabitTile(habit: h),
        ),
        if (habits.any((h) => !h.active)) ...[
          const SizedBox(height: Spacing.sectionGap),
          Text('Неактивные', style: tt.titleMedium),
          const SizedBox(height: Spacing.sm),
          ...habits.where((h) => !h.active).map(
            (h) => _HabitTile(habit: h),
          ),
        ],
      ],
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.habit});

  final HabitsData habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final asyncCompleted = ref.watch(habitCompletedTodayProvider(habit.id));
    final isCompleted = asyncCompleted.valueOrNull ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: GestureDetector(
          onTap: () async {
            if (!isCompleted) {
              await ref.read(habitsDaoProvider).log(
                    HabitLogsCompanion(
                      id: Value(const Uuid().v4()),
                      habitId: Value(habit.id),
                      date: Value(DateTime.now()),
                    ),
                  );
              final streak = await ref
                  .read(habitsDaoProvider)
                  .computeStreak(habit.id);
              await ref
                  .read(habitsDaoProvider)
                  .updateStreak(habit.id, streak);
            }
          },
          child: CircleAvatar(
            backgroundColor: isCompleted
                ? AppColors.success.withOpacity(0.2)
                : cs.surfaceContainerLow,
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? AppColors.success : cs.outline,
            ),
          ),
        ),
        title: Text(
          habit.title,
          style: tt.bodyMedium?.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? cs.onSurfaceVariant : null,
          ),
        ),
        subtitle: Row(
          children: [
            if (habit.streak > 0) ...[
              Icon(Icons.local_fire_department,
                  size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text('${habit.streak}д', style: tt.bodySmall),
              const SizedBox(width: 8),
            ],
            Text(
              habit.period == 0 ? 'Ежедневно' : 'Еженедельно',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            final dao = ref.read(habitsDaoProvider);
            if (v == 'toggle') {
              await dao.upsert(HabitsCompanion(
                id: Value(habit.id),
                title: Value(habit.title),
                target: Value(habit.target),
                period: Value(habit.period),
                streak: Value(habit.streak),
                active: Value(!habit.active),
                createdAt: Value(habit.createdAt),
              ));
            } else if (v == 'delete') {
              // soft delete by deactivating
              await dao.upsert(HabitsCompanion(
                id: Value(habit.id),
                title: Value(habit.title),
                target: Value(habit.target),
                period: Value(habit.period),
                streak: Value(habit.streak),
                active: const Value(false),
                createdAt: Value(habit.createdAt),
              ));
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'toggle',
              child: Text(habit.active ? 'Деактивировать' : 'Активировать'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Удалить'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  const _AddHabitSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _ctrl = TextEditingController();
  int _period = 0;

  static const _suggestions = [
    'Зарядка утром',
    'Контрастный душ',
    'Читать 30 минут',
    'Планировать день',
    'Записать мысли',
    'Ухаживать за кожей',
    'Следить за осанкой',
    'Медитация 10 минут',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
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
          Text('Новая привычка', style: tt.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(labelText: 'Название'),
            autofocus: true,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: _suggestions
                .map(
                  (s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _ctrl.text = s),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Ежедневно')),
              ButtonSegment(value: 1, label: Text('Еженедельно')),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Добавить привычку'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;

    await widget.ref.read(habitsDaoProvider).upsert(
          HabitsCompanion(
            id: Value(const Uuid().v4()),
            title: Value(_ctrl.text.trim()),
            target: const Value(1),
            period: Value(_period),
            streak: const Value(0),
            active: const Value(true),
            createdAt: Value(DateTime.now()),
          ),
        );

    if (mounted) Navigator.pop(context);
  }
}
