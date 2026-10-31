import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import '../providers/settings_providers.dart';

/// Reschedules every reminder when the ones on the device are stale: set by
/// an older build against UTC, scheduled before the user allowed exact
/// alarms (those may fire up to an hour late), or scheduled in the other
/// style than "Sync reminders to phone Alarm" now asks for (plain
/// notification vs ringing alarm, feedback 8, slide 10). Runs at startup, on
/// every resume — e.g. right after returning from the "Alarms & reminders"
/// screen — and when the alarm toggle changes. Not awaited by callers: it's
/// hundreds of platform calls (feedback 7, slide 46 & 48).
Future<void> rescheduleRemindersIfNeeded(WidgetRef ref) async {
  try {
    final settings = ref.read(settingsRepositoryProvider);
    final notifications = ref.read(notificationServiceProvider);
    if (!notifications.isInitialized) return;
    notifications.alarmStyle = settings.alarmSyncEnabled;
    final canExact = await notifications.canScheduleExact();
    if (settings.remindersRescheduledForLocalTz &&
        settings.remindersScheduledExact == canExact &&
        settings.remindersScheduledAsAlarm == settings.alarmSyncEnabled) {
      return;
    }
    final lang = ref.read(appLanguageProvider);
    final habits = await ref.read(habitRepositoryProvider).getAllActive();
    for (final habit in habits.where((h) => h.reminderEnabled)) {
      await notifications.rescheduleForHabit(habit, lang: lang);
    }
    await settings.setRemindersRescheduledForLocalTz();
    await settings.setRemindersScheduledExact(canExact);
    await settings.setRemindersScheduledAsAlarm(settings.alarmSyncEnabled);
  } catch (_) {
    // Best-effort; the next start/resume tries again.
  }
}
