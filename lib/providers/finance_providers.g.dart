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

String _$financeSummaryHash() => r'b5bc7b8d172c9646c228bb0a194c8de86eae9f8f';

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
