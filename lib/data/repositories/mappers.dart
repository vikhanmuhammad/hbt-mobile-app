import '../../domain/models/category.dart' as domain;
import '../../domain/models/enums.dart';
import '../../domain/models/habit.dart' as domain;
import '../../domain/models/habit_log.dart' as domain;
import '../../domain/models/onboarding_response.dart' as domain;
import '../../domain/models/task_days.dart';
import '../../domain/models/user_profile.dart' as domain;
import '../database/app_database.dart' as db;

domain.Category mapCategory(db.Category row) => domain.Category(
      id: row.id,
      name: row.name,
      icon: row.icon,
      colorHex: row.colorHex,
      isDefault: row.isDefault,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
    );

domain.Habit mapHabit(db.Habit row) => domain.Habit(
      id: row.id,
      categoryId: row.categoryId,
      name: row.name,
      description: row.description,
      icon: row.icon,
      goalPeriod: GoalPeriod.fromValue(row.goalPeriod),
      goalValue: row.goalValue,
      goalUnit: row.goalUnit,
      taskDays: TaskDays.decode(row.taskDays),
      timeRange: TimeRange.fromValue(row.timeRange),
      reminderEnabled: row.reminderEnabled,
      reminderTime: row.reminderTime,
      startDate: row.startDate,
      endDate: row.endDate,
      isActive: row.isActive,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
    );

domain.HabitLog mapHabitLog(db.HabitLog row) => domain.HabitLog(
      id: row.id,
      habitId: row.habitId,
      date: row.date,
      progressValue: row.progressValue,
      isDone: row.isDone,
    );

domain.UserProfile mapUserProfile(db.UserProfileRow row) =>
    domain.UserProfile(
      id: row.id,
      name: row.name,
      age: row.age,
      photoPath: row.photoPath,
      themeKey: row.themeKey,
      createdAt: row.createdAt,
    );

domain.OnboardingResponse mapOnboardingResponse(
  db.OnboardingResponse row,
) =>
    domain.OnboardingResponse(
      questionKey: row.questionKey,
      answerValue: row.answerValue,
    );
