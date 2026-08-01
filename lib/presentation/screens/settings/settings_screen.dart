import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/habit.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/toggle_switch.dart';
import '../add_habit/add_habit_flow_screen.dart';
import '../home/category_settings_sheet.dart';
import '../onboarding/onboarding_flow.dart';

/// Kelola kategori custom, edit/nonaktifkan habit, reminder default, dan
/// tentang filosofi tracker. Kolom sempit terpusat, persis prototipe baris
/// ~590-650. Lihat DESIGN.md §4.6.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final categoriesAsync = ref.watch(categoriesProvider);
    final habitsAsync = ref.watch(allActiveHabitsProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final maxWidth = MediaQuery.sizeOf(context).width >= 600 ? 880.0 : 640.0;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 32 : 20, isTablet ? 32 : 16, 40),
            children: [
              Text('Pengaturan', style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              _SectionLabel('Tampilan'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mode gelap', style: theme.textTheme.bodyMedium),
                      ToggleSwitch(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (v) => ref.read(appThemeModeProvider.notifier).toggleDark(v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel('Kelola Kategori'),
              const SizedBox(height: 10),
              categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('$e'),
                data: (categories) {
                  final habitCountAsync = habitsAsync.value ?? const <Habit>[];
                  final countByCategory = <int, int>{};
                  for (final h in habitCountAsync) {
                    countByCategory[h.categoryId] = (countByCategory[h.categoryId] ?? 0) + 1;
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < categories.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => showCategorySettingsSheet(context, categories[i]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: AppColors.categoryColorFromHex(categories[i].colorHex, i),
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(categories[i].name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(fontWeight: FontWeight.w600)),
                                    ),
                                    Text('${countByCategory[categories[i].id] ?? 0} habit',
                                        style: theme.textTheme.bodySmall),
                                    if (!categories[i].isDefault) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.close_rounded,
                                          size: 16, color: theme.textTheme.bodySmall?.color),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      DashedBorder(
                        borderRadius: 14,
                        onTap: () => openCreateCategoryFlow(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text('+ Tambah Kategori',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _SectionLabel('Reminder Default'),
              const SizedBox(height: 10),
              const _DefaultReminderTile(),
              const SizedBox(height: 24),
              _SectionLabel('Data'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showComingSoon(context, 'Export data'),
                      child: const Text('Export Data'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showComingSoon(context, 'Import data'),
                      child: const Text('Import Data'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionLabel('Tentang'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Dibangun berdasar riset Phillippa Lally dkk. (UCL): kebiasaan baru '
                    'rata-rata butuh 66 hari pengulangan agar terasa otomatis. Fokus pada '
                    'konsistensi, bukan kesempurnaan.\n\n'
                    'Sepenuhnya offline. Semua rekomendasi berasal dari data statis di app, '
                    'tidak ada akun atau sinkronisasi cloud.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _confirmResetDemo(context, ref),
                  child: const Text(
                    'Lihat ulang alur onboarding (demo)',
                    style: TextStyle(decoration: TextDecoration.underline, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature belum tersedia di versi ini')),
    );
  }

  Future<void> _confirmResetDemo(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua data?'),
        content: const Text(
          'Semua kategori, habit, dan riwayat progress akan dihapus permanen, lalu '
          'app kembali ke alur onboarding dari awal. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final habitRepo = ref.read(habitRepositoryProvider);
    final notif = ref.read(notificationServiceProvider);

    final habits = await habitRepo.getAll();
    for (final h in habits) {
      try {
        await notif.cancelForHabit(h.id);
      } catch (_) {
        // Platform notifikasi tidak tersedia — lanjutkan penghapusan data.
      }
    }

    await habitRepo.deleteAllData();

    final templates = await ref.read(habitTemplateRepositoryProvider).getAll();
    await ref.read(categoryRepositoryProvider).seedDefaultCategories(templates);
    await ref.read(onboardingStatusProvider.notifier).reset();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        (route) => false,
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _DefaultReminderTile extends ConsumerWidget {
  const _DefaultReminderTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.watch(settingsRepositoryProvider);
    final current = repo.defaultReminderTime ?? '08:00';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, size: 20, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Jam pengingat default: $current', style: theme.textTheme.bodyMedium),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}
