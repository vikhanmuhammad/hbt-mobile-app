import 'package:health/health.dart';

/// Wraps the `health` package (HealthKit on iOS, Health Connect on Android)
/// for step-count read/write — point 10. All calls are best-effort: a
/// device without Health/Health Connect installed, or a user who denies the
/// permission prompt, should degrade to "sync unavailable" rather than
/// crash the app, so every method catches and rethrows as a plain bool/int
/// result instead of leaking platform-specific exceptions to the UI layer.
class HealthSyncService {
  HealthSyncService() : _health = Health();

  final Health _health;

  static final _stepsType = [HealthDataType.STEPS];

  /// Requests read+write access for step count. Returns false if the
  /// platform has no Health provider, the user denies, or any other
  /// platform error occurs — callers should show a "couldn't connect"
  /// message rather than assume success.
  Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      final granted = await _health.requestAuthorization(
        _stepsType,
        permissions: [HealthDataAccess.READ_WRITE],
      );
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Total steps recorded today, or null if unavailable/denied.
  Future<int?> getStepsToday() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps;
    } catch (_) {
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
    } catch (_) {
      return false;
    }
  }
}
