import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/ui_state_providers.dart';
import '../screens/add_habit/add_habit_flow_screen.dart';
import '../screens/community/community_entry_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/finance/finance_summary_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Automatic switch between BottomNavigationBar (< 900dp) <-> NavigationRail
/// (>= 900dp). The Home tab has 2 FABs: left = Add Habit, right = toggle
/// Edit Mode (CLAUDE.md v3 §6.1/§6.3). See DESIGN.md §3 & §4.2.
class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key});

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;

  // Tabs are mounted lazily (only once visited) rather than all at once, so
  // each tab's own entrance animations (see FadeSlideIn usage inside the
  // screens) actually play the first time a user switches to it — an
  // eagerly-built IndexedStack would build every tab up front and their
  // entrance animations would already be finished by the time the user
  // switches to them.
  final Set<int> _builtIndices = {0};

  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );

  void _onDestinationSelected(int i) {
    if (i == _index) return;
    setState(() {
      _index = i;
      _builtIndices.add(i);
    });
    _fadeController
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Community sits in the middle slot (index 2 of 5) so it's the centered
  // destination in the bottom nav bar.
  List<({IconData icon, String label})> _destinations(AppLocalizations l10n) => [
        (icon: Icons.home_rounded, label: l10n.navHome),
        (icon: Icons.bar_chart_rounded, label: l10n.navDashboard),
        (icon: Icons.groups_rounded, label: l10n.navCommunity),
        (icon: Icons.account_balance_wallet_rounded, label: l10n.navFinance),
        (icon: Icons.settings_rounded, label: l10n.navSettings),
      ];

  static final _screenBuilders = <Widget Function()>[
    () => const HomeScreen(),
    () => const DashboardScreen(),
    () => const CommunityEntryScreen(),
    () => const FinanceSummaryScreen(),
    () => const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = _destinations(l10n);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final body = FadeTransition(
      opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
      child: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _screenBuilders.length; i++)
            _builtIndices.contains(i) ? _screenBuilders[i]() : const SizedBox.shrink(),
        ],
      ),
    );

    if (isWide) {
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                leading: const SizedBox(height: 12),
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(d.label, maxLines: 1),
                      ),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        ),
        floatingActionButton: _index == 0 ? const _HomeFabRow() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    return Scaffold(
      // Device's built-in status bar/notch: the Scaffold body renders
      // edge-to-edge by default, without this the top content (e.g. the
      // "Today" header) would be covered by the status bar.
      body: SafeArea(bottom: false, child: body),
      // NavigationDestination.label is a plain String (no way to give it its
      // own FittedBox), so the longer labels ("Dashboard", "Community")
      // sharing narrow per-item width wrap into an ugly mid-word 2nd line
      // once the system font/display size is scaled up. Capping the scale
      // locally, just for this bar, keeps every label on one line while the
      // rest of the app still scales up to the full app-wide maximum.
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.1,
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            for (final d in destinations)
              NavigationDestination(icon: Icon(d.icon), label: d.label),
          ],
        ),
      ),
      floatingActionButton: _index == 0 ? const _HomeFabRow() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Full-width row containing 2 FABs (left Add Habit, right Edit Mode) —
/// the standard Flutter trick for >1 FAB in a single `floatingActionButton` slot.
class _HomeFabRow extends ConsumerWidget {
  const _HomeFabRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(homeEditModeProvider);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _RoundFab(
              icon: Icons.add_rounded,
              onPressedKey: _FabAction.addHabit,
            ),
            _RoundFab(
              icon: isEditMode ? Icons.check_rounded : Icons.edit_rounded,
              onPressedKey: _FabAction.toggleEdit,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack);
  }
}

enum _FabAction { addHabit, toggleEdit }

class _RoundFab extends ConsumerWidget {
  const _RoundFab({required this.icon, required this.onPressedKey});

  final IconData icon;
  final _FabAction onPressedKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 58,
      height: 58,
      child: FloatingActionButton(
        heroTag: onPressedKey,
        onPressed: () {
          switch (onPressedKey) {
            case _FabAction.addHabit:
              openAddHabitFlow(context);
            case _FabAction.toggleEdit:
              ref.read(homeEditModeProvider.notifier).update((v) => !v);
          }
        },
        shape: const CircleBorder(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
          child: Icon(icon, key: ValueKey(icon), size: 26),
        ),
      ),
    );
  }
}
