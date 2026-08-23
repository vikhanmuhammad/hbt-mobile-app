import '../format_utils.dart';
import '../language.dart';
import 'enums.dart';

class HabitTemplate {
  const HabitTemplate({
    required this.key,
    required this.name,
    this.nameId,
    this.icon,
    required this.goalPeriod,
    required this.goalValue,
    this.goalUnit = 'x',
    this.goalDirection = GoalDirection.atLeast,
    required this.timeRange,
  });

  /// Key stabil (mis. 'drink_water') — dipakai untuk mencocokkan habit lama
  /// ke template ini (backfill isCustom/nameId, lihat `HabitRepository`) dan
  /// sebagai `Habit.templateKey` saat habit baru dibuat dari template ini.
  final String key;
  final String name;

  /// Terjemahan Indonesia dari [name] — dwibahasa (CLAUDE.md §Bahasa).
  final String? nameId;
  final String? icon;
  final GoalPeriod goalPeriod;
  final int goalValue;
  final String goalUnit;
  final GoalDirection goalDirection;
  final TimeRange timeRange;

  String displayName(AppLang lang) =>
      lang == AppLang.id ? (nameId ?? name) : name;

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      key: json['key'] as String,
      name: json['name'] as String,
      nameId: json['nameId'] as String?,
      icon: json['icon'] as String?,
      goalPeriod: GoalPeriod.fromValue(json['goalPeriod'] as String),
      goalValue: json['goalValue'] as int,
      goalUnit: json['unit'] as String? ?? json['goalUnit'] as String? ?? 'x',
      goalDirection: GoalDirection.fromValue(json['goalDirection'] as String? ?? 'atLeast'),
      timeRange: TimeRange.fromValue(json['timeRange'] as String),
    );
  }

  /// Mis. "8 gelas", "1x", atau "Rp 50.000" untuk satuan rupiah, persis
  /// format `unitLabel` di prototipe. Diberi prefix "Maks." untuk template
  /// `atMost` (mis. batas pengeluaran).
  String get goalValueLabel {
    final value = goalUnit == 'rupiah'
        ? formatRupiah(goalValue)
        : (goalUnit == 'x' ? '${goalValue}x' : '$goalValue $goalUnit');
    return goalDirection == GoalDirection.atMost ? 'Maks. $value' : value;
  }

  String goalLabel(AppLang lang) => '$goalValueLabel • ${goalPeriod.label(lang)}';

  /// Value equality — dipakai `Set<HabitTemplate>.contains()` di state
  /// seleksi alur onboarding (CLAUDE.md v3 §4.1 langkah 6). Tanpa ini,
  /// instance baru hasil re-parse `habit_templates.json` (mis. provider yang
  /// di-dispose lalu di-watch ulang) tidak akan cocok dengan instance lama
  /// yang tersimpan di state, walau isinya identik.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTemplate &&
          key == other.key &&
          name == other.name &&
          icon == other.icon &&
          goalPeriod == other.goalPeriod &&
          goalValue == other.goalValue &&
          goalUnit == other.goalUnit &&
          goalDirection == other.goalDirection &&
          timeRange == other.timeRange;

  @override
  int get hashCode =>
      Object.hash(key, name, icon, goalPeriod, goalValue, goalUnit, goalDirection, timeRange);
}

/// Grouping kategori mentah dari `habit_templates.json` — cuma dipakai untuk
/// browsing rekomendasi habit (label pengelompokan), bukan ditampilkan
/// sebagai kategori utama. Lihat CLAUDE.md v3 §3.2.
class CategoryTemplate {
  const CategoryTemplate({
    required this.key,
    required this.rawLabel,
    required this.defaultGoalPhrase,
    this.defaultGoalPhraseId,
    required this.icon,
    required this.colorHex,
    required this.habits,
  });

  final String key;

  /// Internal raw name (e.g. "Health") — just a small sub-label while
  /// browsing recommendations, never shown as the main category.
  final String rawLabel;

  /// Default goal phrase (e.g. "Be Healthy") — this is what's stored as
  /// `Categories.name` during seeding & used to match a user's category
  /// with this template group.
  final String defaultGoalPhrase;

  /// Terjemahan Indonesia dari [defaultGoalPhrase] — dwibahasa (CLAUDE.md
  /// §Bahasa), disimpan sebagai `Categories.nameId` saat seeding.
  final String? defaultGoalPhraseId;
  final String icon;
  final String colorHex;
  final List<HabitTemplate> habits;

  String displayGoalPhrase(AppLang lang) =>
      lang == AppLang.id ? (defaultGoalPhraseId ?? defaultGoalPhrase) : defaultGoalPhrase;

  factory CategoryTemplate.fromJson(Map<String, dynamic> json) {
    return CategoryTemplate(
      key: json['key'] as String,
      rawLabel: json['rawLabel'] as String? ?? json['name'] as String,
      defaultGoalPhrase: json['defaultGoalPhrase'] as String? ??
          json['rawLabel'] as String? ??
          json['name'] as String,
      defaultGoalPhraseId: json['defaultGoalPhraseId'] as String?,
      icon: json['icon'] as String,
      colorHex: json['color'] as String? ?? '',
      habits: (json['habits'] as List)
          .map((e) => HabitTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
