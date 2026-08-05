import 'enums.dart';

class HabitTemplate {
  const HabitTemplate({
    required this.name,
    this.icon,
    required this.goalPeriod,
    required this.goalValue,
    this.goalUnit = 'x',
    required this.timeRange,
  });

  final String name;
  final String? icon;
  final GoalPeriod goalPeriod;
  final int goalValue;
  final String goalUnit;
  final TimeRange timeRange;

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      name: json['name'] as String,
      icon: json['icon'] as String?,
      goalPeriod: GoalPeriod.fromValue(json['goalPeriod'] as String),
      goalValue: json['goalValue'] as int,
      goalUnit: json['unit'] as String? ?? json['goalUnit'] as String? ?? 'x',
      timeRange: TimeRange.fromValue(json['timeRange'] as String),
    );
  }

  /// Mis. "8 gelas" atau "1x", persis format `unitLabel` di prototipe.
  String get goalValueLabel =>
      goalUnit == 'x' ? '${goalValue}x' : '$goalValue $goalUnit';

  String get goalLabel => '$goalValueLabel • ${goalPeriod.label}';
}

/// Grouping kategori mentah dari `habit_templates.json` — cuma dipakai untuk
/// browsing rekomendasi habit (label pengelompokan), bukan ditampilkan
/// sebagai kategori utama. Lihat CLAUDE.md v3 §3.2.
class CategoryTemplate {
  const CategoryTemplate({
    required this.key,
    required this.rawLabel,
    required this.defaultGoalPhrase,
    required this.icon,
    required this.colorHex,
    required this.habits,
  });

  final String key;

  /// Nama mentah internal (mis. "Kesehatan") — cuma sub-label kecil saat
  /// browsing rekomendasi, tidak pernah ditampilkan sebagai kategori utama.
  final String rawLabel;

  /// Goal phrase default (mis. "Jadi Sehat") — inilah yang disimpan sebagai
  /// `Categories.name` saat seeding & dipakai untuk mencocokkan kategori user
  /// dengan grup template ini.
  final String defaultGoalPhrase;
  final String icon;
  final String colorHex;
  final List<HabitTemplate> habits;

  factory CategoryTemplate.fromJson(Map<String, dynamic> json) {
    return CategoryTemplate(
      key: json['key'] as String,
      rawLabel: json['rawLabel'] as String? ?? json['name'] as String,
      defaultGoalPhrase: json['defaultGoalPhrase'] as String? ??
          json['rawLabel'] as String? ??
          json['name'] as String,
      icon: json['icon'] as String,
      colorHex: json['color'] as String? ?? '',
      habits: (json['habits'] as List)
          .map((e) => HabitTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
