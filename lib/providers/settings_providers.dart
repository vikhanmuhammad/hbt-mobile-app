import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/language.dart';
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

/// Bahasa tampilan aplikasi — setting global persisten (CLAUDE.md §Bahasa),
/// menggantikan `introLanguageProvider` lama yang session-only/onboarding-
/// only. Dibaca di seluruh app untuk memilih `Habit.displayName`/
/// `Category.displayName` dan (bertahap) string UI chrome.
@riverpod
class AppLanguage extends _$AppLanguage {
  @override
  AppLang build() {
    final code = ref.watch(settingsRepositoryProvider).language;
    return code == 'id' ? AppLang.id : AppLang.en;
  }

  Future<void> setLanguage(AppLang lang) async {
    await ref.read(settingsRepositoryProvider).setLanguage(lang.name);
    state = lang;
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
///
/// `UserProfile` sendiri cuma tersedia async (Drift stream) — sebelum
/// snapshot pertamanya datang, jatuh balik ke `themeKey` yang di-cache
/// sinkron di SharedPreferences (lihat `SettingsRepository.cachedThemeKey`)
/// alih-alih selalu ke gold, supaya splash screen/frame pertama app tidak
/// sempat "kedip" ke warna default dulu baru pindah ke warna tema asli user.
@riverpod
class ActivePalette extends _$ActivePalette {
  @override
  AppPalette build() {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final settingsRepo = ref.watch(settingsRepositoryProvider);
    final resolvedThemeKey = profileAsync.value?.themeKey;
    final themeKey = resolvedThemeKey ?? settingsRepo.cachedThemeKey;
    if (resolvedThemeKey != null) {
      unawaited(settingsRepo.setCachedThemeKey(resolvedThemeKey));
    }
    return AppPalettes.byKey(themeKey);
  }

  Future<void> setPalette(String key) async {
    await ref.read(profileRepositoryProvider).setThemeKey(key);
    await ref.read(settingsRepositoryProvider).setCachedThemeKey(key);
    state = AppPalettes.byKey(key);
  }
}
