import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/ui_state_providers.dart';
import '../screens/add_habit/add_habit_flow_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/finance/finance_summary_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Switch otomatis BottomNavigationBar (< 900dp) <-> NavigationRail (>= 900dp).
/// Tab Beranda punya 2 FAB: kiri = Tambah Habit, kanan = toggle Edit Mode
/// (CLAUDE.md v3 §6.1/§6.3). Lihat DESIGN.md §3 & §4.2.
class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key});

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  int _index = 0;

  static const _destinations = [
    (icon: Icons.home_rounded, label: 'Beranda'),
    (icon: Icons.calendar_month_rounded, label: 'Riwayat'),
    (icon: Icons.bar_chart_rounded, label: 'Dashboard'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
    (icon: Icons.settings_rounded, label: 'Pengaturan'),
  ];

  static final _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const DashboardScreen(),
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
      // Status bar/notch bawaan perangkat: body Scaffold render edge-to-edge
      // secara default, tanpa ini konten atas (mis. header "Hari ini")
      // tertutup status bar.
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

/// Row penuh lebar berisi 2 FAB (kiri Tambah Habit, kanan Edit Mode) —
/// trik standar Flutter untuk >1 FAB dalam 1 slot `floatingActionButton`.
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
