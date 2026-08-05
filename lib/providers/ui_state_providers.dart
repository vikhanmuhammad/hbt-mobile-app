import 'package:flutter_riverpod/legacy.dart';

import '../domain/date_utils.dart';

/// Tanggal yang sedang dilihat di layar Riwayat/Kalender.
final selectedHistoryDateProvider =
    StateProvider<DateTime>((ref) => today());

/// Bulan yang sedang ditampilkan di grid kalender Riwayat.
final selectedHistoryMonthProvider =
    StateProvider<DateTime>((ref) => DateTime(today().year, today().month));

/// Tanggal yang sedang ditampilkan di Beranda (flat list + date strip).
/// Bulan date strip mengikuti `DateTime(date.year, date.month)`. CLAUDE.md
/// v3 §6.1.
final selectedHomeDateProvider = StateProvider<DateTime>((ref) => today());

/// Edit Mode Beranda (CLAUDE.md v3 §6.3), diaktifkan lewat FAB kanan bawah —
/// state global (bukan lokal HomeScreen) supaya NavigationShell juga bisa
/// merender FAB yang sesuai.
final homeEditModeProvider = StateProvider<bool>((ref) => false);
