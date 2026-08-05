// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allActiveHabits)
final allActiveHabitsProvider = AllActiveHabitsProvider._();

final class AllActiveHabitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Habit>>,
          List<Habit>,
          Stream<List<Habit>>
        >
    with $FutureModifier<List<Habit>>, $StreamProvider<List<Habit>> {
  AllActiveHabitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allActiveHabitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allActiveHabitsHash();

  @$internal
  @override
  $StreamProviderElement<List<Habit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Habit>> create(Ref ref) {
    return allActiveHabits(ref);
  }
}

String _$allActiveHabitsHash() => r'2ec3deb6a3c9ae1377bccca85ce69644ddf549f9';
