import '../../domain/models/category.dart' as domain;
import '../../domain/models/community/habit_group_link.dart' as domain;
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
      nameId: row.nameId,
      templateKey: row.templateKey,
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
      goalDirection: GoalDirection.fromValue(row.goalDirection),
      taskDays: TaskDays.decode(row.taskDays),
      timeRange: TimeRange.fromValue(row.timeRange),
      reminderEnabled: row.reminderEnabled,
      reminderTime: row.reminderTime,
      startDate: row.startDate,
      endDate: row.endDate,
      isActive: row.isActive,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      nameId: row.nameId,
      isCustom: row.isCustom,
      templateKey: row.templateKey,
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

domain.HabitGroupLink mapHabitGroupLink(db.HabitGroupLink row) =>
    domain.HabitGroupLink(
      id: row.id,
      habitId: row.habitId,
      groupId: row.groupId,
      groupHabitId: row.groupHabitId,
      linkedAt: row.linkedAt,
      lastSyncedAt: row.lastSyncedAt,
    );
