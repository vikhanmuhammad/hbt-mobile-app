import 'package:flutter/material.dart';

/// Peta kunci ikon kategori (dari `habit_templates.json` / input user saat
/// buat kategori custom) ke Material icon yang dipakai di seluruh app.
IconData categoryIconData(String? key) {
  switch (key) {
    case 'health':
      return Icons.favorite_rounded;
    case 'sports':
      return Icons.directions_run_rounded;
    case 'productivity':
      return Icons.checklist_rounded;
    case 'mindfulness':
      return Icons.self_improvement_rounded;
    case 'finance':
      return Icons.savings_rounded;
    case 'social':
      return Icons.groups_rounded;
    default:
      return Icons.star_rounded;
  }
}

/// Daftar pilihan ikon untuk form "Buat Kategori Baru".
const List<String> customCategoryIconChoices = [
  'health',
  'sports',
  'productivity',
  'mindfulness',
  'finance',
  'social',
  'other',
];
