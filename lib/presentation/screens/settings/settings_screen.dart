import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/habit.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/habit_form_sheet.dart';
import '../home/category_settings_sheet.dart';

/// Kelola kategori custom, edit/nonaktifkan habit, reminder default, dan
/// tentang filosofi tracker. Lihat DESIGN.md §4.6.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final habitsAsync = ref.watch(allActiveHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Kategori'),
          categoriesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Text('$e'),
            data: (categories) => Card(
              child: Column(
                children: [
                  for (final c in categories)
                    ListTile(
                      leading: Icon(categoryIconData(c.icon)),
                      title: Text(c.name),
                      subtitle: Text(c.isDefault ? 'Kategori bawaan' : 'Kategori custom'),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        onPressed: () => showCategorySettingsSheet(context, c),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Semua Habit'),
          habitsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Text('$e'),
            data: (habits) {
              if (habits.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada habit.'),
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (final h in habits) _HabitTile(habit: h),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle('Reminder Default'),
          const _DefaultReminderTile(),
          const SizedBox(height: 24),
          _SectionTitle('Tentang'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Habit Tracker dibangun dari sistem Excel "Daily Habit Tracker", '
                    'sepenuhnya offline tanpa akun atau sinkronisasi cloud.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Filosofi 66 hari: penelitian Phillippa Lally (University College London) '
                    'menunjukkan rata-rata dibutuhkan ~66 hari pemantauan konsisten untuk '
                    'membentuk kebiasaan baru. Angka ini konteks edukatif, bukan target keras.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(habit.name),
      subtitle: Text('${habit.goalPeriod.label} • ${habit.goalValue}x'),
      onTap: () => showHabitFormSheet(
        context,
        initialCategoryId: habit.categoryId,
        editingHabit: habit,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: habit.isActive,
            onChanged: (v) async {
              await ref.read(habitRepositoryProvider).setActive(habit.id, v);
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(monthSummariesProvider);
              ref.invalidate(daySummaryProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus habit?'),
        content: Text(
          'Menghapus "${habit.name}" juga akan menghapus semua riwayat progress-nya. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(habitRepositoryProvider).deleteHabit(habit.id);
      await ref.read(notificationServiceProvider).cancelForHabit(habit.id);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(monthSummariesProvider);
      ref.invalidate(daySummaryProvider);
    }
  }
}

class _DefaultReminderTile extends ConsumerWidget {
  const _DefaultReminderTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(settingsRepositoryProvider);
    final current = repo.defaultReminderTime ?? '08:00';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule_rounded),
        title: const Text('Jam pengingat default'),
        subtitle: Text('Disarankan saat membuat reminder habit baru: $current'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final parts = current.split(':');
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 8,
              minute: int.tryParse(parts[1]) ?? 0,
            ),
          );
          if (picked != null) {
            final formatted =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
            await repo.setDefaultReminderTime(formatted);
            ref.invalidate(settingsRepositoryProvider);
          }
        },
      ),
    );
  }
}
