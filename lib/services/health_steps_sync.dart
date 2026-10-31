import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

import '../data/repositories/habit_log_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/date_utils.dart';
import '../domain/habit_schedule.dart';
import '../domain/models/habit.dart';
import '../providers/core_providers.dart';
import '../providers/stats_providers.dart';
import 'health_sync_service.dart';

/// How a Health sync ended — each has its own message in Settings, so a
/// sync that can't do anything says why and what to do about it instead of
/// silently changing nothing (feedback 8, slide 9).
enum HealthSyncStatus {
  /// Sync is switched off in Settings.
  off,

  /// Health Connect isn't installed (Android).
  unavailable,

  /// Access to steps/workouts isn't granted (anymore).
  noPermission,

  /// No active habit can be filled from health data.
  noMatchingHabits,

  /// The Health app had nothing for the synced days — usually no app that
  /// records steps/workouts is connected to Health Connect.
  noData,

  /// Data was found, but every habit already had at least that much.
  upToDate,

  /// At least one habit's progress was raised.
  updated,
}

typedef HealthSyncResult = ({HealthSyncStatus status, int updatedHabits});

/// Workout types that count for a habit, or [_anyWorkout] for any type.
typedef _Activities = Set<HealthWorkoutActivityType>;

const _anyWorkout = <HealthWorkoutActivityType>{};

const _walking = {
  HealthWorkoutActivityType.WALKING,
  HealthWorkoutActivityType.WALKING_TREADMILL,
  HealthWorkoutActivityType.HIKING,
};
const _running = {HealthWorkoutActivityType.RUNNING, HealthWorkoutActivityType.RUNNING_TREADMILL};
const _swimming = {
  HealthWorkoutActivityType.SWIMMING,
  HealthWorkoutActivityType.SWIMMING_OPEN_WATER,
  HealthWorkoutActivityType.SWIMMING_POOL,
};
const _biking = {HealthWorkoutActivityType.BIKING, HealthWorkoutActivityType.BIKING_STATIONARY};
const _yoga = {
  HealthWorkoutActivityType.YOGA,
  HealthWorkoutActivityType.PILATES,
  HealthWorkoutActivityType.FLEXIBILITY,
};

const _activitiesByTemplate = <String, _Activities>{
  'walk': _walking,
  'mindful_walk': _walking,
  'run': _running,
  'swim': _swimming,
  'cycling': _biking,
  'yoga_stretching': _yoga,
  'stretch': _yoga,
  'walk_bike_instead_driving': {..._walking, ..._biking},
  'workout': _anyWorkout,
  'light_exercise': _anyWorkout,
};

/// Custom habits are matched by name (English or Indonesian).
final _activitiesByKeyword = <RegExp, _Activities>{
  RegExp(r'\b(walk|jalan kaki|hiking)'): _walking,
  RegExp(r'\b(run|jog|lari)'): _running,
  RegExp(r'\b(swim|renang|berenang)'): _swimming,
  RegExp(r'\b(cycl|bike|bicycle|sepeda|gowes)'): _biking,
  RegExp(r'\b(yoga|stretch|pilates|peregangan)'): _yoga,
  RegExp(r'\b(workout|exercise|olahraga|gym|latihan fisik)'): _anyWorkout,
};

_Activities? _activitiesFor(Habit habit) {
  final byTemplate = _activitiesByTemplate[habit.templateKey];
  if (byTemplate != null) return byTemplate;
  final name = '${habit.name} ${habit.nameId ?? ''}'.toLowerCase();
  for (final entry in _activitiesByKeyword.entries) {
    if (entry.key.hasMatch(name)) return entry.value;
  }
  return null;
}

/// What health data fills [habit], by its unit: a `step` habit takes the
/// day's step count; an activity habit (walk, run, swim, cycling, yoga,
/// workout — see [_activitiesFor]) takes that day's matching workouts as a
/// session count (`x`/`time`), minutes, hours or kilometers. Null when the
/// habit can't be filled from health data.
int Function(_DayHealth day)? _valueSourceFor(Habit habit) {
  if (habit.goalUnit == 'step') return (day) => day.steps ?? 0;
  final activities = _activitiesFor(habit);
  if (activities == null) return null;
  Iterable<HealthWorkout> matching(_DayHealth day) =>
      day.workouts.where((w) => activities.isEmpty || activities.contains(w.type));
  return switch (habit.goalUnit) {
    'x' || 'time' => (day) => matching(day).length,
    'minute' => (day) => matching(day).fold<int>(0, (sum, w) => sum + w.end.difference(w.start).inMinutes),
    'hour' => (day) => (matching(day).fold<int>(0, (sum, w) => sum + w.end.difference(w.start).inMinutes) / 60).round(),
    'kilometer' => (day) => (matching(day).fold<int>(0, (sum, w) => sum + (w.distanceMeters ?? 0)) / 1000).round(),
    _ => null,
  };
}

