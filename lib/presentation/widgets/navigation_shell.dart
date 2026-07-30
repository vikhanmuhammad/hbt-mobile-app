import 'package:flutter/material.dart';

import '../screens/add_habit/add_habit_flow_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Switch otomatis BottomNavigationBar (< 900dp) <-> NavigationRail (>= 900dp).
/// FAB tambah habit selalu di kiri bawah, hanya tampil di tab Beranda.
/// Lihat DESIGN.md §3 & §4.2.
class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _index = 0;

  static const _destinations = [
    (icon: Icons.home_rounded, label: 'Beranda'),
    (icon: Icons.calendar_month_rounded, label: 'Riwayat'),
    (icon: Icons.bar_chart_rounded, label: 'Dashboard'),
    (icon: Icons.settings_rounded, label: 'Pengaturan'),
  ];

  static final _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const DashboardScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final body = IndexedStack(index: _index, children: _screens);

    if (isWide) {
      return Scaffold(
        body: Row(
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
        floatingActionButton: _index == 0 ? const _AddHabitFab() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
      floatingActionButton: _index == 0 ? const _AddHabitFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class _AddHabitFab extends StatelessWidget {
  const _AddHabitFab();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: FloatingActionButton(
        onPressed: () => openAddHabitFlow(context),
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
