import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/user_profile.dart';
import '../presentation/theme/app_palettes.dart';
import 'core_providers.dart';

part 'settings_providers.g.dart';

@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    // Belum pernah diubah manual dari Settings (fresh install) => selalu
    // light, bukan ikut tema sistem — supaya tampilan awal aplikasi
    // konsisten terlepas dari tema device.
    final enabled = ref.watch(settingsRepositoryProvider).darkModeEnabled;
    return (enabled ?? false) ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleDark(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setDarkModeEnabled(enabled);
    state = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}

/// Stream profil user — dipakai untuk deteksi user baru/lama (CLAUDE.md v3
/// §4.2) dan untuk menurunkan palet Personalize aktif di bawah.
@riverpod
Stream<UserProfile?> userProfileStream(Ref ref) {
  return ref.watch(profileRepositoryProvider).watchProfile();
}

/// Palet warna aktif (fitur Personalize, CLAUDE.md v3 §8). Default ke
/// "Teal Sage" (gold) selama belum ada `UserProfile` (mis. saat masih di
/// tengah onboarding) atau selama `themeKey` belum pernah diubah user.
@riverpod
class ActivePalette extends _$ActivePalette {
  @override
  AppPalette build() {
    final profile = ref.watch(userProfileStreamProvider).value;
    return AppPalettes.byKey(profile?.themeKey);
  }

  Future<void> setPalette(String key) async {
    await ref.read(profileRepositoryProvider).setThemeKey(key);
    state = AppPalettes.byKey(key);
  }
}
