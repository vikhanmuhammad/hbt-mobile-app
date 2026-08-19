import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wraps `device_calendar` (calendar read/write) and a native Android
/// "set alarm" intent — point 10. iOS has no public API to programmatically
/// create Clock alarms, so [createAlarm] is a no-op returning false there;
/// the Settings UI should explain that limitation rather than silently fail.
class CalendarAlarmService {
  CalendarAlarmService() : _plugin = DeviceCalendarPlugin();

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

  /// Creates/updates a recurring calendar event mirroring a habit's daily
  /// reminder time — [existingEventId] lets a repeat call update the same
  /// event instead of creating duplicates. Returns the event id on success,
  /// null on failure/no permission.
  Future<String?> upsertReminderEvent({
    required String habitName,
    required DateTime firstOccurrence,
    String? existingEventId,
  }) async {
    try {
      if (!await requestPermissions()) return null;
      final calendarId = await _defaultWritableCalendarId();
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
        recurrenceRule: RecurrenceRule(RecurrenceFrequency.Daily),
      );
      final result = await _plugin.createOrUpdateEvent(event);
      return (result?.isSuccess ?? false) ? result?.data : null;
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

  /// Opens the native "set alarm" screen pre-filled with the given time
  /// (Android only — `AlarmClock.ACTION_SET_ALARM` has no iOS equivalent
  /// since Apple doesn't expose a public Clock/alarm API). Returns false on
  /// iOS or on any platform error; true once the intent was successfully
  /// launched (the user still has to confirm saving the alarm themselves).
  Future<bool> createAlarm({required String label, required int hour, required int minute}) async {
    if (!Platform.isAndroid) return false;
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': hour,
          'android.intent.extra.alarm.MINUTES': minute,
          'android.intent.extra.alarm.MESSAGE': label,
          'android.intent.extra.alarm.SKIP_UI': false,
        },
      );
      await intent.launch();
      return true;
    } catch (_) {
      return false;
    }
  }
}
