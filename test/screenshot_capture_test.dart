// Screenshot capture harness — NOT a real test suite. Renders every
// top-level screen with dummy/in-memory data (no Firebase, no real login)
// and dumps a PNG per screen into build/screenshots/ so they can be
// compiled into a single reference PDF. Run with:
//   flutter test test/screenshot_capture_test.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habbit_tracker_app/data/assets/habit_templates_loader.dart';
import 'package:habbit_tracker_app/data/database/app_database.dart' hide Category;
import 'package:habbit_tracker_app/data/repositories/category_repository.dart';
import 'package:habbit_tracker_app/data/repositories/habit_log_repository.dart';
import 'package:habbit_tracker_app/data/repositories/habit_repository.dart';
import 'package:habbit_tracker_app/data/repositories/habit_template_repository.dart';
import 'package:habbit_tracker_app/data/repositories/profile_repository.dart';
import 'package:habbit_tracker_app/domain/models/category.dart';
import 'package:habbit_tracker_app/domain/models/community/app_group.dart';
import 'package:habbit_tracker_app/domain/models/community/chat_message.dart';
import 'package:habbit_tracker_app/domain/models/community/group_habit.dart';
import 'package:habbit_tracker_app/domain/models/community/group_member.dart';
import 'package:habbit_tracker_app/domain/models/community/leaderboard_entry.dart';
import 'package:habbit_tracker_app/domain/models/community_enums.dart';
import 'package:habbit_tracker_app/domain/models/enums.dart';
import 'package:habbit_tracker_app/domain/models/habit_template.dart';
import 'package:habbit_tracker_app/presentation/screens/add_habit/add_habit_flow_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/community/create_group_habit_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/community/create_group_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/community/group_detail_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/community/join_group_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/community/link_habit_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/onboarding/onboarding_flow.dart';
import 'package:habbit_tracker_app/presentation/screens/onboarding/returning_welcome_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/settings/faq_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/settings/personalize_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/settings/profile_screen.dart';
import 'package:habbit_tracker_app/presentation/screens/settings/usage_tips_screen.dart';
import 'package:habbit_tracker_app/presentation/theme/app_colors.dart';
import 'package:habbit_tracker_app/presentation/theme/app_theme.dart';
import 'package:habbit_tracker_app/presentation/widgets/navigation_shell.dart';
import 'package:habbit_tracker_app/providers/community_providers.dart';
import 'package:habbit_tracker_app/providers/core_providers.dart';
import 'package:habbit_tracker_app/providers/template_providers.dart';

const _phoneSize = Size(390, 844);
const _pixelRatio = 2.0;
final _outDir = Directory('build/screenshots');

class _FakeIsPro extends IsPro {
  @override
  bool build() => true;
}

Future<(AppDatabase, List<CategoryTemplate>)> _seedDatabase() async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final categoryRepo = CategoryRepository(database);
  final habitRepo = HabitRepository(database);
  final logRepo = HabitLogRepository(database);
  final profileRepo = ProfileRepository(database);
  final templateRepo = HabitTemplateRepository(const HabitTemplatesLoader());

  final templates = await templateRepo.getAll();
  await categoryRepo.seedDefaultCategories(templates);
  final categories = await categoryRepo.getActiveCategories();

  Category byPhrase(String phrase) =>
      categories.firstWhere((c) => c.name == phrase, orElse: () => categories.first);

  final health = byPhrase('Be Healthy');
  final finance = categories.firstWhere(
    (c) => c.name == 'Save Money',
    orElse: () => categories.first,
  );
  final mind = byPhrase('Be Mindful');

  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day - 30);

  final habitSpecs = <(Category, String, String, GoalPeriod, int, String, GoalDirection)>[
    (health, 'Drink Water', 'droplet', GoalPeriod.daily, 8, 'x', GoalDirection.atLeast),
    (health, 'Morning Run', 'footprints', GoalPeriod.daily, 1, 'x', GoalDirection.atLeast),
    (health, 'Sleep 8 Hours', 'moon', GoalPeriod.daily, 1, 'x', GoalDirection.atLeast),
    (mind, 'Meditate', 'brain', GoalPeriod.daily, 10, 'minutes', GoalDirection.atLeast),
    (mind, 'Read a Book', 'book-open', GoalPeriod.daily, 20, 'pages', GoalDirection.atLeast),
    (finance, 'Daily Spending Limit', 'wallet', GoalPeriod.daily, 100000, 'rupiah', GoalDirection.atMost),
    (finance, 'Save Money', 'piggy-bank', GoalPeriod.monthly, 1000000, 'rupiah', GoalDirection.atLeast),
  ];

  for (final spec in habitSpecs) {
    await habitRepo.createHabit(
      categoryId: spec.$1.id,
      name: spec.$2,
      icon: spec.$3,
      goalPeriod: spec.$4,
      goalValue: spec.$5,
      goalUnit: spec.$6,
      goalDirection: spec.$7,
      taskDays: const ['all'],
      timeRange: TimeRange.anytime,
      reminderEnabled: false,
      startDate: start,
    );
  }

  final habits = await habitRepo.getAllActive();
  for (var dayOffset = 30; dayOffset >= 0; dayOffset--) {
    final date = DateTime(today.year, today.month, today.day - dayOffset);
    for (final habit in habits) {
      if ((dayOffset + habit.id) % 4 == 0) continue;
      final ratio = 0.5 + 0.5 * (((dayOffset * 7 + habit.id * 13) % 10) / 10);
      final value = habit.goalDirection == GoalDirection.atMost
          ? (habit.goalValue * (0.4 + 0.5 * ((dayOffset + habit.id) % 5) / 5)).round()
          : (habit.goalValue * ratio).round().clamp(0, habit.goalValue * 2);
      await logRepo.setProgress(habit: habit, date: date, progressValue: value);
    }
  }

  await profileRepo.completeOnboarding(name: 'Alex Putri', age: 27, responses: const []);

  return (database, templates);
}

