import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _NavigationShellState extends ConsumerState<NavigationShell> {
  int _index = 0;

  // Community sits in the middle slot (index 2 of 5) so it's the centered
  // destination in the bottom nav bar.
  static const _destinations = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.bar_chart_rounded, label: 'Dashboard'),
    (icon: Icons.groups_rounded, label: 'Community'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Finance'),
    (icon: Icons.settings_rounded, label: 'Settings'),
  ];

  static final _screens = [
    const HomeScreen(),
    const DashboardScreen(),
    const CommunityEntryScreen(),
    const FinanceSummaryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final body = IndexedStack(index: _index, children: _screens);

    if (isWide) {
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                labelType: NavigationRailLabelType.all,
                leading: const SizedBox(height: 12),
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
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
    );
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
        child: Icon(icon, size: 26),
      ),
    );
  }
}
