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

@ProviderFor(ActivePalette)
final activePaletteProvider = ActivePaletteProvider._();

/// Palet warna aktif (fitur Personalize, CLAUDE.md v3 §8). Default ke
/// "Teal Sage" (gold) selama belum ada `UserProfile` (mis. saat masih di
/// tengah onboarding) atau selama `themeKey` belum pernah diubah user.
final class ActivePaletteProvider
    extends $NotifierProvider<ActivePalette, AppPalette> {
  /// Palet warna aktif (fitur Personalize, CLAUDE.md v3 §8). Default ke
  /// "Teal Sage" (gold) selama belum ada `UserProfile` (mis. saat masih di
  /// tengah onboarding) atau selama `themeKey` belum pernah diubah user.
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

String _$activePaletteHash() => r'67b4190238222b4e2a896a1477dae3c313854394';

/// Palet warna aktif (fitur Personalize, CLAUDE.md v3 §8). Default ke
/// "Teal Sage" (gold) selama belum ada `UserProfile` (mis. saat masih di
/// tengah onboarding) atau selama `themeKey` belum pernah diubah user.

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
