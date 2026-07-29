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

/// Beranda level 1: grid kategori dengan progress ring per kategori.
/// Tablet >=900dp: master-detail (grid kiri, detail kanan). Lihat
/// DESIGN.md §4.2.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final date = today();
    final categoryProgress = ref.watch(categoryProgressListProvider(date));
    final home = ref.watch(homeProgressProvider(date));

    final grid = CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Beranda'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                DailyProgressRing(done: home.done, total: home.total, size: 84),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress hari ini', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        home.total == 0
                            ? 'Belum ada habit aktif hari ini'
                            : '${home.done} dari ${home.total} habit selesai',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (categoryProgress.isEmpty)
          const SliverFillRemaining(
            child: _EmptyState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: categoryGridColumns(MediaQuery.sizeOf(context).width),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final progress = categoryProgress[index];
                  final selected = ref.watch(selectedCategoryIdProvider) == progress.category.id;
                  return CategoryCard(
                    progress: progress,
                    accentColor:
                        AppColors.categoryColorFromHex(progress.category.colorHex, index),
                    selected: isWide && selected,
                    onTap: () {
                      if (isWide) {
                        ref.read(selectedCategoryIdProvider.notifier).state =
                            progress.category.id;
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
                childCount: categoryProgress.length,
              ),
            ),
          ),
      ],
    );

    if (!isWide) return grid;

    final selectedId = ref.watch(selectedCategoryIdProvider);
    return Row(
      children: [
        SizedBox(width: 380, child: grid),
        const VerticalDivider(width: 1),
        Expanded(
          child: selectedId == null
              ? const Center(child: Text('Pilih kategori untuk melihat detail'))
              : CategoryDetailView(categoryId: selectedId),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_rounded, size: 48, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text('Belum ada kategori', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Tap tombol Tambah Habit di kiri bawah untuk membuat kategori & habit pertamamu.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
