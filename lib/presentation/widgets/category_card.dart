import 'package:flutter/material.dart';

import '../../domain/models/category_progress.dart';
import 'daily_progress_ring.dart';
import 'habit_icon.dart';

/// Kartu kategori grid Beranda level 1. Ikon = bulatan solid warna kategori
/// + glyph putih, ring progress kecil di kanan. Lihat prototipe baris ~424.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.progress,
    required this.accentColor,
    required this.onTap,
    this.selected = false,
  });

  final CategoryProgress progress;
  final Color accentColor;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = progress.category;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: selected
            ? BorderSide(color: accentColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    child: Center(
                      child: HabitIcon(icon: category.icon, size: 15, color: Colors.white),
                    ),
                  ),
                  DailyProgressRing(
                    done: progress.doneCount,
                    total: progress.totalCount,
                    size: 34,
                    strokeWidth: 4,
                    color: accentColor,
                    centerLabel: '',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                progress.totalCount == 0
                    ? 'Tidak ada jadwal'
                    : '${progress.doneCount}/${progress.totalCount} hari ini',
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
