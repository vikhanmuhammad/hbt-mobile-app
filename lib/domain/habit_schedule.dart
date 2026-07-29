import 'date_utils.dart';
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
