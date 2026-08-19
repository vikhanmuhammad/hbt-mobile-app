import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/toggle_switch.dart';
import '../add_habit/add_habit_flow_screen.dart';
import '../onboarding/onboarding_flow.dart';
import 'faq_screen.dart';
import 'health_sync_settings_tile.dart';
import 'personalize_screen.dart';
import 'profile_screen.dart';
import 'usage_tips_screen.dart';

/// Display, profile, personalize, default reminder, data, usage tips, FAQ,
/// and about the tracker's philosophy. CLAUDE.md v3 §8 — no more separate
/// "Manage Categories" menu; goal phrases are managed implicitly through
/// the Add/Edit Habit flow.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final themeMode = ref.watch(appThemeModeProvider);
    // When never manually set, themeMode == ThemeMode.system — the app
    // already renders dark if the device is dark, but the switch still
    // needs to show that effective status, not just check == ThemeMode.dark.
    final isDarkEffective = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final maxWidth = MediaQuery.sizeOf(context).width >= 600 ? 880.0 : 640.0;

    final profile = ref.watch(userProfileStreamProvider).value;
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: FadeSlideIn(
          child: ListView(
            padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 32 : 20, isTablet ? 32 : 16, 40),
            children: [
              // Profile header card — avatar/name + Pro badge, matches the
              // reference app's Settings layout (point 16).
              Row(
                children: [
                  const AppLogo(size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name.isNotEmpty == true ? profile!.name : 'No Name',
                          style: theme.textTheme.headlineSmall,
                        ),
                        if (isPro) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium_rounded, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Pro Member',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _SectionLabel('Settings'),
              const SizedBox(height: 10),
              _NavTile(
                icon: Icons.checklist_rounded,
                label: 'Habit Manager',
                onTap: () => openCreateCategoryFlow(context),
              ),
              const SizedBox(height: 10),
              _NavTile(
                icon: Icons.palette_outlined,
                label: 'Theme',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PersonalizeScreen()),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dark mode', style: theme.textTheme.bodyMedium),
                      ToggleSwitch(
                        value: isDarkEffective,
                        onChanged: (v) => ref.read(appThemeModeProvider.notifier).toggleDark(v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel('Health & Calendar Sync'),
              const SizedBox(height: 10),
              const HealthSyncSettingsTile(),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                _SectionLabel('Pro Access'),
                const SizedBox(height: 10),
                const _DebugProToggleTile(),
              ],
              const SizedBox(height: 24),
              _SectionLabel('Default Reminder'),
              const SizedBox(height: 10),
              const _DefaultReminderTile(),
              const SizedBox(height: 24),
              _SectionLabel('About'),
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
                label: 'FAQs',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _NavTile(
                icon: Icons.mail_outline_rounded,
                label: 'Contact us',
                onTap: () => _contactUs(context),
              ),
              const SizedBox(height: 10),
              _NavTile(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () => _shareApp(context),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'Built on research by Phillippa Lally et al. (UCL): a new habit '
                    'takes on average 66 days of repetition to become automatic. Focus on '
                    'consistency, not perfection.\n\n'
                    'Fully offline. All recommendations come from static data in the app, '
                    'no account or cloud sync.',
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
                    'Replay the onboarding flow',
                    style: TextStyle(decoration: TextDecoration.underline, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  static const _supportEmail = 'habtrack08@gmail.com';

  Future<void> _contactUs(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=${Uri.encodeComponent('Habit Tracker Support')}',
    );
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email app found — reach us at $_supportEmail'),
        ),
      );
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        text: "I'm building better habits with Habit Tracker — join me!",
        subject: 'Habit Tracker',
      ),
    );
  }

  Future<void> _confirmResetDemo(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'All categories, habits, and progress history will be permanently deleted, then '
          'the app returns to the onboarding flow from the start. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete All'),
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
        // Notification platform not available — proceed with data deletion.
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

/// Toggle Pro status via `MockEntitlementService` — only shown in debug
/// builds. Stands in for the Play Billing/StoreKit integration, deferred
/// until closer to release (update_v2.md §1.1).
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
              child: Text('Pro Mode', style: theme.textTheme.bodyMedium),
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
                child: Text('Default reminder time: $current', style: theme.textTheme.bodyMedium),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}
