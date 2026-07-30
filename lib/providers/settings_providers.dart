import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'core_providers.dart';

part 'settings_providers.g.dart';

@riverpod
class OnboardingStatus extends _$OnboardingStatus {
  @override
  bool build() {
    return ref.watch(settingsRepositoryProvider).hasCompletedOnboarding;
  }

  Future<void> complete() async {
    await ref.read(settingsRepositoryProvider).setOnboardingComplete();
    state = true;
  }

  Future<void> reset() async {
    await ref.read(settingsRepositoryProvider).resetOnboarding();
    state = false;
  }
}

@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    final enabled = ref.watch(settingsRepositoryProvider).darkModeEnabled;
    if (enabled == null) return ThemeMode.system;
    return enabled ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleDark(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setDarkModeEnabled(enabled);
    state = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}
