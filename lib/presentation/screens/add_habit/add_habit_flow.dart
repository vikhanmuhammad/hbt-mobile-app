import 'package:flutter/material.dart';

import 'pick_category_screen.dart';

/// Entrypoint alur Tambah Habit dari FAB kiri bawah di Beranda.
/// Lihat CLAUDE.md §3.3.
void openAddHabitFlow(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const PickCategoryScreen()),
  );
}
