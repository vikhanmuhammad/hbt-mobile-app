import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habbit_tracker_app/data/assets/habit_templates_loader.dart';
import 'package:habbit_tracker_app/data/database/app_database.dart' hide Category, Habit;
import 'package:habbit_tracker_app/data/repositories/category_repository.dart';
import 'package:habbit_tracker_app/data/repositories/finance_repository.dart';
import 'package:habbit_tracker_app/data/repositories/habit_log_repository.dart';
import 'package:habbit_tracker_app/data/repositories/habit_repository.dart';
import 'package:habbit_tracker_app/data/repositories/habit_template_repository.dart';
import 'package:habbit_tracker_app/data/repositories/settings_repository.dart';
import 'package:habbit_tracker_app/data/repositories/stats_repository.dart';
import 'package:habbit_tracker_app/domain/date_utils.dart';
import 'package:habbit_tracker_app/domain/format_utils.dart';
import 'package:habbit_tracker_app/domain/habit_schedule.dart';
import 'package:habbit_tracker_app/domain/models/enums.dart';
import 'package:habbit_tracker_app/domain/models/finance_summary.dart';
import 'package:habbit_tracker_app/domain/models/habit.dart';
import 'package:habbit_tracker_app/presentation/widgets/thousands_input_formatter.dart';
import 'package:habbit_tracker_app/providers/core_providers.dart';
import 'package:habbit_tracker_app/providers/habit_providers.dart';
import 'package:habbit_tracker_app/providers/progress_providers.dart';
import 'package:habbit_tracker_app/services/health_steps_sync.dart';
import 'package:habbit_tracker_app/services/health_sync_service.dart';

/// Types [text] into a field one character at a time, like a keyboard does.
String _type(ThousandsInputFormatter formatter, String text) {
  var value = TextEditingValue.empty;
  for (final ch in text.split('')) {
    final next = TextEditingValue(
      text: value.text + ch,
      selection: TextSelection.collapsed(offset: value.text.length + 1),
    );
    value = formatter.formatEditUpdate(value, next);
  }
  return value.text;
}

Future<(AppDatabase, int)> _database() async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final templates = await HabitTemplateRepository(const HabitTemplatesLoader()).getAll();
  final categoryRepo = CategoryRepository(database);
  await categoryRepo.seedDefaultCategories(templates);
  return (database, (await categoryRepo.getActiveCategories()).first.id);
}

Future<Habit> _createHabit(
  AppDatabase database,
  int categoryId, {
  String name = 'Run',
  String? templateKey,
  GoalPeriod period = GoalPeriod.weekly,
  int goal = 3,
  String unit = 'x',
  GoalDirection direction = GoalDirection.atLeast,
  String? currency,
  required DateTime start,
}) async {
  final repo = HabitRepository(database);
  final id = await repo.createHabit(
    categoryId: categoryId,
    name: name,
    templateKey: templateKey,
    icon: 'droplet',
    goalPeriod: period,
    goalValue: goal,
    goalUnit: unit,
    goalDirection: direction,
    taskDays: const ['all'],
    timeRange: TimeRange.anytime,
    reminderEnabled: false,
    startDate: start,
    currency: currency,
  );
  return (await repo.getById(id))!;
}

class _FakeHealth extends HealthSyncService {
  _FakeHealth({this.steps = const {}, this.workouts = const []});

  final Map<DateTime, int> steps;
  final List<HealthWorkout> workouts;

  @override
  Future<bool> isHealthConnectAvailable() async => true;

  @override
  Future<int?> getSteps(DateTime start, DateTime end) async => steps[dateOnly(start)] ?? 0;

