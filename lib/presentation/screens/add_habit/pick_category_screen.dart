import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/category_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/responsive_grid.dart';
import 'create_category_screen.dart';
import 'recommendation_screen.dart';

/// Step 1 alur Tambah Habit: grid kategori (bawaan + custom) + kartu
/// "Buat Kategori Baru" di akhir grid. Lihat CLAUDE.md §3.3, DESIGN.md §4.5.
class PickCategoryScreen extends ConsumerWidget {
  const PickCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kategori')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Gagal memuat kategori: $e')),
        data: (categories) {
          final columns = categoryGridColumns(MediaQuery.sizeOf(context).width);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == categories.length) {
                return _NewCategoryTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateCategoryScreen()),
                  ),
                );
              }
              final category = categories[index];
              final color = AppColors.categoryColorFromHex(category.colorHex, index);
              return _CategoryTile(
                name: category.name,
                icon: category.icon,
                color: color,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecommendationScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String? icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(categoryIconData(icon), color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewCategoryTile extends StatelessWidget {
  const _NewCategoryTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor, style: BorderStyle.solid),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 10),
              Text('Kategori Baru', style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
