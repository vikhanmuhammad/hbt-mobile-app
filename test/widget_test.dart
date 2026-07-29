import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habbit_tracker_app/main.dart';
import 'package:habbit_tracker_app/providers/core_providers.dart';

void main() {
  testWidgets('App boots and shows onboarding welcome screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const HabitTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang'), findsOneWidget);
  });
}
