import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/habit_template.dart';

class HabitTemplatesLoader {
  const HabitTemplatesLoader();

  static const _assetPath = 'assets/data/habit_templates.json';

  Future<List<CategoryTemplate>> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final categories = json['categories'] as List;
    return categories
        .map((e) => CategoryTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