GroupHabit _sampleGroupHabit({String id = 'gh1', String groupId = 'g1'}) => GroupHabit(
      id: id,
      groupId: groupId,
      name: 'Push-up Challenge',
      unit: 'reps',
      icon: 'dumbbell',
      leaderboardMode: LeaderboardMode.progress,
      createdBy: 'uid_admin',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

AppGroup _sampleGroup() => AppGroup(
      id: 'g1',
      name: 'Morning Warriors',
      inviteCode: 'ABC123',
      createdBy: 'uid_admin',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      members: [
        GroupMember(
          uid: 'uid_admin',
          displayName: 'Alex Putri',
          role: GroupRole.admin,
          joinedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        GroupMember(
          uid: 'uid_2',
          displayName: 'Budi Santoso',
          role: GroupRole.member,
          joinedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        GroupMember(
          uid: 'uid_3',
          displayName: 'Citra Dewi',
          role: GroupRole.member,
          joinedAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
      ],
    );

List<LeaderboardEntry> _sampleLeaderboard() => [
      LeaderboardEntry(
        uid: 'uid_admin',
        displayName: 'Alex Putri',
        streak: 12,
        progressValue: 340,
        lastUpdated: DateTime.now(),
      ),
      LeaderboardEntry(
        uid: 'uid_2',
        displayName: 'Budi Santoso',
        streak: 8,
        progressValue: 260,
        lastUpdated: DateTime.now(),
      ),
      LeaderboardEntry(
        uid: 'uid_3',
        displayName: 'Citra Dewi',
        streak: 5,
        progressValue: 190,
        lastUpdated: DateTime.now(),
      ),
    ];

List<ChatMessage> _sampleMessages() => [
      ChatMessage(
        id: 'm1',
        senderUid: 'uid_2',
        senderName: 'Budi Santoso',
        text: 'Good morning team! Just finished my push-ups 💪',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'm2',
        senderUid: 'uid_admin',
        senderName: 'Alex Putri',
        text: 'Nice work! Keep the streak going everyone.',
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

// Individual `testWidgets` bodies run inside a fake-async zone, where real
// dart:io writes never complete (the test hangs until the framework's
// timeout). So instead of writing to disk per-test, PNG bytes are collected
// here and flushed to disk once in `tearDownAll`, which runs as real async.
final Map<String, Uint8List> _captured = {};

Future<void> _saveImage(GlobalKey boundaryKey, String fileName) async {
  final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: _pixelRatio);
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  _captured[fileName] = bytes;
  // ignore: avoid_print
  print('Captured $fileName (${bytes.length} bytes)');
}

Future<void> _capture(
  WidgetTester tester,
  String fileName,
  Widget screen, {
  dynamic overrides = const [],
  int settlePumps = 6,
}) async {
  tester.view.physicalSize = _phoneSize * _pixelRatio;
  tester.view.devicePixelRatio = _pixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final boundaryKey = GlobalKey();

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(accent: AppColors.gold),
        home: RepaintBoundary(key: boundaryKey, child: screen),
      ),
    ),
  );

  for (var i = 0; i < settlePumps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  await _saveImage(boundaryKey, fileName);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late List<CategoryTemplate> templates;
  late SharedPreferences prefs;

  setUpAll(() async {
    _outDir.createSync(recursive: true);
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    (database, templates) = await _seedDatabase();
  });

  tearDownAll(() async {
    for (final entry in _captured.entries) {
      final file = File('${_outDir.path}/${entry.key}.png');
      await file.writeAsBytes(entry.value, flush: true);
      // ignore: avoid_print
      print('Saved ${file.path}');
    }
    await database.close();
  });

  dynamic baseOverrides({bool isPro = true}) => [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
        authStateProvider.overrideWith((ref) => Stream.value(null)),
        // Avoids a fresh rootBundle.loadString() (real I/O) from inside a
        // testWidgets fake-async zone, which never resolves and hangs the
        // test until the framework's timeout.
        habitTemplatesProvider.overrideWith((ref) => Future.value(templates)),
        if (isPro) isProProvider.overrideWith(() => _FakeIsPro()),
      ];

  // ---------------------------------------------------------------------
  // Section 1 — Onboarding & Welcome
  // ---------------------------------------------------------------------
  testWidgets('S1_01 Onboarding flow', (tester) async {
    await _capture(tester, 'S1_01_onboarding_flow', const OnboardingFlow(), overrides: baseOverrides());
  });

  testWidgets('S1_02 Returning welcome screen', (tester) async {
    await _capture(
      tester,
      'S1_02_returning_welcome',
      const ReturningWelcomeScreen(name: 'Alex Putri'),
      overrides: baseOverrides(),
      settlePumps: 3,
    );
  });

  // ---------------------------------------------------------------------
  // Section 2 — Home & Dashboard (via the real bottom-nav shell)
  // ---------------------------------------------------------------------
  testWidgets('S2 Main navigation shell — Home, Dashboard, Finance, Community, Settings tabs', (tester) async {
    tester.view.physicalSize = _phoneSize * _pixelRatio;
    tester.view.devicePixelRatio = _pixelRatio;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: baseOverrides(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(accent: AppColors.gold),
          home: RepaintBoundary(key: boundaryKey, child: const NavigationShell()),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await _saveImage(boundaryKey, 'S2_01_home_screen');

    final navBar = find.byType(NavigationBar);
    Future<void> tapTab(int index, String fileName) async {
      final destinations = find.descendant(of: navBar, matching: find.byType(NavigationDestination));
      await tester.tap(destinations.at(index));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await _saveImage(boundaryKey, fileName);
    }

    await tapTab(1, 'S2_02_dashboard_screen');
    await tapTab(2, 'S4_01_finance_summary_screen');
    await tapTab(3, 'S5_01_community_entry_signed_out');
    await tapTab(4, 'S6_01_settings_screen');
  });

  // ---------------------------------------------------------------------
  // Section 3 — Add Habit flow
  // ---------------------------------------------------------------------
  testWidgets('S3_01 Add Habit flow — step 1 (pick goal phrase)', (tester) async {
    await _capture(
      tester,
      'S3_01_add_habit_step1_goal_phrase',
      const AddHabitFlowScreen(),
      overrides: baseOverrides(),
    );
  });

  testWidgets('S3_02 Add Habit flow — new category step', (tester) async {
    await _capture(
      tester,
      'S3_02_add_habit_new_category',
      const AddHabitFlowScreen(startAtNewCategory: true),
      overrides: baseOverrides(),
    );
  });

  // ---------------------------------------------------------------------
  // Section 5 — Community
  // ---------------------------------------------------------------------
  testWidgets('S5_02 Create group screen', (tester) async {
    await _capture(tester, 'S5_02_create_group_screen', const CreateGroupScreen(), overrides: baseOverrides());
  });

  testWidgets('S5_03 Join group screen', (tester) async {
    await _capture(tester, 'S5_03_join_group_screen', const JoinGroupScreen(), overrides: baseOverrides());
  });

  testWidgets('S5_04 Create group habit screen', (tester) async {
    await _capture(
      tester,
      'S5_04_create_group_habit_screen',
      const CreateGroupHabitScreen(groupId: 'g1'),
      overrides: baseOverrides(),
    );
  });

  testWidgets('S5_05 Group detail screen', (tester) async {
    final group = _sampleGroup();
    final groupHabit = _sampleGroupHabit();
    await _capture(
      tester,
      'S5_05_group_detail_screen',
      const GroupDetailScreen(groupId: 'g1'),
      overrides: [
        ...baseOverrides(),
        groupDetailProvider('g1').overrideWith((ref) => Stream.value(group)),
        groupHabitsProvider('g1').overrideWith((ref) => Stream.value([groupHabit])),
        groupHabitLeaderboardProvider('g1', 'gh1')
            .overrideWith((ref) => Stream.value(_sampleLeaderboard())),
        groupMessagesProvider('g1').overrideWith((ref) => Stream.value(_sampleMessages())),
      ],
      settlePumps: 8,
    );
  });

  testWidgets('S5_06 Link habit screen', (tester) async {
    final groupHabit = _sampleGroupHabit();
    await _capture(
      tester,
      'S5_06_link_habit_screen',
      LinkHabitScreen(groupHabit: groupHabit),
      overrides: baseOverrides(),
    );
  });

  // ---------------------------------------------------------------------
  // Section 6 — Settings
  // ---------------------------------------------------------------------
  testWidgets('S6_02 FAQ screen', (tester) async {
    await _capture(tester, 'S6_02_faq_screen', const FaqScreen(), overrides: baseOverrides());
  });

  testWidgets('S6_03 Personalize screen', (tester) async {
    await _capture(tester, 'S6_03_personalize_screen', const PersonalizeScreen(), overrides: baseOverrides());
  });

  testWidgets('S6_04 Profile screen', (tester) async {
    await _capture(tester, 'S6_04_profile_screen', const ProfileScreen(), overrides: baseOverrides());
  });

  testWidgets('S6_05 Usage tips screen', (tester) async {
    await _capture(tester, 'S6_05_usage_tips_screen', const UsageTipsScreen(), overrides: baseOverrides());
  });
}
