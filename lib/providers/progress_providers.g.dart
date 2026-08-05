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

/// Semua habit aktif ditagih pada [date] (flat, lintas goal phrase), dengan
/// progress-nya. Dipakai di Beranda (flat list, CLAUDE.md v3 §6.1) dan
/// Riwayat/Kalender (detail hari, untuk backfill).

@ProviderFor(habitsWithProgressForDate)
final habitsWithProgressForDateProvider = HabitsWithProgressForDateFamily._();

/// Semua habit aktif ditagih pada [date] (flat, lintas goal phrase), dengan
/// progress-nya. Dipakai di Beranda (flat list, CLAUDE.md v3 §6.1) dan
/// Riwayat/Kalender (detail hari, untuk backfill).

final class HabitsWithProgressForDateProvider
    extends
        $FunctionalProvider<
          List<HabitWithProgress>,
          List<HabitWithProgress>,
          List<HabitWithProgress>
        >
    with $Provider<List<HabitWithProgress>> {
  /// Semua habit aktif ditagih pada [date] (flat, lintas goal phrase), dengan
  /// progress-nya. Dipakai di Beranda (flat list, CLAUDE.md v3 §6.1) dan
  /// Riwayat/Kalender (detail hari, untuk backfill).
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

/// Semua habit aktif ditagih pada [date] (flat, lintas goal phrase), dengan
/// progress-nya. Dipakai di Beranda (flat list, CLAUDE.md v3 §6.1) dan
/// Riwayat/Kalender (detail hari, untuk backfill).

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

  /// Semua habit aktif ditagih pada [date] (flat, lintas goal phrase), dengan
  /// progress-nya. Dipakai di Beranda (flat list, CLAUDE.md v3 §6.1) dan
  /// Riwayat/Kalender (detail hari, untuk backfill).

  HabitsWithProgressForDateProvider call(DateTime date) =>
      HabitsWithProgressForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'habitsWithProgressForDateProvider';
}
