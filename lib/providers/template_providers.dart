import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/habit_template.dart';
import 'core_providers.dart';

part 'template_providers.g.dart';

/// keepAlive supaya instance `HabitTemplate` tetap sama sepanjang sesi app —
/// data statis dari asset JSON, tidak pernah berubah saat runtime. Tanpa ini,
/// provider di-dispose tiap kali halaman yang mem-watch-nya keluar dari
/// viewport (mis. PageView onboarding), lalu di-refetch jadi instance BARU
/// saat kembali — merusak `Set<HabitTemplate>.contains()` yang dipakai untuk
/// state "template mana yang sudah dicentang" di alur onboarding.
@Riverpod(keepAlive: true)
Future<List<CategoryTemplate>> habitTemplates(Ref ref) {
  return ref.watch(habitTemplateRepositoryProvider).getAll();
}
