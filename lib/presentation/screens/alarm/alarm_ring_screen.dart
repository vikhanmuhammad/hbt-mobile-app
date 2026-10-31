import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/notification_service.dart';

/// Shown when a habit alarm opens the app — full-screen over the lock screen
/// when it rings while the phone is locked — so it can be stopped or
/// snoozed right here (feedback 8, slide 10). The sound itself belongs to
/// the alarm notification, so it stops as soon as either button runs.
class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({super.key, required this.ring});

  final AlarmRing ring;

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  late final Timer _clock;
  DateTime _now = DateTime.now();
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 15), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _clock.cancel();
    // Leaving by Back counts as dismissing, so it never keeps ringing
    // behind the app.
    if (!_handled) unawaited(NotificationService.instance.stopAlarm(widget.ring));
    super.dispose();
  }

  Future<void> _finish(Future<void> Function(AlarmRing) action) async {
    _handled = true;
    await action(widget.ring);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final time = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.alarm_rounded, size: 72, color: theme.colorScheme.onPrimary),
              const SizedBox(height: 16),
              Text(
                time,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.ring.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                widget.ring.body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _finish(NotificationService.instance.snooze),
                  icon: const Icon(Icons.snooze_rounded),
                  label: Text(l10n.alarmSnooze),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary,
                    side: BorderSide(color: theme.colorScheme.onPrimary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _finish(NotificationService.instance.stopAlarm),
                  icon: const Icon(Icons.alarm_off_rounded),
                  label: Text(l10n.alarmDismiss),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.onPrimary,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
