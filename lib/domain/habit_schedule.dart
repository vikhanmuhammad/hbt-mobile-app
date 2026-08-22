import 'date_utils.dart';
import 'models/enums.dart';
import 'models/habit.dart';
import 'models/task_days.dart';

/// Habit "aktif ditagih" pada [date] = isActive, dalam rentang startDate–endDate,
/// dan `date` termasuk taskDays-nya. Lihat CLAUDE.md §4.
bool isHabitActiveOn(Habit habit, DateTime date) {
  if (!habit.isActive) return false;

  final day = dateOnly(date);
  final start = dateOnly(habit.startDate);
  if (day.isBefore(start)) return false;

  final end = habit.endDate;
  if (end != null && day.isAfter(dateOnly(end))) return false;

  return TaskDays.includesWeekday(habit.taskDays, date.weekday);
}

/// Inclusive start/end of the goal period containing [date]: the day itself
/// for `daily`, Monday-Sunday for `weekly`, or the calendar month for
/// `monthly`. Used to sum a weekly/monthly habit's per-day logs into one
/// period total instead of resetting to that single day's value.
(DateTime start, DateTime end) periodBoundsFor(GoalPeriod period, DateTime date) {
  final day = dateOnly(date);
  switch (period) {
    case GoalPeriod.daily:
      return (day, day);
    case GoalPeriod.weekly:
      final start = day.subtract(Duration(days: day.weekday - 1));
      return (start, start.add(const Duration(days: 6)));
    case GoalPeriod.monthly:
      return (DateTime(day.year, day.month, 1), DateTime(day.year, day.month + 1, 0));
  }
}
