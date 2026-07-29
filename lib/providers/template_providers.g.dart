// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitTemplates)
final habitTemplatesProvider = HabitTemplatesProvider._();

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
  HabitTemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitTemplatesProvider',
        isAutoDispose: true,
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

String _$habitTemplatesHash() => r'8c844310ec184c161c98687bced52c48b70d33d3';
