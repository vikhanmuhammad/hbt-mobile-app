import '../language.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.colorHex,
    required this.isDefault,
    required this.isArchived,
    required this.createdAt,
    this.nameId,
    this.templateKey,
  });

  final int id;
  final String name;
  final String? icon;
  final String? colorHex;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;

  /// Terjemahan Indonesia dari [name] (goal phrase) — null kalau belum
  /// diisi (kategori lama/custom), fallback ke [name] lewat [displayName].
  final String? nameId;

  /// Key stabil ke entri kategori di `habit_templates.json`. Null untuk
  /// kategori custom buatan user.
  final String? templateKey;

  String displayName(AppLang lang) =>
      lang == AppLang.id ? (nameId ?? name) : name;
}

/// Key stabil kategori Finance di `habit_templates.json` (`key: "finance"`).
/// Dipakai untuk identifikasi kategori Finance karena `Category.name`
/// sekarang bisa berupa goal phrase bahasa Indonesia maupun Inggris —
/// bergantung ke string nama akan rusak begitu bahasa berbeda. Kategori
/// custom tidak pernah punya `templateKey`, jadi tidak pernah dianggap
/// kategori Finance.
const financeCategoryTemplateKey = 'finance';

bool isFinanceCategory(Category category) =>
    category.isDefault && category.templateKey == financeCategoryTemplateKey;

/// Short blurb shown under each goal phrase title on the "Pick Goal Phrase"
/// step, keyed by `Category.templateKey` (stable across bahasa) — default
/// categories only, since custom ones fall back to a generic description.
const Map<String, String> goalPhraseDescriptions = {
  'health': 'Build daily habits for a healthier body.',
  'exercise': 'Move more and stay physically fit.',
  'productivity': 'Get more done with focused daily routines.',
  'mindfulness': 'Take care of your mind and reduce stress.',
  'finance': 'Track spending and grow your savings.',
  'social': 'Stay connected with people who matter.',
  'learning': 'Grow your knowledge and skills every day.',
  'sleep': 'Build a healthier, more consistent sleep routine.',
  'creativity': 'Make space for imagination and self-expression.',
  'home': 'Keep your living space clean and organized.',
  'career': 'Build momentum toward your professional goals.',
  'environment': 'Live more sustainably, one habit at a time.',
  'selfcare': 'Look after your wellbeing and recharge.',
};

String goalPhraseDescriptionFor(Category category) =>
    goalPhraseDescriptions[category.templateKey] ?? 'A custom goal you created.';
