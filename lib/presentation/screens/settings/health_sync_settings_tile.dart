import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/core_providers.dart';
import '../../../services/calendar_alarm_service.dart';
import '../../../services/health_steps_sync.dart';
import '../../../services/health_sync_service.dart';
import '../../../services/reminder_reschedule.dart';
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
    // On Android, `requestAuthorization` throws if Health Connect isn't
    // installed — check first so we can offer to install it instead of
    // just surfacing a generic "denied" message.
    if (!await _health.isHealthConnectAvailable()) {
      await repo.setStepsSyncEnabled(false);
      if (mounted) {
        setState(() => _busy = false);
        _showHealthConnectMissing();
      }
      return;
    }
    final granted = await _health.requestPermissions();
    await repo.setStepsSyncEnabled(granted);
    if (!granted) {
      if (mounted) {
        setState(() => _busy = false);
        _showDenied(AppLocalizations.of(context)!.healthSyncFeatureHealth);
      }
      return;
    }
    // Sync right away and say how it went, so turning this on has a visible
    // effect — or a clear reason why not (feedback 7, slide 47; feedback 8,
    // slide 9).
    await _syncNow();
  }

  Future<void> _syncNow() async {
    setState(() => _busy = true);
    final result = await syncHealthSteps(ref);
    if (!mounted) return;
    setState(() => _busy = false);
    _showSyncResult(result);
  }

  Future<void> _grantAccess() async {
    setState(() => _busy = true);
    final granted = await _health.requestPermissions();
    if (!mounted) return;
    setState(() => _busy = false);
    if (granted) {
      await _syncNow();
    } else {
      _showDenied(AppLocalizations.of(context)!.healthSyncFeatureHealth);
    }
  }

  void _showSyncResult(HealthSyncResult? result) {
    final l10n = AppLocalizations.of(context)!;
    switch (result?.status) {
      case HealthSyncStatus.off:
        return;
      case HealthSyncStatus.unavailable:
        _showHealthConnectMissing();
      case HealthSyncStatus.updated:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.healthSyncResultUpdated(result!.updatedHabits))),
        );
      case HealthSyncStatus.upToDate:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.healthSyncResultUpToDate)),
        );
      case HealthSyncStatus.noPermission:
        _showSyncProblem(l10n.healthSyncResultNoPermission, grantAccess: true);
      case HealthSyncStatus.noData:
        _showSyncProblem(l10n.healthSyncResultNoData);
      case HealthSyncStatus.noMatchingHabits:
        _showSyncProblem(l10n.healthSyncResultNoHabits);
      case null:
        _showSyncProblem(l10n.healthSyncResultFailed);
    }
  }

  void _showSyncProblem(String message, {bool grantAccess = false}) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.healthSyncProblemTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(dialogContext).okButtonLabel),
          ),
          if (grantAccess)
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _grantAccess();
              },
              child: Text(l10n.healthSyncGrantAccess),
            ),
        ],
      ),
    );
  }

  void _showHealthConnectMissing() {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.healthConnectNotInstalledTitle),
        content: Text(l10n.healthConnectNotInstalledMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _health.installHealthConnect();
            },
            child: Text(l10n.healthConnectInstallButton),
          ),
        ],
      ),
    );
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
      if (!granted) _showDenied(AppLocalizations.of(context)!.healthSyncFeatureCalendar);
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
    // Reminders already on the device switch to (or back from) ringing as
    // an alarm right away, not only the next time each habit is saved.
    if (value) {
      final notifications = ref.read(notificationServiceProvider);
      await notifications.requestExactAlarmPermissionIfNeeded();
      await notifications.requestFullScreenIntentPermission();
    }
    await rescheduleRemindersIfNeeded(ref);
    if (value && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.healthSyncAlarmEnabled)),
      );
    }
  }

  String _lastSyncedText(AppLocalizations l10n) {
    final at = ref.read(settingsRepositoryProvider).lastHealthSyncAt;
    if (at == null) return l10n.healthSyncNeverSynced;
    final localizations = MaterialLocalizations.of(context);
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(at));
    final now = DateTime.now();
    final sameDay = at.year == now.year && at.month == now.month && at.day == now.day;
    return l10n.healthSyncLastSynced(sameDay ? time : '${localizations.formatShortDate(at)} $time');
  }

  void _showDenied(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.healthSyncDeniedMessage(feature))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(settingsRepositoryProvider);

    return Card(
      child: Column(
        children: [
          _SyncRow(
            icon: Icons.directions_walk_rounded,
            label: l10n.healthSyncStepsLabel,
            value: repo.stepsSyncEnabled,
            enabled: !_busy,
            onChanged: _toggleSteps,
          ),
          if (repo.stepsSyncEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 0, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_lastSyncedText(l10n), style: theme.textTheme.bodySmall),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _syncNow,
                    child: Text(l10n.healthSyncNow),
                  ),
                ],
              ),
            ),
          Divider(height: 1, color: theme.dividerColor),
          _SyncRow(
            icon: Icons.calendar_month_rounded,
            label: l10n.healthSyncCalendarLabel,
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
              label: l10n.healthSyncAlarmLabel,
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
