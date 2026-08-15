class Category {
  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.colorHex,
    required this.isDefault,
    required this.isArchived,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? icon;
  final String? colorHex;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
}

/// Default goal phrase for the Finance category (`defaultGoalPhrase` for
/// `key: "keuangan"` in habit_templates.json) — the only way to identify
/// this category since [Category] has no key/type field (see
/// CategoryRepository.seedDefaultCategories). Custom categories are never
/// treated as the Finance category.
const financeCategoryGoalPhrase = 'Save Money';

bool isFinanceCategory(Category category) =>
    category.isDefault && category.name == financeCategoryGoalPhrase;

/// Short blurb shown under each goal phrase title on the "Pick Goal Phrase"
/// step, keyed by `Category.name` (the goal phrase) — default categories
/// only, since custom ones fall back to a generic description.
const Map<String, String> goalPhraseDescriptions = {
  'Be Healthy': 'Build daily habits for a healthier body.',
  'Be Active': 'Move more and stay physically fit.',
  'Be Productive': 'Get more done with focused daily routines.',
  'Be Calm': 'Take care of your mind and reduce stress.',
  'Save Money': 'Track spending and grow your savings.',
  'Be Social': 'Stay connected with people who matter.',
};

String goalPhraseDescriptionFor(Category category) =>
    goalPhraseDescriptions[category.name] ?? 'A custom goal you created.';
