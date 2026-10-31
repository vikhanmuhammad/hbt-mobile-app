import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/language.dart';
import '../domain/models/enums.dart';
import '../domain/models/habit.dart';
import '../domain/models/task_days.dart';

/// A reminder that is ringing as an alarm — what the alarm screen shows and
/// what Snooze needs to ring it again.
class AlarmRing {
  const AlarmRing({required this.notificationId, required this.habitId, required this.title, required this.body});

  final int notificationId;
  final int habitId;
  final String title;
  final String body;

  String toPayload() => jsonEncode({'type': 'alarm', 'habitId': habitId, 'title': title, 'body': body});

  static AlarmRing? fromResponse(int? notificationId, String? payload) {
    if (notificationId == null || payload == null) return null;
    try {
      final map = jsonDecode(payload);
      if (map is! Map || map['type'] != 'alarm') return null;
      return AlarmRing(
        notificationId: notificationId,
        habitId: map['habitId'] as int,
        title: map['title'] as String,
        body: map['body'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Notification-action handler that runs in a background isolate (the app
/// may not be running) — Snooze re-rings the alarm later; Dismiss needs
/// nothing beyond the notification being cancelled by the action itself.
@pragma('vm:entry-point')
Future<void> notificationBackgroundResponse(NotificationResponse response) async {
  if (response.actionId != NotificationService.snoozeActionId) return;
  final ring = AlarmRing.fromResponse(response.id, response.payload);
  if (ring == null) return;
  try {
    await NotificationService.instance.snooze(ring);
  } catch (e, st) {
    debugPrint('NotificationService: background snooze failed: $e\n$st');
  }
}

/// Local notifications for habit reminders, rescheduled every time a habit
/// is created/edited/deleted. See CLAUDE.md §7.
///
/// With "Sync reminders to phone Alarm" on ([alarmStyle]), reminders ring as
/// a real alarm instead of a plain notification: alarm sound on the alarm
/// volume stream, looping with vibration until handled, shown full-screen
/// over the lock screen, with Snooze/Dismiss right on it (feedback 8, slide
/// 10). The previous approach handed the time to the phone's Clock app,
/// which many Clock apps silently ignore.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  static const snoozeActionId = 'alarm_snooze';
  static const dismissActionId = 'alarm_dismiss';
  static const snoozeDuration = Duration(minutes: 10);
  static const _lockScreenChannel = MethodChannel('habtrack/alarm');

  /// Whether reminders are scheduled as ringing alarms — mirrors the
  /// "Sync reminders to phone Alarm" setting (see `rescheduleRemindersIfNeeded`).
  bool alarmStyle = false;

  final _alarmRings = StreamController<AlarmRing>.broadcast();

  /// An alarm the user opened (tapped it, or it launched the app
  /// full-screen) — the app shows its alarm screen for it.
  Stream<AlarmRing> get alarmRings => _alarmRings.stream;

  bool _timeZonesReady = false;

  Future<void> _initTimeZones() async {
    if (_timeZonesReady) return;
    tzdata.initializeTimeZones();
    // `tz.local` defaults to UTC until explicitly told the device's real
    // timezone — every `zonedSchedule` call below (via `_nextInstance`)
    // computes "now" and the target fire time against `tz.local`, so
    // without this every reminder was silently scheduled against UTC wall
    // time instead of the device's actual local time. On a device several
    // hours off UTC (e.g. WIB/UTC+7) that's enough to make a reminder set
    // for e.g. 08:00 either fire hours late/early or appear to never fire
    // at the expected moment at all — this was the actual root cause behind
    // "alarm/reminder doesn't work even when synced and set per-habit"
    // (feedback 7, slide 46 & 48), not a permission or channel issue.
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e, st) {
      // Best-effort — if the platform lookup fails for some reason, fall
      // back to whatever `tz.local` already is (UTC) rather than crash
      // startup over a reminder-scheduling nicety.
      debugPrint('NotificationService: failed to set local timezone: $e\n$st');
    }
    _timeZonesReady = true;
  }

  Future<void> init() async {
    if (_initialized) return;
    await _initTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundResponse,
    );
    _initialized = true;

    final launch = await _plugin.getNotificationAppLaunchDetails();
    final response = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true && response != null) {
      final ring = AlarmRing.fromResponse(response.id, response.payload);
      if (ring != null) _alarmRings.add(ring);
    }
  }

  void _onResponse(NotificationResponse response) {
    final ring = AlarmRing.fromResponse(response.id, response.payload);
    if (ring == null) return;
    switch (response.actionId) {
      case snoozeActionId:
        unawaited(snooze(ring));
      case dismissActionId:
        unawaited(releaseLockScreen());
      default:
        _alarmRings.add(ring);
    }
  }

  /// Stops [ring] (sound, vibration, notification).
  Future<void> stopAlarm(AlarmRing ring) async {
    await _plugin.cancel(id: ring.notificationId);
    await releaseLockScreen();
  }

  /// Stops [ring] and rings it again after [snoozeDuration].
  Future<void> snooze(AlarmRing ring) async {
    await _initTimeZones();
    await _plugin.cancel(id: ring.notificationId);
    final snoozeId = _notificationId(ring.habitId, _snoozeDayIndex, 0);
    await _plugin.zonedSchedule(
      id: snoozeId,
      title: ring.title,
      body: ring.body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(snoozeDuration),
      notificationDetails: _alarmDetails(),
      androidScheduleMode: await _alarmScheduleMode(),
      payload: AlarmRing(notificationId: snoozeId, habitId: ring.habitId, title: ring.title, body: ring.body)
          .toPayload(),
    );
    await releaseLockScreen();
  }

  /// Lets the app stop showing over the lock screen once an alarm is handled
  /// (`MainActivity` only turns that on for an alarm launch).
  Future<void> releaseLockScreen() async {
    try {
      await _lockScreenChannel.invokeMethod<void>('releaseLockScreen');
    } catch (_) {
      // Not Android, or a background isolate without the activity — nothing to do.
    }
  }

  /// Android 14+: showing an alarm full-screen over the lock screen needs
  /// this permission granted by the user; without it the alarm still rings
  /// as a heads-up notification.
  Future<void> requestFullScreenIntentPermission() async {
    try {
      await _android?.requestFullScreenIntentPermission();
    } catch (_) {}
  }

  /// Alarm channel: alarm sound on the alarm audio stream (heard even when
  /// the ringer is silenced), insistent so it keeps ringing until Snooze or
  /// Dismiss, full-screen over the lock screen. Stops by itself after 10
  /// minutes like a Clock alarm would.
  NotificationDetails _alarmDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_alarms_v1',
          'Habit Alarms',
          channelDescription: 'Habit reminders that ring like an alarm',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 800, 600, 800, 600, 800]),
          // FLAG_INSISTENT: repeat sound/vibration until the user responds.
          additionalFlags: Int32List.fromList([4]),
          ongoing: true,
          autoCancel: false,
          visibility: NotificationVisibility.public,
          timeoutAfter: 10 * 60 * 1000,
          actions: const [
            AndroidNotificationAction(snoozeActionId, 'Snooze 10 min', cancelNotification: true),
            AndroidNotificationAction(dismissActionId, 'Dismiss', cancelNotification: true),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

  /// `alarmClock` mode is exact and exempt from Doze/battery restrictions —
  /// what Clock apps use. Needs the exact-alarm permission; without it falls
  /// back to the regular (possibly delayed) mode.
  Future<AndroidScheduleMode> _alarmScheduleMode() async {
    final canExact = await _android?.canScheduleExactNotifications() ?? false;
    return canExact ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Exact timing when the user allows it (Android 12+ "Alarms & reminders"
  /// setting). The inexact mode lets Android defer/batch the reminder —
  /// on Xiaomi/Samsung battery management that often meant it never showed
  /// at the set time at all (feedback 7, slide 46 & 48).
  Future<AndroidScheduleMode> _scheduleMode() async {
    final canExact = await _android?.canScheduleExactNotifications() ?? false;
    return canExact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<bool> canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? false;

  /// Opens the system "Alarms & reminders" permission screen if exact
  /// alarms aren't allowed yet — called when the user turns a reminder on,
  /// not at startup, so it only ever appears in context.
  Future<void> requestExactAlarmPermissionIfNeeded() async {
    final android = _android;
    if (android == null || _exactAlarmPromptShown) return;
    if (await android.canScheduleExactNotifications() ?? true) return;
    _exactAlarmPromptShown = true;
    await android.requestExactAlarmsPermission();
  }

  bool _exactAlarmPromptShown = false;

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
    // New channel id: Android fixes a channel's importance when it's first
    // created, so the old default-importance channel could never be raised.
    // High importance makes the reminder pop up instead of arriving silently
    // in the shade, where it read as "the reminder doesn't work".
    final details = alarmStyle
        ? _alarmDetails()
        : const NotificationDetails(
            android: AndroidNotificationDetails(
              'habit_reminders_v2',
              'Habit Reminders',
              channelDescription: 'Reminders for your habits',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          );
    final mode = alarmStyle ? await _alarmScheduleMode() : await _scheduleMode();
    final name = habit.displayName(lang);
    final title = lang == AppLang.id ? 'Waktunya: $name' : 'Time for: $name';
    final body = lang == AppLang.id
        ? 'Jangan lupa catat progresmu hari ini.'
        : "Don't forget to log your progress today.";
    String? payloadFor(int id) => alarmStyle
        ? AlarmRing(notificationId: id, habitId: habit.id, title: title, body: body).toPayload()
        : null;

    if (TaskDays.isEveryDay(days)) {
      for (var s = 0; s < slots.length; s++) {
        await _scheduleDaily(
          id: _notificationId(habit.id, 7, s),
          payload: payloadFor(_notificationId(habit.id, 7, s)),
          title: title,
          body: body,
          hour: slots[s].$1,
          minute: slots[s].$2,
          details: details,
          mode: mode,
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
          payload: payloadFor(_notificationId(habit.id, weekdayIndex, s)),
          title: title,
          body: body,
          hour: slots[s].$1,
          minute: slots[s].$2,
          isoWeekday: weekdayIndex + 1,
          details: details,
          mode: mode,
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

  /// `dayIndex` slot used for a snoozed alarm (0-6 = weekdays, 7 = daily).
  static const _snoozeDayIndex = 9;

  Future<void> cancelForHabit(int habitId) async {
    await _plugin.cancel(id: _notificationId(habitId, _snoozeDayIndex, 0));
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
    String? payload,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationDetails details,
    required AndroidScheduleMode mode,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstance(hour, minute),
      notificationDetails: details,
      androidScheduleMode: mode,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> _scheduleWeekly({
    required int id,
    String? payload,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int isoWeekday,
    required NotificationDetails details,
    required AndroidScheduleMode mode,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstance(hour, minute, isoWeekday: isoWeekday),
      notificationDetails: details,
      androidScheduleMode: mode,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
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
