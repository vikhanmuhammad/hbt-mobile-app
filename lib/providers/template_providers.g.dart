// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// keepAlive supaya instance `HabitTemplate` tetap sama sepanjang sesi app —
/// data statis dari asset JSON, tidak pernah berubah saat runtime. Tanpa ini,
/// provider di-dispose tiap kali halaman yang mem-watch-nya keluar dari
/// viewport (mis. PageView onboarding), lalu di-refetch jadi instance BARU
/// saat kembali — merusak `Set<HabitTemplate>.contains()` yang dipakai untuk
/// state "template mana yang sudah dicentang" di alur onboarding.

@ProviderFor(habitTemplates)
final habitTemplatesProvider = HabitTemplatesProvider._();

/// keepAlive supaya instance `HabitTemplate` tetap sama sepanjang sesi app —
/// data statis dari asset JSON, tidak pernah berubah saat runtime. Tanpa ini,
/// provider di-dispose tiap kali halaman yang mem-watch-nya keluar dari
/// viewport (mis. PageView onboarding), lalu di-refetch jadi instance BARU
/// saat kembali — merusak `Set<HabitTemplate>.contains()` yang dipakai untuk
/// state "template mana yang sudah dicentang" di alur onboarding.

final class HabitTemplatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryTemplate>>,
          List<CategoryTemplate>,
          FutureOr<List<CategoryTemplate>>
        >
    with
        $FutureModifier<List<CategoryTemplate>>,
        $FutureProvider<List<CategoryTemplate>> {
  /// keepAlive supaya instance `HabitTemplate` tetap sama sepanjang sesi app —
  /// data statis dari asset JSON, tidak pernah berubah saat runtime. Tanpa ini,
  /// provider di-dispose tiap kali halaman yang mem-watch-nya keluar dari
  /// viewport (mis. PageView onboarding), lalu di-refetch jadi instance BARU
  /// saat kembali — merusak `Set<HabitTemplate>.contains()` yang dipakai untuk
  /// state "template mana yang sudah dicentang" di alur onboarding.
  HabitTemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitTemplatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitTemplatesHash();

  @$internal
  @override
  $FutureProviderElement<List<CategoryTemplate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryTemplate>> create(Ref ref) {
    return habitTemplates(ref);
  }
}

String _$habitTemplatesHash() => r'67e0446b01f49c6c653791a4aabfe8edefba30a2';
