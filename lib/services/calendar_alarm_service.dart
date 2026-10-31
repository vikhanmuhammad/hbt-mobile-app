import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wraps `device_calendar` (calendar read/write) — point 10. Phone alarms
/// are rung by the app itself now (see `NotificationService.alarmStyle`).
class CalendarAlarmService {
  // shouldInitTimezone: false — the plugin's default re-runs
  // `tz.initializeTimeZones()`, which resets `tz.local` back to UTC after
  // NotificationService set it to the device zone, so every reminder saved
  // afterwards was scheduled hours off (feedback 7, slide 46 & 48).
  CalendarAlarmService() : _plugin = DeviceCalendarPlugin(shouldInitTimezone: false);

  final DeviceCalendarPlugin _plugin;

  Future<bool> requestPermissions() async {
    try {
      var result = await _plugin.hasPermissions();
      if (result.isSuccess && result.data == true) return true;
      result = await _plugin.requestPermissions();
      return result.isSuccess && result.data == true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _defaultWritableCalendarId() async {
    try {
      final result = await _plugin.retrieveCalendars();
      if (!result.isSuccess || result.data == null) return null;
      final writable = result.data!.where((c) => c.isReadOnly == false);
      return writable.isEmpty ? null : writable.first.id;
    } catch (_) {
      return null;
    }
  }

  /// Creates, or updates in place when [existingEventId] is given, a
  /// recurring calendar event for a habit's reminder — every day, or weekly
  /// on [isoWeekdays] only. Carries an at-start-time alert so the calendar
  /// itself notifies too. Returns (calendarId, eventId), null on failure/no
  /// permission.
  Future<(String, String)?> upsertReminderEvent({
    required String habitName,
    required DateTime firstOccurrence,
    List<int>? isoWeekdays,
    String? existingCalendarId,
    String? existingEventId,
  }) async {
    try {
      if (!await requestPermissions()) return null;
      final calendarId = existingCalendarId ?? await _defaultWritableCalendarId();
      if (calendarId == null) return null;

      final event = Event(
        calendarId,
        eventId: existingEventId,
        title: 'Habit reminder: $habitName',
        // device_calendar 4.x's Event uses TZDateTime (from `timezone`, the
        // same package flutter_local_notifications scheduling relies on
        // elsewhere in this app) rather than a plain DateTime.
        start: tz.TZDateTime.from(firstOccurrence, tz.local),
        end: tz.TZDateTime.from(firstOccurrence.add(const Duration(minutes: 15)), tz.local),
        recurrenceRule: isoWeekdays == null
            ? RecurrenceRule(RecurrenceFrequency.Daily)
            : RecurrenceRule(
                RecurrenceFrequency.Weekly,
                daysOfWeek: [for (final d in isoWeekdays) DayOfWeek.values[d - 1]],
              ),
        reminders: [Reminder(minutes: 0)],
      );
      final result = await _plugin.createOrUpdateEvent(event);
      final eventId = (result?.isSuccess ?? false) ? result?.data : null;
      return eventId == null ? null : (calendarId, eventId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteReminderEvent(String calendarId, String eventId) async {
    try {
      final result = await _plugin.deleteEvent(calendarId, eventId);
      return result.isSuccess && result.data == true;
    } catch (_) {
      return false;
    }
  }

  /// Reads events overlapping [day] across all writable calendars — used to
  /// flag a habit reminder time that clashes with an existing appointment.
  Future<List<Event>> eventsOn(DateTime day) async {
    try {
      if (!await requestPermissions()) return const [];
      final result = await _plugin.retrieveCalendars();
      if (!result.isSuccess || result.data == null) return const [];

      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final events = <Event>[];
      for (final calendar in result.data!) {
        final params = RetrieveEventsParams(startDate: start, endDate: end);
        final eventsResult = await _plugin.retrieveEvents(calendar.id, params);
        if (eventsResult.isSuccess && eventsResult.data != null) {
          events.addAll(eventsResult.data!);
        }
      }
      return events;
    } catch (_) {
      return const [];
    }
  }
}
