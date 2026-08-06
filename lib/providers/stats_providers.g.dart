// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Otomatis reaktif terhadap filter icon habit di layar Dashboard —
/// `selectedDashboardHabitIdsProvider` di-watch di sini (bukan lewat family
/// parameter) supaya perubahan Set tidak bergantung pada `Set` punya value
/// equality (defaultnya identity-based di Dart).

@ProviderFor(dashboardSummary)
final dashboardSummaryProvider = DashboardSummaryProvider._();

/// Otomatis reaktif terhadap filter icon habit di layar Dashboard —
/// `selectedDashboardHabitIdsProvider` di-watch di sini (bukan lewat family
/// parameter) supaya perubahan Set tidak bergantung pada `Set` punya value
/// equality (defaultnya identity-based di Dart).

final class DashboardSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardSummary>,
          DashboardSummary,
          FutureOr<DashboardSummary>
        >
    with $FutureModifier<DashboardSummary>, $FutureProvider<DashboardSummary> {
  /// Otomatis reaktif terhadap filter icon habit di layar Dashboard —
  /// `selectedDashboardHabitIdsProvider` di-watch di sini (bukan lewat family
  /// parameter) supaya perubahan Set tidak bergantung pada `Set` punya value
  /// equality (defaultnya identity-based di Dart).
  DashboardSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardSummaryHash();

  @$internal
  @override
  $FutureProviderElement<DashboardSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardSummary> create(Ref ref) {
    return dashboardSummary(ref);
  }
}

String _$dashboardSummaryHash() => r'351c3cad5db71139509530b16989e5d185245b22';

@ProviderFor(monthSummaries)
final monthSummariesProvider = MonthSummariesFamily._();

final class MonthSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DaySummary>>,
          List<DaySummary>,
          FutureOr<List<DaySummary>>
        >
    with $FutureModifier<List<DaySummary>>, $FutureProvider<List<DaySummary>> {
  MonthSummariesProvider._({
    required MonthSummariesFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'monthSummariesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthSummariesHash();

  @override
  String toString() {
    return r'monthSummariesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DaySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DaySummary>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return monthSummaries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthSummariesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthSummariesHash() => r'f2337fa0601eef324fe0a7b8827b7597d7cbe392';

final class MonthSummariesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DaySummary>>, DateTime> {
  MonthSummariesFamily._()
    : super(
        retry: null,
        name: r'monthSummariesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthSummariesProvider call(DateTime monthAnchor) =>
      MonthSummariesProvider._(argument: monthAnchor, from: this);

  @override
  String toString() => r'monthSummariesProvider';
}

@ProviderFor(daySummary)
final daySummaryProvider = DaySummaryFamily._();

final class DaySummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DaySummary>,
          DaySummary,
          FutureOr<DaySummary>
        >
    with $FutureModifier<DaySummary>, $FutureProvider<DaySummary> {
  DaySummaryProvider._({
    required DaySummaryFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'daySummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$daySummaryHash();

  @override
  String toString() {
    return r'daySummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DaySummary> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DaySummary> create(Ref ref) {
    final argument = this.argument as DateTime;
    return daySummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DaySummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$daySummaryHash() => r'00767043ab8b1fc9c87e698f4c8ac8a6ded1c93d';

final class DaySummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DaySummary>, DateTime> {
  DaySummaryFamily._()
    : super(
        retry: null,
        name: r'daySummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DaySummaryProvider call(DateTime date) =>
      DaySummaryProvider._(argument: date, from: this);

  @override
  String toString() => r'daySummaryProvider';
}