  @override
  Future<List<HealthWorkout>?> getWorkouts(DateTime start, DateTime end) async => workouts;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('slide 8: decimal amounts', () {
    test('cent currencies accept a decimal comma — or a typed dot — and store cents', () {
      final formatter = ThousandsInputFormatter(decimalDigits: 2);
      expect(_type(formatter, '5,50'), '5,50');
      expect(_type(formatter, '5.50'), '5,50');
      expect(_type(formatter, '1250,759'), '1.250,75');
      expect(ThousandsInputFormatter.parse('5,50', decimalDigits: 2), 550);
      expect(ThousandsInputFormatter.parse('5,5', decimalDigits: 2), 550);
      expect(ThousandsInputFormatter.parse('1.250', decimalDigits: 2), 125000);
    });

    test('IDR stays whole rupiah with thousand separators', () {
      final formatter = ThousandsInputFormatter();
      expect(_type(formatter, '50000'), '50.000');
      expect(_type(formatter, '50,5'), '505');
      expect(ThousandsInputFormatter.parse('50.000'), 50000);
    });

    test('formatting reads stored cents back', () {
      expect(formatCurrency(550, 'SGD '), contains('5,50'));
      expect(formatCurrency(50000, 'Rp '), contains('50.000'));
      expect(formatCurrency(50000, 'Rp '), isNot(contains(',')));
      expect(formatAmountInput(5000, 'SGD'), '50');
      expect(formatAmountInput(550, 'SGD'), '5,50');
      expect(formatAmountInput(50000, 'IDR'), '50.000');
    });
  });

  group('slides 5 & 6: progress only on days that were logged', () {
    late AppDatabase database;
    late int categoryId;
    late ProviderContainer container;

    setUp(() async {
      (database, categoryId) = await _database();
      container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(database)]);
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    Future<({int progress, bool done})> progressOn(Habit habit, DateTime date) async {
      final (weekStart, weekEnd) = periodBoundsFor(GoalPeriod.weekly, date);
      container.listen(allActiveHabitsProvider, (_, _) {});
      container.listen(logsForDateProvider(date), (_, _) {});
      container.listen(logsInRangeProvider(weekStart, weekEnd), (_, _) {});
      await container.read(allActiveHabitsProvider.future);
      await container.read(logsForDateProvider(date).future);
      await container.read(logsInRangeProvider(weekStart, weekEnd).future);
      final item = container.read(habitsWithProgressForDateProvider(date)).firstWhere((i) => i.habit.id == habit.id);
      return (progress: item.progressValue, done: item.isDone);
    }

    test('a weekly habit is not carried onto missed days of the week', () async {
      final monday = periodBoundsFor(GoalPeriod.weekly, today()).$1.subtract(const Duration(days: 7));
      final tuesday = monday.add(const Duration(days: 1));
      final wednesday = monday.add(const Duration(days: 2));
      final thursday = monday.add(const Duration(days: 3));
      final habit = await _createHabit(database, categoryId, start: monday.subtract(const Duration(days: 7)));
      final logs = HabitLogRepository(database);
      await logs.setProgress(habit: habit, date: monday, progressValue: 1);
      await logs.setProgress(habit: habit, date: wednesday, progressValue: 2);

      expect(await progressOn(habit, monday), (progress: 1, done: false));
      expect(await progressOn(habit, tuesday), (progress: 0, done: false));
      expect(await progressOn(habit, wednesday), (progress: 3, done: true));
      expect(await progressOn(habit, thursday), (progress: 0, done: false));

      final summaries = await StatsRepository(database).computeMonthSummaries(tuesday);
      expect(summaries.firstWhere((d) => isSameDay(d.date, tuesday)).doneCount, 0);
      expect(summaries.firstWhere((d) => isSameDay(d.date, wednesday)).doneCount, 1);
    });

    test('an unchecked day (log of 0) counts as empty', () async {
      final monday = periodBoundsFor(GoalPeriod.weekly, today()).$1.subtract(const Duration(days: 7));
      final tuesday = monday.add(const Duration(days: 1));
      final habit = await _createHabit(database, categoryId, start: monday);
      final logs = HabitLogRepository(database);
      await logs.setProgress(habit: habit, date: monday, progressValue: 1);
      await logs.setProgress(habit: habit, date: tuesday, progressValue: 0);
      expect(await progressOn(habit, tuesday), (progress: 0, done: false));
    });
  });

