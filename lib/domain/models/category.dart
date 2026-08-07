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

/// Goal phrase kategori Keuangan bawaan (`defaultGoalPhrase` untuk
/// `key: "keuangan"` di habit_templates.json) — satu-satunya cara
/// identifikasi kategori ini karena [Category] tidak punya field key/tipe
/// (lihat CategoryRepository.seedDefaultCategories). Kategori custom tidak
/// pernah dianggap kategori Keuangan.
const financeCategoryGoalPhrase = 'Jadi Hemat';

bool isFinanceCategory(Category category) =>
    category.isDefault && category.name == financeCategoryGoalPhrase;
