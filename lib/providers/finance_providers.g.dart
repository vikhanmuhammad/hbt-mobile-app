// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Rangkuman keuangan untuk bulan kalender yang memuat [monthAnchor].

@ProviderFor(financeSummary)
final financeSummaryProvider = FinanceSummaryFamily._();

/// Rangkuman keuangan untuk bulan kalender yang memuat [monthAnchor].

final class FinanceSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<FinanceSummary>,
          FinanceSummary,
          FutureOr<FinanceSummary>
        >
    with $FutureModifier<FinanceSummary>, $FutureProvider<FinanceSummary> {
  /// Rangkuman keuangan untuk bulan kalender yang memuat [monthAnchor].
  FinanceSummaryProvider._({
    required FinanceSummaryFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'financeSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$financeSummaryHash();

  @override
  String toString() {
    return r'financeSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FinanceSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FinanceSummary> create(Ref ref) {
    final argument = this.argument as DateTime;
    return financeSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FinanceSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$financeSummaryHash() => r'b16cf195ddc7ef85c6bdc24dd965b524bb7ee1f1';

/// Rangkuman keuangan untuk bulan kalender yang memuat [monthAnchor].

final class FinanceSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FinanceSummary>, DateTime> {
  FinanceSummaryFamily._()
    : super(
        retry: null,
        name: r'financeSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rangkuman keuangan untuk bulan kalender yang memuat [monthAnchor].

  FinanceSummaryProvider call(DateTime monthAnchor) =>
      FinanceSummaryProvider._(argument: monthAnchor, from: this);

  @override
  String toString() => r'financeSummaryProvider';
}

/// Rangkuman keuangan bulan kalender yang memuat [monthAnchor], tapi
/// di-clamp sampai hari ini (bukan sampai akhir bulan) — dasar "Total
/// Saved" di Finance: akumulasi sisa budget berjalan dari hari habit
/// budget itu di-set (`isHabitActiveOn` sudah otomatis mengecualikan hari
/// sebelum `habit.startDate`) sampai hari ini, bukan diproyeksikan ke
/// seluruh bulan yang belum berjalan. Beda dari [financeSummaryProvider]
/// biasa, yang sengaja TIDAK di-clamp supaya "X dari Rp Y budget" &
/// `paceAt` di tab Monthly tetap membandingkan ke cap bulan penuh. Untuk
/// bulan yang sudah lewat, clamp ke hari ini tidak berpengaruh — hasilnya
/// otomatis sama dengan bulan penuh karena akhir bulan sudah di masa lalu.

@ProviderFor(financeMonthToDateSummary)
final financeMonthToDateSummaryProvider = FinanceMonthToDateSummaryFamily._();

/// Rangkuman keuangan bulan kalender yang memuat [monthAnchor], tapi
/// di-clamp sampai hari ini (bukan sampai akhir bulan) — dasar "Total
/// Saved" di Finance: akumulasi sisa budget berjalan dari hari habit
/// budget itu di-set (`isHabitActiveOn` sudah otomatis mengecualikan hari
/// sebelum `habit.startDate`) sampai hari ini, bukan diproyeksikan ke
/// seluruh bulan yang belum berjalan. Beda dari [financeSummaryProvider]
/// biasa, yang sengaja TIDAK di-clamp supaya "X dari Rp Y budget" &
/// `paceAt` di tab Monthly tetap membandingkan ke cap bulan penuh. Untuk
/// bulan yang sudah lewat, clamp ke hari ini tidak berpengaruh — hasilnya
/// otomatis sama dengan bulan penuh karena akhir bulan sudah di masa lalu.

final class FinanceMonthToDateSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<FinanceSummary>,
          FinanceSummary,
          FutureOr<FinanceSummary>
        >
    with $FutureModifier<FinanceSummary>, $FutureProvider<FinanceSummary> {
  /// Rangkuman keuangan bulan kalender yang memuat [monthAnchor], tapi
  /// di-clamp sampai hari ini (bukan sampai akhir bulan) — dasar "Total
  /// Saved" di Finance: akumulasi sisa budget berjalan dari hari habit
  /// budget itu di-set (`isHabitActiveOn` sudah otomatis mengecualikan hari
  /// sebelum `habit.startDate`) sampai hari ini, bukan diproyeksikan ke
  /// seluruh bulan yang belum berjalan. Beda dari [financeSummaryProvider]
  /// biasa, yang sengaja TIDAK di-clamp supaya "X dari Rp Y budget" &
  /// `paceAt` di tab Monthly tetap membandingkan ke cap bulan penuh. Untuk
  /// bulan yang sudah lewat, clamp ke hari ini tidak berpengaruh — hasilnya
  /// otomatis sama dengan bulan penuh karena akhir bulan sudah di masa lalu.
  FinanceMonthToDateSummaryProvider._({
    required FinanceMonthToDateSummaryFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'financeMonthToDateSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$financeMonthToDateSummaryHash();

  @override
  String toString() {
    return r'financeMonthToDateSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FinanceSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FinanceSummary> create(Ref ref) {
    final argument = this.argument as DateTime;
    return financeMonthToDateSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FinanceMonthToDateSummaryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$financeMonthToDateSummaryHash() =>
    r'0777ffcd0e43fc574bebdb24595cd8325eb86e2f';

/// Rangkuman keuangan bulan kalender yang memuat [monthAnchor], tapi
/// di-clamp sampai hari ini (bukan sampai akhir bulan) — dasar "Total
/// Saved" di Finance: akumulasi sisa budget berjalan dari hari habit
/// budget itu di-set (`isHabitActiveOn` sudah otomatis mengecualikan hari
/// sebelum `habit.startDate`) sampai hari ini, bukan diproyeksikan ke
/// seluruh bulan yang belum berjalan. Beda dari [financeSummaryProvider]
/// biasa, yang sengaja TIDAK di-clamp supaya "X dari Rp Y budget" &
/// `paceAt` di tab Monthly tetap membandingkan ke cap bulan penuh. Untuk
/// bulan yang sudah lewat, clamp ke hari ini tidak berpengaruh — hasilnya
/// otomatis sama dengan bulan penuh karena akhir bulan sudah di masa lalu.

final class FinanceMonthToDateSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FinanceSummary>, DateTime> {
  FinanceMonthToDateSummaryFamily._()
    : super(
        retry: null,
        name: r'financeMonthToDateSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rangkuman keuangan bulan kalender yang memuat [monthAnchor], tapi
  /// di-clamp sampai hari ini (bukan sampai akhir bulan) — dasar "Total
  /// Saved" di Finance: akumulasi sisa budget berjalan dari hari habit
  /// budget itu di-set (`isHabitActiveOn` sudah otomatis mengecualikan hari
  /// sebelum `habit.startDate`) sampai hari ini, bukan diproyeksikan ke
  /// seluruh bulan yang belum berjalan. Beda dari [financeSummaryProvider]
  /// biasa, yang sengaja TIDAK di-clamp supaya "X dari Rp Y budget" &
  /// `paceAt` di tab Monthly tetap membandingkan ke cap bulan penuh. Untuk
  /// bulan yang sudah lewat, clamp ke hari ini tidak berpengaruh — hasilnya
  /// otomatis sama dengan bulan penuh karena akhir bulan sudah di masa lalu.

  FinanceMonthToDateSummaryProvider call(DateTime monthAnchor) =>
      FinanceMonthToDateSummaryProvider._(argument: monthAnchor, from: this);

  @override
  String toString() => r'financeMonthToDateSummaryProvider';
}

/// Rangkuman keuangan untuk [period] (harian/mingguan/bulanan) yang memuat
/// [anchor] — dipakai layar Rangkuman Keuangan untuk toggle Daily/Weekly/
/// Monthly (`selectedFinancePeriodProvider`).

@ProviderFor(financeSummaryForPeriod)
final financeSummaryForPeriodProvider = FinanceSummaryForPeriodFamily._();

/// Rangkuman keuangan untuk [period] (harian/mingguan/bulanan) yang memuat
/// [anchor] — dipakai layar Rangkuman Keuangan untuk toggle Daily/Weekly/
/// Monthly (`selectedFinancePeriodProvider`).

final class FinanceSummaryForPeriodProvider
    extends
        $FunctionalProvider<
          AsyncValue<FinanceSummary>,
          FinanceSummary,
          FutureOr<FinanceSummary>
        >
    with $FutureModifier<FinanceSummary>, $FutureProvider<FinanceSummary> {
  /// Rangkuman keuangan untuk [period] (harian/mingguan/bulanan) yang memuat
  /// [anchor] — dipakai layar Rangkuman Keuangan untuk toggle Daily/Weekly/
  /// Monthly (`selectedFinancePeriodProvider`).
  FinanceSummaryForPeriodProvider._({
    required FinanceSummaryForPeriodFamily super.from,
    required (FinancePeriod, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'financeSummaryForPeriodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$financeSummaryForPeriodHash();

  @override
  String toString() {
    return r'financeSummaryForPeriodProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<FinanceSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FinanceSummary> create(Ref ref) {
    final argument = this.argument as (FinancePeriod, DateTime);
    return financeSummaryForPeriod(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FinanceSummaryForPeriodProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$financeSummaryForPeriodHash() =>
    r'fc21dde0cd79eb9514e8996301a2e5569b64df91';

/// Rangkuman keuangan untuk [period] (harian/mingguan/bulanan) yang memuat
/// [anchor] — dipakai layar Rangkuman Keuangan untuk toggle Daily/Weekly/
/// Monthly (`selectedFinancePeriodProvider`).

final class FinanceSummaryForPeriodFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<FinanceSummary>,
          (FinancePeriod, DateTime)
        > {
  FinanceSummaryForPeriodFamily._()
    : super(
        retry: null,
        name: r'financeSummaryForPeriodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rangkuman keuangan untuk [period] (harian/mingguan/bulanan) yang memuat
  /// [anchor] — dipakai layar Rangkuman Keuangan untuk toggle Daily/Weekly/
  /// Monthly (`selectedFinancePeriodProvider`).

  FinanceSummaryForPeriodProvider call(FinancePeriod period, DateTime anchor) =>
      FinanceSummaryForPeriodProvider._(argument: (period, anchor), from: this);

  @override
  String toString() => r'financeSummaryForPeriodProvider';
}
