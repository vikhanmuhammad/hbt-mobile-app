// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardSummary)
final dashboardSummaryProvider = DashboardSummaryProvider._();

final class DashboardSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardSummary>,
          DashboardSummary,
          FutureOr<DashboardSummary>
        >
    with $FutureModifier<DashboardSummary>, $FutureProvider<DashboardSummary> {
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

String _$dashboardSummaryHash() => r'0fcb44d745a3f7eaa2d44586f62515e7718f3eea';

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

String _$monthSummariesHash() => r'2825ab0921c77b6233e8d22d5c3cd980abd5592f';

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
