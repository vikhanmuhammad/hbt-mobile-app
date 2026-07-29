import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/models/enums.dart';
import '../domain/models/habit.dart';
import '../domain/models/task_days.dart';

/// Notifikasi lokal biasa (bukan exact alarm) untuk reminder habit, dijadwalkan
/// ulang tiap kali habit dibuat/diubah/dihapus. Lihat CLAUDE.md §7.
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

  /// Jadwalkan ulang reminder untuk 1 habit: batalkan yang lama, lalu buat
  /// notifikasi baru mengikuti reminderTime + taskDays kalau reminder aktif.
  Future<void> rescheduleForHabit(Habit habit) async {
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

    final days = habit.taskDays;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Pengingat Habit',
        channelDescription: 'Pengingat harian untuk habit yang aktif',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    if (TaskDays.isEveryDay(days)) {
      await _scheduleDaily(
        id: _notificationId(habit.id, 7),
        title: habit.name,
        hour: hour,
        minute: minute,
        details: details,
      );
      return;
    }

    for (final day in days) {
      final weekdayIndex = weekdayKeys.indexOf(day);
      if (weekdayIndex == -1) continue;
      await _scheduleWeekly(
        id: _notificationId(habit.id, weekdayIndex),
        title: habit.name,
        hour: hour,
        minute: minute,
        isoWeekday: weekdayIndex + 1,
        details: details,
      );
    }
  }

  Future<void> cancelForHabit(int habitId) async {
    for (var slot = 0; slot < 8; slot++) {
      await _plugin.cancel(id: _notificationId(habitId, slot));
    }
  }

  int _notificationId(int habitId, int slot) => habitId * 10 + slot;

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required int hour,
    required int minute,
    required NotificationDetails details,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: 'Waktunya: $title',
      body: 'Jangan lupa catat progress hari ini.',
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
      title: 'Waktunya: $title',
      body: 'Jangan lupa catat progress hari ini.',
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
