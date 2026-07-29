// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitsByCategory)
final habitsByCategoryProvider = HabitsByCategoryFamily._();

final class HabitsByCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Habit>>,
          List<Habit>,
          Stream<List<Habit>>
        >
    with $FutureModifier<List<Habit>>, $StreamProvider<List<Habit>> {
  HabitsByCategoryProvider._({
    required HabitsByCategoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'habitsByCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitsByCategoryHash();

  @override
  String toString() {
    return r'habitsByCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Habit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Habit>> create(Ref ref) {
    final argument = this.argument as int;
    return habitsByCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitsByCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitsByCategoryHash() => r'be0c690df33dc7da6f084b993d7c4b06576255a8';

final class HabitsByCategoryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Habit>>, int> {
  HabitsByCategoryFamily._()
    : super(
        retry: null,
        name: r'habitsByCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitsByCategoryProvider call(int categoryId) =>
      HabitsByCategoryProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'habitsByCategoryProvider';
}

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
