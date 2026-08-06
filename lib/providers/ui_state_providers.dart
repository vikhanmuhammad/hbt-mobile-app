import 'package:flutter_riverpod/legacy.dart';

import '../domain/date_utils.dart';

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
