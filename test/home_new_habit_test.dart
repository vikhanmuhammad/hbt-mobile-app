import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habbit_tracker_app/data/assets/habit_templates_loader.dart';
import 'package:habbit_tracker_app/data/database/app_database.dart' hide Category;
import 'package:habbit_tracker_app/data/repositories/category_repository.dart';
import 'package:habbit_tracker_app/data/repositories/habit_repository.dart';
import 'package:habbit_tracker_app/data/repositories/habit_template_repository.dart';
import 'package:habbit_tracker_app/domain/date_utils.dart';
import 'package:habbit_tracker_app/domain/models/enums.dart';
import 'package:habbit_tracker_app/l10n/generated/app_localizations.dart';
import 'package:habbit_tracker_app/presentation/screens/home/home_screen.dart';
import 'package:habbit_tracker_app/providers/community_providers.dart';
import 'package:habbit_tracker_app/providers/core_providers.dart';
import 'package:habbit_tracker_app/providers/habit_providers.dart';

void main() {
  testWidgets('a habit added while another route covers Home shows up on Home right away', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    late int categoryId;
    await tester.runAsync(() async {
      final templates = await HabitTemplateRepository(const HabitTemplatesLoader()).getAll();
      final categoryRepo = CategoryRepository(database);
      await categoryRepo.seedDefaultCategories(templates);
      categoryId = (await categoryRepo.getActiveCategories()).first.id;
    });

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(database),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          linkedHabitIdsProvider.overrideWith((ref) => Stream.value(<int>{})),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: HomeScreen()),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Brand new habit'), findsNothing);

    // Cover Home like the add-habit flow does, create the habit, come back.
    navigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await HabitRepository(database).createHabit(
        categoryId: categoryId,
        name: 'Brand new habit',
        icon: 'droplet',
        goalPeriod: GoalPeriod.daily,
        goalValue: 1,
        taskDays: const ['all'],
        timeRange: TimeRange.anytime,
        reminderEnabled: false,
        startDate: today(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    final container = ProviderScope.containerOf(navigatorKey.currentContext!);
    container.invalidate(allActiveHabitsProvider);
    navigatorKey.currentState!.pop();
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Brand new habit'), findsOneWidget);

    // Unmount and let Drift's stream-cleanup timers run before teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(seconds: 1));
  });
}
