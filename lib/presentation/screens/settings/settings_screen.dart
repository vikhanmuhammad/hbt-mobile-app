import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../widgets/toggle_switch.dart';
import '../onboarding/onboarding_flow.dart';
import 'faq_screen.dart';
import 'personalize_screen.dart';
import 'profile_screen.dart';
import 'usage_tips_screen.dart';

/// Tampilan, profil, personalize, reminder default, data, usage tips, FAQ,
/// dan tentang filosofi tracker. CLAUDE.md v3 §8 — tidak ada lagi menu
/// "Kelola Kategori" terpisah; goal phrase dikelola implisit lewat alur
/// Tambah/Edit Habit.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final themeMode = ref.watch(appThemeModeProvider);
    // Saat belum pernah diset manual, themeMode == ThemeMode.system — app
    // sudah render gelap kalau perangkat gelap, tapi switch harus tetap
    // menampilkan status efektif itu, bukan cuma cek == ThemeMode.dark.
    final isDarkEffective = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
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
                        value: isDarkEffective,
                        onChanged: (v) => ref.read(appThemeModeProvider.notifier).toggleDark(v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel('Akun'),
              const SizedBox(height: 10),
              _NavTile(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _NavTile(
                icon: Icons.palette_outlined,
                label: 'Personalize',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PersonalizeScreen()),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                _SectionLabel('Community (Debug)'),
                const SizedBox(height: 10),
                const _DebugProToggleTile(),
              ],
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
              _SectionLabel('Bantuan'),
              const SizedBox(height: 10),
              _NavTile(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Usage Tips',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UsageTipsScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _NavTile(
                icon: Icons.help_outline_rounded,
                label: 'FAQ',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                ),
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

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
              Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle status Pro lewat `MockEntitlementService` — cuma tampil di debug
/// build. Menggantikan integrasi Play Billing/StoreKit yang ditunda ke
/// mendekati rilis (update_v2.md §1.1).
class _DebugProToggleTile extends ConsumerWidget {
  const _DebugProToggleTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPro = ref.watch(isProProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Mode Pro (Debug)', style: theme.textTheme.bodyMedium),
            ),
            ToggleSwitch(
              value: isPro,
              onChanged: (v) => ref.read(isProProvider.notifier).setPro(v),
            ),
          ],
        ),
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
