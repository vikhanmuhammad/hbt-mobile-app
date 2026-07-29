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
}
