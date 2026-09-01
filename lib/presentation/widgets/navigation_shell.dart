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
      bottomNavigationBar: _BottomNavBar(
        destinations: destinations,
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
      ),
      floatingActionButton: _index == 0 ? const _HomeFabRow() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Bottom nav bar for narrow layouts (< 900dp) — a custom `Row` of
/// `Expanded` items instead of the built-in `NavigationBar`, because
/// `NavigationDestination.label` is a plain `String` with no way to give it
/// its own `FittedBox`. That used to be worked around by clamping the
/// bar's text-scale to 1.0x, but that only helps against accessibility
/// font-size settings — it does nothing for a physically narrow device
/// where labels like "Community"/"Pengaturan" are too long for their slot
/// even at 1.0x. Each label here is individually wrapped in
/// `FittedBox(fit: scaleDown)` (same technique already used by the wide
/// `NavigationRail` below), so it shrinks to fit whatever space its own
/// `Expanded` item actually has — safe from overflow at any combination of
/// screen width and text scale, without needing to clamp anything.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<({IconData icon, String label})> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.navigationBarTheme;
    final selectedColor = navTheme.iconTheme?.resolve({WidgetState.selected})?.color ??
        theme.colorScheme.onSecondaryContainer;
    final unselectedColor = navTheme.iconTheme?.resolve({})?.color ??
        theme.colorScheme.onSurfaceVariant;
    final indicatorColor = navTheme.indicatorColor ?? theme.colorScheme.secondaryContainer;

    return SafeArea(
      top: false,
      child: Material(
        color: navTheme.backgroundColor ?? theme.colorScheme.surfaceContainer,
        elevation: navTheme.elevation ?? 3,
        child: SizedBox(
          height: navTheme.height ?? 80,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onDestinationSelected(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: i == selectedIndex ? indicatorColor : null,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              destinations[i].icon,
                              color: i == selectedIndex ? selectedColor : unselectedColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                destinations[i].label,
                                maxLines: 1,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: i == selectedIndex ? selectedColor : unselectedColor,
                                  fontWeight: i == selectedIndex ? FontWeight.w700 : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
