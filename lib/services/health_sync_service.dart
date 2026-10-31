import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// One exercise session read from the phone's Health app.
typedef HealthWorkout = ({
  HealthWorkoutActivityType type,
  DateTime start,
  DateTime end,
  int? distanceMeters,
});

/// Wraps the `health` package (HealthKit on iOS, Health Connect on Android)
/// for step counts and exercise sessions — point 10. All calls are
/// best-effort: a device without Health/Health Connect installed, or a user
/// who denies the permission prompt, should degrade to "sync unavailable"
/// rather than crash the app, so every method catches and returns a plain
/// bool/null result instead of leaking platform-specific exceptions to the
/// UI layer.
class HealthSyncService {
  HealthSyncService() : _health = Health();

  final Health _health;

  /// Steps (read+write) plus workouts. On Android reading a workout also
  /// reads its distance and calories, which Health Connect guards with their
  /// own permissions, so those are requested with it.
  static List<HealthDataType> get _types => [
        HealthDataType.STEPS,
        HealthDataType.WORKOUT,
        if (Platform.isAndroid) HealthDataType.DISTANCE_DELTA,
        if (Platform.isAndroid) HealthDataType.TOTAL_CALORIES_BURNED,
      ];

  static List<HealthDataAccess> get _access => [
        HealthDataAccess.READ_WRITE,
        for (var i = 1; i < _types.length; i++) HealthDataAccess.READ,
      ];

  /// Android only (always true on iOS): whether the Health Connect app is
  /// installed. `requestAuthorization` throws `UnsupportedError` on Android
  /// when it isn't, so callers should check this first and offer to install
  /// it instead of surfacing a generic "denied" message.
  Future<bool> isHealthConnectAvailable() => _health.isHealthConnectAvailable();

  /// Opens the Play Store listing for Health Connect. Android only, no-op
  /// on iOS.
  Future<void> installHealthConnect() => _health.installHealthConnect();

  /// Requests access to steps and workouts. Returns false if the platform
  /// has no Health provider, the user denies, or any other platform error
  /// occurs — callers should show a "couldn't connect" message rather than
  /// assume success.
  Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      return await _health.requestAuthorization(_types, permissions: _access);
    } catch (e, st) {
      // Was a bare `catch (_) { return false; }` — every failure was
      // completely silent, which is why 3 devices could all "just not work"
      // with zero error trail to debug from (feedback 6, slide 28).
      debugPrint('HealthSyncService.requestPermissions failed: $e\n$st');
      return false;
    }
  }

  /// Whether every permission sync needs is granted. Android only — iOS
  /// never reveals read access, so null there means "unknown".
  Future<bool?> hasPermissions() async {
    try {
      await _health.configure();
      return await _health.hasPermissions(_types, permissions: _access);
    } catch (e, st) {
      debugPrint('HealthSyncService.hasPermissions failed: $e\n$st');
      return false;
    }
  }

  /// Total steps between [start] and [end], or null if unavailable/denied.
  Future<int?> getSteps(DateTime start, DateTime end) async {
    try {
      return await _health.getTotalStepsInInterval(start, end);
    } catch (e, st) {
      debugPrint('HealthSyncService.getSteps failed: $e\n$st');
      return null;
    }
  }

  /// Exercise sessions that started between [start] and [end], or null if
  /// unavailable/denied.
  Future<List<HealthWorkout>?> getWorkouts(DateTime start, DateTime end) async {
    try {
      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WORKOUT],
        startTime: start,
        endTime: end,
      );
      return [
        for (final p in points)
          if (p.value is WorkoutHealthValue)
            (
              type: (p.value as WorkoutHealthValue).workoutActivityType,
              start: p.dateFrom,
              end: p.dateTo,
              distanceMeters: (p.value as WorkoutHealthValue).totalDistance,
            ),
      ];
    } catch (e, st) {
      debugPrint('HealthSyncService.getWorkouts failed: $e\n$st');
      return null;
    }
  }

  /// Writes [steps] as a manual step-count entry for today — used when a
  /// user logs a "Walk"/step habit manually and wants it reflected back
  /// into the phone's Health app, not just this app's local DB.
  Future<bool> writeStepsToday(int steps) async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      return await _health.writeHealthData(
        value: steps.toDouble(),
        type: HealthDataType.STEPS,
        startTime: midnight,
        endTime: now,
      );
    } catch (e, st) {
      debugPrint('HealthSyncService.writeStepsToday failed: $e\n$st');
      return false;
    }
  }
}
