import '../data/repositories/settings_repository.dart';
import '../domain/language.dart';
import '../domain/models/enums.dart';
import '../domain/models/habit.dart';
import '../domain/models/task_days.dart';
import 'calendar_alarm_service.dart';
import 'notification_service.dart';

/// Ties per-habit reminder scheduling together with the Settings > Health &
/// Calendar Sync toggles (point 10).
///
/// Before this, `calendarSyncEnabled`/`alarmSyncEnabled` only gated the
/// initial OS permission request in `HealthSyncSettingsTile` — nothing ever
/// read those flags again afterward, so turning "Sync reminders to
/// Calendar"/"Sync reminders to phone Alarm" on had literally no further
/// effect: no calendar event or alarm was ever created for any habit
/// reminder, synced or not. That's the concrete bug behind "the alarm
/// doesn't work even when synced and set per-habit" and "alarm, calendar,
/// and health integrations aren't connected to each other" (feedback 7,
/// slide 46 & 48) — this coordinator is the missing connection: whenever a
/// habit's reminder is (re)scheduled, it also pushes that same reminder
/// into the calendar/alarm integrations the user has already opted into,
/// so enabling all three "just works" together instead of needing a
/// separate manual step per habit.
class ReminderSyncCoordinator {
  ReminderSyncCoordinator({
    required NotificationService notificationService,
    required CalendarAlarmService calendarAlarmService,
    required SettingsRepository settingsRepository,
  })  : _notifications = notificationService,
        _calendarAlarm = calendarAlarmService,
        _settings = settingsRepository;

  final NotificationService _notifications;
  final CalendarAlarmService _calendarAlarm;
  final SettingsRepository _settings;

  /// Reschedules the local notification for [habit] — as a ringing alarm
  /// when "Sync reminders to phone Alarm" is on (see
  /// `NotificationService.alarmStyle`) — then, best-effort, same "never
  /// block the habit save over an integration" policy as notification
  /// scheduling itself, mirrors it into the calendar if that toggle is on.
  Future<void> syncForHabit(Habit habit, {AppLang lang = AppLang.en}) async {
    _notifications.alarmStyle = _settings.alarmSyncEnabled;
    await _notifications.rescheduleForHabit(habit, lang: lang);

    final active = habit.reminderEnabled && habit.reminderTime != null && habit.isActive;
    final parts = habit.reminderTime?.split(':') ?? const <String>[];
    final hour = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final minute = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (!active || hour == null || minute == null) {
      await _removeCalendarEvent(habit.id);
      return;
    }
    try {
      await _notifications.requestExactAlarmPermissionIfNeeded();
    } catch (_) {}

    final habitName = habit.displayName(lang);
    final isoWeekdays = _isoWeekdays(habit);

    if (_settings.calendarSyncEnabled) {
      try {
        final now = DateTime.now();
        var first = DateTime(now.year, now.month, now.day, hour, minute);
        while (first.isBefore(now) || (isoWeekdays != null && !isoWeekdays.contains(first.weekday))) {
          first = first.add(const Duration(days: 1));
        }
        final ids = await _calendarAlarm.upsertReminderEvent(
          habitName: habitName,
          firstOccurrence: first,
          isoWeekdays: isoWeekdays,
          existingCalendarId: _settings.reminderCalendarIdFor(habit.id),
          existingEventId: _settings.reminderEventIdFor(habit.id),
        );
        if (ids != null) await _settings.setReminderEvent(habit.id, ids.$1, ids.$2);
      } catch (_) {
        // Calendar write failed/denied — the local notification reminder
        // scheduled above still stands on its own.
      }
    }
  }

  /// Cleans up a deleted habit's reminder everywhere it was mirrored.
  Future<void> removeForHabit(int habitId) async {
    await _notifications.cancelForHabit(habitId);
    await _removeCalendarEvent(habitId);
  }

  Future<void> _removeCalendarEvent(int habitId) async {
    final calendarId = _settings.reminderCalendarIdFor(habitId);
    final eventId = _settings.reminderEventIdFor(habitId);
    if (calendarId == null || eventId == null) return;
    try {
      await _calendarAlarm.deleteReminderEvent(calendarId, eventId);
    } catch (_) {}
    await _settings.clearReminderEvent(habitId);
  }

  /// ISO weekdays (1 = Monday) the habit is scheduled on, or null for every day.
  List<int>? _isoWeekdays(Habit habit) {
    if (TaskDays.isEveryDay(habit.taskDays)) return null;
    final days = [
      for (final key in habit.taskDays)
        if (weekdayKeys.contains(key)) weekdayKeys.indexOf(key) + 1,
    ]..sort();
    return days.isEmpty ? null : days;
  }
}
