import 'package:flutter_riverpod/legacy.dart';

import '../domain/date_utils.dart';
import '../domain/onboarding_strings.dart';
import 'core_providers.dart';

/// Language used for onboarding's intro copy/questions — seeded from the
/// persisted global `appLanguageProvider` (Settings > Language) so
/// onboarding opens in whatever language the user last picked, instead of
/// always defaulting to English. Onboarding's own language toggle also
/// writes back through `appLanguageProvider` (see onboarding_flow.dart) so
/// the two stay in sync going forward.
final introLanguageProvider = StateProvider<OnboardingLang>((ref) {
  final code = ref.read(settingsRepositoryProvider).language;
  return code == 'id' ? OnboardingLang.id : OnboardingLang.en;
});

/// Tanggal yang sedang dipilih di kalender layar Dashboard (menentukan hari
/// mana yang dibuka lewat bottom sheet detail).
final selectedDashboardDateProvider =
    StateProvider<DateTime>((ref) => today());

/// Bulan yang sedang ditampilkan di grid kalender Dashboard.
final selectedDashboardMonthProvider =
    StateProvider<DateTime>((ref) => DateTime(today().year, today().month));

/// Filter habit aktif di layar Dashboard (icon-icon di atas kalender) — set
/// kosong berarti "All" (tanpa filter, semua habit ikut dihitung). Non-kosong
/// membatasi ring kalender & ringkasan dashboard cuma ke habit yang dipilih.
final selectedDashboardHabitIdsProvider =
    StateProvider<Set<int>>((ref) => <int>{});

/// Tanggal yang sedang ditampilkan di Beranda (flat list + date strip).
/// Bulan date strip mengikuti `DateTime(date.year, date.month)`. CLAUDE.md
/// v3 §6.1.
final selectedHomeDateProvider = StateProvider<DateTime>((ref) => today());

/// Edit Mode Beranda (CLAUDE.md v3 §6.3), diaktifkan lewat FAB kanan bawah —
/// state global (bukan lokal HomeScreen) supaya NavigationShell juga bisa
/// merender FAB yang sesuai.
final homeEditModeProvider = StateProvider<bool>((ref) => false);

/// Bulan yang sedang ditampilkan di layar Rangkuman Keuangan.
final selectedFinanceMonthProvider =
    StateProvider<DateTime>((ref) => DateTime(today().year, today().month));

/// Granularitas periode yang sedang ditampilkan di layar Rangkuman Keuangan
/// (harian/mingguan/bulanan) — `selectedFinanceMonthProvider` di atas tetap
/// dipakai sebagai anchor bulan saat mode `monthly`; mode `daily`/`weekly`
/// pakai `selectedFinanceAnchorDateProvider` di bawah.
enum FinancePeriod { daily, weekly, monthly }

final selectedFinancePeriodProvider =
    StateProvider<FinancePeriod>((ref) => FinancePeriod.monthly);

/// Tanggal anchor untuk mode `daily`/`weekly` di layar Rangkuman Keuangan.
final selectedFinanceAnchorDateProvider =
    StateProvider<DateTime>((ref) => today());
