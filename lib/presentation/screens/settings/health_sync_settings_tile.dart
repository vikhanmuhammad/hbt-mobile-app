import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/core_providers.dart';
import '../../../services/calendar_alarm_service.dart';
import '../../../services/health_sync_service.dart';
import '../../widgets/toggle_switch.dart';

/// Point 10 — three independent opt-in toggles: sync step count from the
/// phone's Health app (HealthKit/Health Connect), write habit reminders
/// into the phone's calendar, and (Android only) open the native "set
/// alarm" screen for a habit reminder. Each toggle triggers its own OS
/// permission prompt the first time it's turned on, and reverts itself if
/// the user denies or the platform doesn't support it.
class HealthSyncSettingsTile extends ConsumerStatefulWidget {
  const HealthSyncSettingsTile({super.key});

  @override
  ConsumerState<HealthSyncSettingsTile> createState() => _HealthSyncSettingsTileState();
}

class _HealthSyncSettingsTileState extends ConsumerState<HealthSyncSettingsTile> {
  final _health = HealthSyncService();
  final _calendarAlarm = CalendarAlarmService();
  bool _busy = false;

  Future<void> _toggleSteps(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    if (!value) {
      await repo.setStepsSyncEnabled(false);
      setState(() {});
      return;
    }
    setState(() => _busy = true);
    final granted = await _health.requestPermissions();
    await repo.setStepsSyncEnabled(granted);
    if (mounted) {
      setState(() => _busy = false);
      if (!granted) _showDenied('Health access');
    }
  }

  Future<void> _toggleCalendar(bool value) async {
    final repo = ref.read(settingsRepositoryProvider);
    if (!value) {
      await repo.setCalendarSyncEnabled(false);
      setState(() {});
      return;
    }
    setState(() => _busy = true);
    final granted = await _calendarAlarm.requestPermissions();
    await repo.setCalendarSyncEnabled(granted);
    if (mounted) {
      setState(() => _busy = false);
      if (!granted) _showDenied('Calendar access');
    }
  }

  Future<void> _toggleAlarm(bool value) async {
    // This row is only ever shown on Android (see build()) — iOS has no
    // public API for third-party apps to create native Clock alarms, so
    // there's no toggle to hide-behind-a-block here anymore, it's just not
    // rendered on iOS at all.
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setAlarmSyncEnabled(value);
    setState(() {});
  }

  void _showDenied(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature was denied or unavailable on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ref.watch(settingsRepositoryProvider);

    return Card(
      child: Column(
        children: [
          _SyncRow(
            icon: Icons.directions_walk_rounded,
            label: 'Sync steps from Health app',
            value: repo.stepsSyncEnabled,
            enabled: !_busy,
            onChanged: _toggleSteps,
          ),
          Divider(height: 1, color: theme.dividerColor),
          _SyncRow(
            icon: Icons.calendar_month_rounded,
            label: 'Sync reminders to Calendar',
            value: repo.calendarSyncEnabled,
            enabled: !_busy,
            onChanged: _toggleCalendar,
          ),
          // Android only — iOS has no public API for third-party apps to
          // create native Clock alarms (confirmed with the user rather than
          // faking it with a private/undocumented URL scheme).
          if (Platform.isAndroid) ...[
            Divider(height: 1, color: theme.dividerColor),
            _SyncRow(
              icon: Icons.alarm_rounded,
              label: 'Sync reminders to phone Alarm',
              value: repo.alarmSyncEnabled,
              enabled: !_busy,
              onChanged: _toggleAlarm,
            ),
          ],
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          ToggleSwitch(value: value, onChanged: enabled ? onChanged : (_) {}),
        ],
      ),
    );
  }
}
