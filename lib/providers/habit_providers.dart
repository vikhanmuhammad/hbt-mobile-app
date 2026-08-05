import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/habit.dart';
import 'core_providers.dart';

part 'habit_providers.g.dart';

@riverpod
Stream<List<Habit>> allActiveHabits(Ref ref) {
  return ref.watch(habitRepositoryProvider).watchAllActive();
}
