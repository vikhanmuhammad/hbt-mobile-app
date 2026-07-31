// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(logsForDate)
final logsForDateProvider = LogsForDateFamily._();

final class LogsForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitLog>>,
          List<HabitLog>,
          Stream<List<HabitLog>>
        >
    with $FutureModifier<List<HabitLog>>, $StreamProvider<List<HabitLog>> {
  LogsForDateProvider._({
    required LogsForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'logsForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$logsForDateHash();

  @override
  String toString() {
    return r'logsForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<HabitLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitLog>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return logsForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LogsForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$logsForDateHash() => r'38f3b07f7f14c3f50da1962f9718f595dbec1cdb';

final class LogsForDateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<HabitLog>>, DateTime> {
  LogsForDateFamily._()
    : super(
        retry: null,
        name: r'logsForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LogsForDateProvider call(DateTime date) =>
      LogsForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'logsForDateProvider';
}

/// Habit dalam 1 kategori yang aktif ditagih pada [date], lengkap dengan
/// progress hari itu. Dipakai di Category Detail (Beranda level 2).

@ProviderFor(habitsWithProgressForCategory)
final habitsWithProgressForCategoryProvider =
    HabitsWithProgressForCategoryFamily._();

/// Habit dalam 1 kategori yang aktif ditagih pada [date], lengkap dengan
/// progress hari itu. Dipakai di Category Detail (Beranda level 2).

final class HabitsWithProgressForCategoryProvider
    extends
        $FunctionalProvider<
          List<HabitWithProgress>,
          List<HabitWithProgress>,
          List<HabitWithProgress>
        >
    with $Provider<List<HabitWithProgress>> {
  /// Habit dalam 1 kategori yang aktif ditagih pada [date], lengkap dengan
  /// progress hari itu. Dipakai di Category Detail (Beranda level 2).
  HabitsWithProgressForCategoryProvider._({
    required HabitsWithProgressForCategoryFamily super.from,
    required (int, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'habitsWithProgressForCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitsWithProgressForCategoryHash();

  @override
  String toString() {
    return r'habitsWithProgressForCategoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<HabitWithProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<HabitWithProgress> create(Ref ref) {
    final argument = this.argument as (int, DateTime);
    return habitsWithProgressForCategory(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<HabitWithProgress> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<HabitWithProgress>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HabitsWithProgressForCategoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitsWithProgressForCategoryHash() =>
    r'40b52960b292fa92fe1cd945d468afc0117baefc';

/// Habit dalam 1 kategori yang aktif ditagih pada [date], lengkap dengan
/// progress hari itu. Dipakai di Category Detail (Beranda level 2).

final class HabitsWithProgressForCategoryFamily extends $Family
    with $FunctionalFamilyOverride<List<HabitWithProgress>, (int, DateTime)> {
  HabitsWithProgressForCategoryFamily._()
    : super(
        retry: null,
        name: r'habitsWithProgressForCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Habit dalam 1 kategori yang aktif ditagih pada [date], lengkap dengan
  /// progress hari itu. Dipakai di Category Detail (Beranda level 2).

  HabitsWithProgressForCategoryProvider call(int categoryId, DateTime date) =>
      HabitsWithProgressForCategoryProvider._(
        argument: (categoryId, date),
        from: this,
      );

  @override
  String toString() => r'habitsWithProgressForCategoryProvider';
}

/// Semua habit aktif ditagih pada [date] lintas kategori, dengan progress-nya.
/// Dipakai di Riwayat/Kalender (detail hari) untuk backfill. Lihat DESIGN.md §4.3.

@ProviderFor(habitsWithProgressForDate)
final habitsWithProgressForDateProvider = HabitsWithProgressForDateFamily._();

/// Semua habit aktif ditagih pada [date] lintas kategori, dengan progress-nya.
/// Dipakai di Riwayat/Kalender (detail hari) untuk backfill. Lihat DESIGN.md §4.3.

final class HabitsWithProgressForDateProvider
    extends
        $FunctionalProvider<
          List<HabitWithProgress>,
          List<HabitWithProgress>,
          List<HabitWithProgress>
        >
    with $Provider<List<HabitWithProgress>> {
  /// Semua habit aktif ditagih pada [date] lintas kategori, dengan progress-nya.
  /// Dipakai di Riwayat/Kalender (detail hari) untuk backfill. Lihat DESIGN.md §4.3.
  HabitsWithProgressForDateProvider._({
    required HabitsWithProgressForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'habitsWithProgressForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitsWithProgressForDateHash();

  @override
  String toString() {
    return r'habitsWithProgressForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<HabitWithProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<HabitWithProgress> create(Ref ref) {
    final argument = this.argument as DateTime;
    return habitsWithProgressForDate(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<HabitWithProgress> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<HabitWithProgress>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HabitsWithProgressForDateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitsWithProgressForDateHash() =>
    r'e346ec388d0271555df80731924cd37b26f234cc';

/// Semua habit aktif ditagih pada [date] lintas kategori, dengan progress-nya.
/// Dipakai di Riwayat/Kalender (detail hari) untuk backfill. Lihat DESIGN.md §4.3.

final class HabitsWithProgressForDateFamily extends $Family
    with $FunctionalFamilyOverride<List<HabitWithProgress>, DateTime> {
  HabitsWithProgressForDateFamily._()
    : super(
        retry: null,
        name: r'habitsWithProgressForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Semua habit aktif ditagih pada [date] lintas kategori, dengan progress-nya.
  /// Dipakai di Riwayat/Kalender (detail hari) untuk backfill. Lihat DESIGN.md §4.3.

  HabitsWithProgressForDateProvider call(DateTime date) =>
      HabitsWithProgressForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'habitsWithProgressForDateProvider';
}

/// Progress semua kategori pada [date]: dasar untuk grid kategori Beranda
/// (level 1) dan ring progress utama.

@ProviderFor(categoryProgressList)
final categoryProgressListProvider = CategoryProgressListFamily._();

/// Progress semua kategori pada [date]: dasar untuk grid kategori Beranda
/// (level 1) dan ring progress utama.

final class CategoryProgressListProvider
    extends
        $FunctionalProvider<
          List<CategoryProgress>,
          List<CategoryProgress>,
          List<CategoryProgress>
        >
    with $Provider<List<CategoryProgress>> {
  /// Progress semua kategori pada [date]: dasar untuk grid kategori Beranda
  /// (level 1) dan ring progress utama.
  CategoryProgressListProvider._({
    required CategoryProgressListFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'categoryProgressListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryProgressListHash();

  @override
  String toString() {
    return r'categoryProgressListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<CategoryProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CategoryProgress> create(Ref ref) {
    final argument = this.argument as DateTime;
    return categoryProgressList(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CategoryProgress> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CategoryProgress>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryProgressListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryProgressListHash() =>
    r'9c012a3f82188214c107483761ecc85f0789f6c9';

/// Progress semua kategori pada [date]: dasar untuk grid kategori Beranda
/// (level 1) dan ring progress utama.

final class CategoryProgressListFamily extends $Family
    with $FunctionalFamilyOverride<List<CategoryProgress>, DateTime> {
  CategoryProgressListFamily._()
    : super(
        retry: null,
        name: r'categoryProgressListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Progress semua kategori pada [date]: dasar untuk grid kategori Beranda
  /// (level 1) dan ring progress utama.

  CategoryProgressListProvider call(DateTime date) =>
      CategoryProgressListProvider._(argument: date, from: this);

  @override
  String toString() => r'categoryProgressListProvider';
}

@ProviderFor(homeProgress)
final homeProgressProvider = HomeProgressFamily._();

final class HomeProgressProvider
    extends
        $FunctionalProvider<
          ({int done, int total}),
          ({int done, int total}),
          ({int done, int total})
        >
    with $Provider<({int done, int total})> {
  HomeProgressProvider._({
    required HomeProgressFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'homeProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeProgressHash();

  @override
  String toString() {
    return r'homeProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<({int done, int total})> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ({int done, int total}) create(Ref ref) {
    final argument = this.argument as DateTime;
    return homeProgress(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({int done, int total}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({int done, int total})>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HomeProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeProgressHash() => r'a3c15e4c5685f769e1941f23cf47c58e5ccf215e';

final class HomeProgressFamily extends $Family
    with $FunctionalFamilyOverride<({int done, int total}), DateTime> {
  HomeProgressFamily._()
    : super(
        retry: null,
        name: r'homeProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HomeProgressProvider call(DateTime date) =>
      HomeProgressProvider._(argument: date, from: this);

  @override
  String toString() => r'homeProgressProvider';
}
