// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppThemeMode)
final appThemeModeProvider = AppThemeModeProvider._();

final class AppThemeModeProvider
    extends $NotifierProvider<AppThemeMode, ThemeMode> {
  AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  AppThemeMode create() => AppThemeMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$appThemeModeHash() => r'67f848898dfea065ca4dcabefc2c9fc261c5bfbd';

abstract class _$AppThemeMode extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Bahasa tampilan aplikasi — setting global persisten (CLAUDE.md §Bahasa),
/// menggantikan `introLanguageProvider` lama yang session-only/onboarding-
/// only. Dibaca di seluruh app untuk memilih `Habit.displayName`/
/// `Category.displayName` dan (bertahap) string UI chrome.

@ProviderFor(AppLanguage)
final appLanguageProvider = AppLanguageProvider._();

/// Bahasa tampilan aplikasi — setting global persisten (CLAUDE.md §Bahasa),
/// menggantikan `introLanguageProvider` lama yang session-only/onboarding-
/// only. Dibaca di seluruh app untuk memilih `Habit.displayName`/
/// `Category.displayName` dan (bertahap) string UI chrome.
final class AppLanguageProvider
    extends $NotifierProvider<AppLanguage, AppLang> {
  /// Bahasa tampilan aplikasi — setting global persisten (CLAUDE.md §Bahasa),
  /// menggantikan `introLanguageProvider` lama yang session-only/onboarding-
  /// only. Dibaca di seluruh app untuk memilih `Habit.displayName`/
  /// `Category.displayName` dan (bertahap) string UI chrome.
  AppLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLanguageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLanguageHash();

  @$internal
  @override
  AppLanguage create() => AppLanguage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLang value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLang>(value),
    );
  }
}

String _$appLanguageHash() => r'ee807159d205f3c9517e7899877c69aabd4c900e';

/// Bahasa tampilan aplikasi — setting global persisten (CLAUDE.md §Bahasa),
/// menggantikan `introLanguageProvider` lama yang session-only/onboarding-
/// only. Dibaca di seluruh app untuk memilih `Habit.displayName`/
/// `Category.displayName` dan (bertahap) string UI chrome.

abstract class _$AppLanguage extends $Notifier<AppLang> {
  AppLang build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppLang, AppLang>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLang, AppLang>,
              AppLang,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Stream profil user — dipakai untuk deteksi user baru/lama (CLAUDE.md v3
/// §4.2) dan untuk menurunkan palet Personalize aktif di bawah.

@ProviderFor(userProfileStream)
final userProfileStreamProvider = UserProfileStreamProvider._();

/// Stream profil user — dipakai untuk deteksi user baru/lama (CLAUDE.md v3
/// §4.2) dan untuk menurunkan palet Personalize aktif di bawah.

final class UserProfileStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          Stream<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $StreamProvider<UserProfile?> {
  /// Stream profil user — dipakai untuk deteksi user baru/lama (CLAUDE.md v3
  /// §4.2) dan untuk menurunkan palet Personalize aktif di bawah.
  UserProfileStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileStreamHash();

  @$internal
  @override
  $StreamProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProfile?> create(Ref ref) {
    return userProfileStream(ref);
  }
}

String _$userProfileStreamHash() => r'a9a837487179662dbb71b0e7f2fd1d1dbfff4524';

/// Palet warna aktif (fitur Personalize, CLAUDE.md v3 §8). Default ke
/// "Teal Sage" (gold) selama belum ada `UserProfile` (mis. saat masih di
/// tengah onboarding) atau selama `themeKey` belum pernah diubah user.
///
/// `UserProfile` sendiri cuma tersedia async (Drift stream) — sebelum
/// snapshot pertamanya datang, jatuh balik ke `themeKey` yang di-cache
/// sinkron di SharedPreferences (lihat `SettingsRepository.cachedThemeKey`)
/// alih-alih selalu ke gold, supaya splash screen/frame pertama app tidak
/// sempat "kedip" ke warna default dulu baru pindah ke warna tema asli user.

@ProviderFor(ActivePalette)
final activePaletteProvider = ActivePaletteProvider._();

/// Palet warna aktif (fitur Personalize, CLAUDE.md v3 §8). Default ke
/// "Teal Sage" (gold) selama belum ada `UserProfile` (mis. saat masih di
/// tengah onboarding) atau selama `themeKey` belum pernah diubah user.
///
/// `UserProfile` sendiri cuma tersedia async (Drift stream) — sebelum
/// snapshot pertamanya datang, jatuh balik ke `themeKey` yang di-cache
/// sinkron di SharedPreferences (lihat `SettingsRepository.cachedThemeKey`)
/// alih-alih selalu ke gold, supaya splash screen/frame pertama app tidak
/// sempat "kedip" ke warna default dulu baru pindah ke warna tema asli user.
final class ActivePaletteProvider
    extends $NotifierProvider<ActivePalette, AppPalette> {
  /// Palet warna aktif (fitur Personalize, CLAUDE.md v3 §8). Default ke
  /// "Teal Sage" (gold) selama belum ada `UserProfile` (mis. saat masih di
  /// tengah onboarding) atau selama `themeKey` belum pernah diubah user.
  ///
  /// `UserProfile` sendiri cuma tersedia async (Drift stream) — sebelum
  /// snapshot pertamanya datang, jatuh balik ke `themeKey` yang di-cache
  /// sinkron di SharedPreferences (lihat `SettingsRepository.cachedThemeKey`)
  /// alih-alih selalu ke gold, supaya splash screen/frame pertama app tidak
  /// sempat "kedip" ke warna default dulu baru pindah ke warna tema asli user.
  ActivePaletteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activePaletteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activePaletteHash();

  @$internal
  @override
  ActivePalette create() => ActivePalette();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPalette value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPalette>(value),
    );
  }
}

String _$activePaletteHash() => r'20f9a23e89af8fb700c8e4dd9d1ea08c2635507f';

/// Palet warna aktif (fitur Personalize, CLAUDE.md v3 §8). Default ke
/// "Teal Sage" (gold) selama belum ada `UserProfile` (mis. saat masih di
/// tengah onboarding) atau selama `themeKey` belum pernah diubah user.
///
/// `UserProfile` sendiri cuma tersedia async (Drift stream) — sebelum
/// snapshot pertamanya datang, jatuh balik ke `themeKey` yang di-cache
/// sinkron di SharedPreferences (lihat `SettingsRepository.cachedThemeKey`)
/// alih-alih selalu ke gold, supaya splash screen/frame pertama app tidak
/// sempat "kedip" ke warna default dulu baru pindah ke warna tema asli user.

abstract class _$ActivePalette extends $Notifier<AppPalette> {
  AppPalette build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppPalette, AppPalette>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppPalette, AppPalette>,
              AppPalette,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
