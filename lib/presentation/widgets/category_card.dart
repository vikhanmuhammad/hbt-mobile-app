import 'package:flutter/material.dart';

import '../../domain/models/category_progress.dart';
import '../theme/app_colors.dart';
import 'category_icon.dart';
import 'daily_progress_ring.dart';

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
        side: BorderSide(
          color: selected ? accentColor : theme.dividerColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIconData(category.icon),
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  DailyProgressRing(
                    done: progress.doneCount,
                    total: progress.totalCount,
                    size: 40,
                    strokeWidth: 4,
                    color: accentColor,
                    centerLabel: '',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                category.name,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                progress.totalCount == 0
                    ? 'Belum ada habit hari ini'
                    : '${progress.doneCount}/${progress.totalCount} selesai',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color categoryAccentColor(String? colorHex, int fallbackIndex) =>
    AppColors.categoryColorFromHex(colorHex, fallbackIndex);