class _DayHealth {
  _DayHealth(this.steps, this.workouts);

  final int? steps;
  final List<HealthWorkout> workouts;

  bool get isEmpty => (steps ?? 0) <= 0 && workouts.isEmpty;
}

/// Days synced each time, today included — covers a few days of not opening
/// the app.
const _syncDays = 7;

/// Fills habits from the phone's Health app (Health Connect / HealthKit)
/// while "Sync activity" is on: step habits from the step count, walk/run/
/// swim/cycling/yoga/workout habits from recorded workouts, for the last
/// [_syncDays] days. Before, only habits with the `step` unit were filled,
/// and no template habit uses that unit, so a sync never changed anything
/// (feedback 8, slide 9). Only ever raises a day's value — a higher number
/// the user logged by hand is kept.
Future<HealthSyncResult> syncHabitsFromHealth({
  required SettingsRepository settings,
  required HabitRepository habitRepository,
  required HabitLogRepository logRepository,
  HealthSyncService? health,
}) async {
  if (!settings.stepsSyncEnabled) return (status: HealthSyncStatus.off, updatedHabits: 0);
  final service = health ?? HealthSyncService();
  if (!await service.isHealthConnectAvailable()) {
    return (status: HealthSyncStatus.unavailable, updatedHabits: 0);
  }

  final todayDate = today();
  final firstDay = todayDate.subtract(const Duration(days: _syncDays - 1));
  final habits = await habitRepository.getAllActive();
  final sources = <Habit, int Function(_DayHealth)>{
    for (final habit in habits) habit: ?_valueSourceFor(habit),
  };
  if (sources.isEmpty) return (status: HealthSyncStatus.noMatchingHabits, updatedHabits: 0);

  final now = DateTime.now();
  final workouts = await service.getWorkouts(firstDay, now);
  final days = <DateTime, _DayHealth>{};
  var anyStepsRead = false;
  for (var day = firstDay; !day.isAfter(todayDate); day = day.add(const Duration(days: 1))) {
    final next = day.add(const Duration(days: 1));
    final steps = await service.getSteps(day, next.isAfter(now) ? now : next);
    anyStepsRead |= steps != null;
    days[day] = _DayHealth(steps, [
      for (final w in workouts ?? const <HealthWorkout>[])
        if (isSameDay(w.start, day)) w,
    ]);
  }
  if (!anyStepsRead && workouts == null) {
    return (status: HealthSyncStatus.noPermission, updatedHabits: 0);
  }
  if (days.values.every((d) => d.isEmpty)) {
    return (status: HealthSyncStatus.noData, updatedHabits: 0);
  }

  final updatedHabitIds = <int>{};
  for (final MapEntry(key: habit, value: source) in sources.entries) {
    for (final MapEntry(key: day, value: dayHealth) in days.entries) {
      if (!isHabitActiveOn(habit, day)) continue;
      final value = source(dayHealth);
      if (value <= 0) continue;
      final current = (await logRepository.getLog(habit.id, day))?.progressValue ?? 0;
      if (value > current) {
        await logRepository.setProgress(habit: habit, date: day, progressValue: value);
        updatedHabitIds.add(habit.id);
      }
    }
  }
  return updatedHabitIds.isEmpty
      ? (status: HealthSyncStatus.upToDate, updatedHabits: 0)
      : (status: HealthSyncStatus.updated, updatedHabits: updatedHabitIds.length);
}

/// Pulls health data into habits (see [syncHabitsFromHealth]), records the
/// outcome for Settings, and refreshes the Future-backed summaries. Never
/// throws — health data is a convenience and must not break startup/resume.
Future<HealthSyncResult?> syncHealthSteps(WidgetRef ref) async {
  final settings = ref.read(settingsRepositoryProvider);
  try {
    final result = await syncHabitsFromHealth(
      settings: settings,
      habitRepository: ref.read(habitRepositoryProvider),
      logRepository: ref.read(habitLogRepositoryProvider),
    );
    if (result.status != HealthSyncStatus.off) {
      await settings.setLastHealthSync(DateTime.now(), result.status.name);
    }
    if (result.status == HealthSyncStatus.updated) {
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(monthSummariesProvider);
      ref.invalidate(daySummaryProvider);
    }
    return result;
  } catch (_) {
    return null;
  }
}
