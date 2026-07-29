import 'enums.dart';

class HabitTemplate {
  const HabitTemplate({
    required this.name,
    required this.goalPeriod,
    required this.goalValue,
    required this.timeRange,
  });

  final String name;
  final GoalPeriod goalPeriod;
  final int goalValue;
  final TimeRange timeRange;

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      name: json['name'] as String,
      goalPeriod: GoalPeriod.fromValue(json['goalPeriod'] as String),
      goalValue: json['goalValue'] as int,
      timeRange: TimeRange.fromValue(json['timeRange'] as String),
    );
  }

  String get goalSummary => '$goalValue x / ${goalPeriod.unitLabel}';
}

class CategoryTemplate {
  const CategoryTemplate({
    required this.key,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.habits,
  });

  final String key;
  final String name;
  final String icon;
  final String colorHex;
  final List<HabitTemplate> habits;

  factory CategoryTemplate.fromJson(Map<String, dynamic> json) {
    return CategoryTemplate(
      key: json['key'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      colorHex: json['color'] as String? ?? '',
      habits: (json['habits'] as List)
          .map((e) => HabitTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
