import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/assets/habit_templates_loader.dart';
import '../data/database/app_database.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/habit_log_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/habit_template_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/stats_repository.dart';
import '../services/notification_service.dart';

part 'core_providers.g.dart';

/// Di-override di main() dengan instance nyata sebelum runApp, karena
/// pembuatannya perlu `await SharedPreferences.getInstance()`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider belum di-override');
});

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService.instance;

@riverpod
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepository(ref.watch(appDatabaseProvider));
}

@riverpod
HabitRepository habitRepository(Ref ref) {
  return HabitRepository(ref.watch(appDatabaseProvider));
}

@riverpod
HabitLogRepository habitLogRepository(Ref ref) {
  return HabitLogRepository(ref.watch(appDatabaseProvider));
}

@riverpod
StatsRepository statsRepository(Ref ref) {
  return StatsRepository(ref.watch(appDatabaseProvider));
}

@riverpod
HabitTemplateRepository habitTemplateRepository(Ref ref) {
  return HabitTemplateRepository(const HabitTemplatesLoader());
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
}
