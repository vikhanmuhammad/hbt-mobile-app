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
