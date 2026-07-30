import 'package:flutter/material.dart';

import 'category_detail_view.dart';

/// Wrapper full-screen untuk mobile (push route) — tanpa AppBar sistem,
/// header (back/dot/nama/tombol +Habit) sudah dibangun di dalam
/// [CategoryDetailView] sendiri, persis prototipe.
class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CategoryDetailView(
            categoryId: categoryId,
            showBackButton: true,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
