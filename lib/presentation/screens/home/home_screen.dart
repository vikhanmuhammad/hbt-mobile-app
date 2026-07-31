import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_card.dart';
import '../../widgets/daily_progress_ring.dart';
import '../../widgets/responsive_grid.dart';
import 'category_detail_screen.dart';
import 'category_detail_view.dart';

/// Beranda level 1: header "Hari ini" + ring keseluruhan, grid kategori.
/// Tablet >=900dp: master-detail (grid kiri, detail kanan). Lihat
/// DESIGN.md §4.2 & prototipe baris ~406-441 (tanpa AppBar/judul halaman).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final date = today();
    // Kategori tanpa habit sama sekali disembunyikan dari grid Beranda —
    // cukup tampil di step "Pilih Kategori" saat Tambah Habit.
    final categoryProgress =
        ref.watch(categoryProgressListProvider(date)).where((c) => c.hasAnyHabit).toList();
    final home = ref.watch(homeProgressProvider(date));

    final level1 = ListView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 16,
        isTablet ? 32 : 20,
        isTablet ? 32 : 16,
        110,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hari ini',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(formatFullDate(date), style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            const SizedBox(width: 16),
            DailyProgressRing(
              done: home.done,
              total: home.total,
              size: 76,
              strokeWidth: 8,
              centerLabel: '${home.done}/${home.total}',
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (categoryProgress.isEmpty)
          const _EmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: categoryGridColumns(MediaQuery.sizeOf(context).width),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemCount: categoryProgress.length,
            itemBuilder: (context, index) {
              final progress = categoryProgress[index];
              final selected = ref.watch(selectedCategoryIdProvider) == progress.category.id;
              return CategoryCard(
                progress: progress,
                accentColor: AppColors.categoryColorFromHex(progress.category.colorHex, index),
                selected: isWide && selected,
                onTap: () {
                  if (isWide) {
                    ref.read(selectedCategoryIdProvider.notifier).state = progress.category.id;
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailScreen(
                          categoryId: progress.category.id,
                          categoryName: progress.category.name,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
      ],
    );

    if (!isWide) return level1;

    final selectedId = ref.watch(selectedCategoryIdProvider);
    return Row(
      children: [
        SizedBox(width: 380, child: level1),
        const SizedBox(width: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 32, 32),
            child: selectedId == null
                ? Center(
                    child: Text(
                      'Pilih kategori untuk melihat detail',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : CategoryDetailView(categoryId: selectedId),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_rounded, size: 48, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text('Belum ada habit', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Tap tombol Tambah Habit di kiri bawah untuk menambah habit pertamamu. '
            'Kategori akan muncul di sini setelah ada habit di dalamnya.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