  group('slide 7: spending trend per tab unit', () {
    test('weekly and monthly trends are bucketed into weeks and months', () async {
      final (database, categoryId) = await _database();
      addTearDown(database.close);
      final habit = await _createHabit(
        database,
        categoryId,
        name: 'Budget Tracker',
        period: GoalPeriod.daily,
        goal: 100000,
        unit: 'rupiah',
        direction: GoalDirection.atMost,
        start: DateTime(2026, 1, 1),
      );
      final logs = HabitLogRepository(database);
      await logs.setProgress(habit: habit, date: DateTime(2026, 9, 28), progressValue: 10); // Mon
      await logs.setProgress(habit: habit, date: DateTime(2026, 9, 30), progressValue: 20); // Wed, same week
      await logs.setProgress(habit: habit, date: DateTime(2026, 10, 6), progressValue: 40); // next week
      final repo = FinanceRepository(database);

      final weekly = await repo.computeSummary(
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 11),
        trendBucket: FinanceTrendBucket.week,
        trendStart: DateTime(2026, 10, 5).subtract(const Duration(days: 35)),
      );
      expect(weekly.dailyTrend, hasLength(6));
      expect(weekly.dailyTrend.map((p) => p.totalExpense), [0, 0, 0, 0, 30, 40]);
      expect(weekly.dailyTrend[4].date, DateTime(2026, 9, 28));

      final monthly = await repo.computeSummary(
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 31),
        trendBucket: FinanceTrendBucket.month,
        trendStart: DateTime(2026, 5, 1),
      );
      expect(monthly.dailyTrend.map((p) => p.date.month), [5, 6, 7, 8, 9, 10]);
      expect(monthly.dailyTrend.map((p) => p.totalExpense), [0, 0, 0, 0, 30, 40]);
    });
  });

  group('slide 9: health sync', () {
    late AppDatabase database;
    late int categoryId;
    late SettingsRepository settings;

    setUp(() async {
      (database, categoryId) = await _database();
      SharedPreferences.setMockInitialValues({});
      settings = SettingsRepository(await SharedPreferences.getInstance());
      await settings.setStepsSyncEnabled(true);
    });

    tearDown(() => database.close());

    Future<HealthSyncResult> sync(HealthSyncService health) => syncHabitsFromHealth(
          settings: settings,
          habitRepository: HabitRepository(database),
          logRepository: HabitLogRepository(database),
          health: health,
        );

    test('a recorded run fills a template Run habit (unit x)', () async {
      final day = today().subtract(const Duration(days: 1));
      final habit = await _createHabit(database, categoryId, templateKey: 'run', start: day);
      final result = await sync(_FakeHealth(workouts: [
        (
          type: HealthWorkoutActivityType.RUNNING,
          start: day.add(const Duration(hours: 7)),
          end: day.add(const Duration(hours: 7, minutes: 30)),
          distanceMeters: 5000,
        ),
      ]));
      expect(result, (status: HealthSyncStatus.updated, updatedHabits: 1));
      expect((await HabitLogRepository(database).getLog(habit.id, day))?.progressValue, 1);
    });

    test('step habits take the step count; walking minutes fill a minute habit', () async {
      final day = today();
      final steps = await _createHabit(database, categoryId, name: 'Daily steps', unit: 'step', goal: 8000, period: GoalPeriod.daily, start: day);
      final walk = await _createHabit(database, categoryId, name: 'Jalan kaki sore', unit: 'minute', goal: 30, period: GoalPeriod.daily, start: day);
      final result = await sync(_FakeHealth(steps: {day: 6400}, workouts: [
        (
          type: HealthWorkoutActivityType.WALKING,
          start: day.add(const Duration(minutes: 1)),
          end: day.add(const Duration(minutes: 26)),
          distanceMeters: null,
        ),
      ]));
      expect(result.status, HealthSyncStatus.updated);
      final logs = HabitLogRepository(database);
      expect((await logs.getLog(steps.id, day))?.progressValue, 6400);
      expect((await logs.getLog(walk.id, day))?.progressValue, 25);
    });

    test('reports why nothing was filled', () async {
      expect((await sync(_FakeHealth())).status, HealthSyncStatus.noMatchingHabits);
      await _createHabit(database, categoryId, templateKey: 'run', start: today());
      expect((await sync(_FakeHealth())).status, HealthSyncStatus.noData);
    });
  });
}
