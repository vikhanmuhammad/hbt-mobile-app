import 'package:flutter/material.dart';

import 'category_detail_view.dart';

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
      appBar: AppBar(title: Text(categoryName)),
      body: CategoryDetailView(categoryId: categoryId),
    );
  }
}
