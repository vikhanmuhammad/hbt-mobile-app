import 'package:flutter_riverpod/legacy.dart';

import '../domain/date_utils.dart';

/// Tanggal yang sedang dilihat di layar Riwayat/Kalender.
final selectedHistoryDateProvider =
    StateProvider<DateTime>((ref) => today());

/// Bulan yang sedang ditampilkan di grid kalender Riwayat.
final selectedHistoryMonthProvider =
    StateProvider<DateTime>((ref) => DateTime(today().year, today().month));

/// Kategori yang sedang dipilih di layar Category Detail (Beranda level 2),
/// null berarti masih di level grid kategori (dipakai untuk layout tablet
/// master-detail, lihat DESIGN.md §4.2).
final selectedCategoryIdProvider = StateProvider<int?>((ref) => null);
