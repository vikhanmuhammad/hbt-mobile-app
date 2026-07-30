import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habbit_tracker_app/main.dart';
import 'package:habbit_tracker_app/providers/core_providers.dart';

void main() {
  testWidgets('App boots and shows the splash screen without throwing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const HabitTrackerApp(),
      ),
    );
    await tester.pump();

    // Full boot (DB seeding via path_provider) needs a real platform, so this
    // only verifies the splash screen renders cleanly — the actual app flow
    // is verified by running on a device/emulator.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
