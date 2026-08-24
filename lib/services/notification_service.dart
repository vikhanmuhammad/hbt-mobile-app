import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/language.dart';
import '../domain/models/enums.dart';
import '../domain/models/habit.dart';
import '../domain/models/task_days.dart';

/// Plain local notifications (not exact alarms) for habit reminders,
/// rescheduled every time a habit is created/edited/deleted. See CLAUDE.md §7.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Cap on how many same-day repeats [_timeSlots] generates for an interval
  /// reminder — keeps `cancelForHabit`'s cleanup loop and the number of OS
  /// alarms actually scheduled bounded even for a very short interval
  /// starting early in the day.
  static const _maxIntervalSlots = 48;

  /// Reschedule the reminder for 1 habit: cancel the old one, then create a
  /// new notification following reminderTime + taskDays if the reminder is
  /// enabled. When `reminderIntervalMinutes` is set, repeats every N minutes
  /// from reminderTime until the end of the day instead of firing once (#19).
  Future<void> rescheduleForHabit(Habit habit, {AppLang lang = AppLang.en}) async {
    await cancelForHabit(habit.id);
    if (!habit.reminderEnabled ||
        habit.reminderTime == null ||
        !habit.isActive) {
      return;
    }

    final timeParts = habit.reminderTime!.split(':');
    if (timeParts.length != 2) return;
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return;

    final slots = _timeSlots(hour, minute, habit.reminderIntervalMinutes);
    final days = habit.taskDays;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Daily reminders for active habits',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    if (TaskDays.isEveryDay(days)) {
      for (var s = 0; s < slots.length; s++) {
        await _scheduleDaily(
          id: _notificationId(habit.id, 7, s),
          title: habit.displayName(lang),
          hour: slots[s].$1,
          minute: slots[s].$2,
          details: details,
        );
      }
      return;
    }

    for (final day in days) {
      final weekdayIndex = weekdayKeys.indexOf(day);
      if (weekdayIndex == -1) continue;
      for (var s = 0; s < slots.length; s++) {
        await _scheduleWeekly(
          id: _notificationId(habit.id, weekdayIndex, s),
          title: habit.displayName(lang),
          hour: slots[s].$1,
          minute: slots[s].$2,
          isoWeekday: weekdayIndex + 1,
          details: details,
        );
      }
    }
  }

  /// `(hour, minute)` of every repeat starting at [hour]:[minute], stepping
  /// by [intervalMinutes] until past midnight — just the start time alone
  /// when [intervalMinutes] is null/non-positive (original single-reminder
  /// behavior).
  List<(int, int)> _timeSlots(int hour, int minute, int? intervalMinutes) {
    if (intervalMinutes == null || intervalMinutes <= 0) return [(hour, minute)];
    final slots = <(int, int)>[];
    var total = hour * 60 + minute;
    while (total < 24 * 60 && slots.length < _maxIntervalSlots) {
      slots.add((total ~/ 60, total % 60));
      total += intervalMinutes;
    }
    return slots;
  }

  Future<void> cancelForHabit(int habitId) async {
    for (var dayIndex = 0; dayIndex < 8; dayIndex++) {
      for (var slot = 0; slot < _maxIntervalSlots; slot++) {
        await _plugin.cancel(id: _notificationId(habitId, dayIndex, slot));
      }
    }
    // Legacy single-slot-per-day IDs from before interval reminders existed
    // — harmless no-ops once actually canceled, but left scheduled forever
    // otherwise for any habit edited since before this change.
    for (var slot = 0; slot < 8; slot++) {
      await _plugin.cancel(id: habitId * 10 + slot);
    }
  }

  int _notificationId(int habitId, int dayIndex, int slot) =>
      habitId * 1000 + dayIndex * 100 + slot;

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required int hour,
    required int minute,
    required NotificationDetails details,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: 'Time for: $title',
      body: 'Don\'t forget to log your progress today.',
      scheduledDate: _nextInstance(hour, minute),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required int hour,
    required int minute,
    required int isoWeekday,
    required NotificationDetails details,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: 'Time for: $title',
      body: 'Don\'t forget to log your progress today.',
      scheduledDate: _nextInstance(hour, minute, isoWeekday: isoWeekday),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstance(int hour, int minute, {int? isoWeekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (isoWeekday != null) {
      while (scheduled.weekday != isoWeekday) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }
    return scheduled;
  }
}
