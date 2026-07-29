import 'package:flutter/material.dart';

import '../../domain/models/habit_template.dart';

/// List rekomendasi habit template 1 kategori: checkbox multi-select + tap
/// baris untuk edit-sebelum-simpan. Lihat DESIGN.md §5 (RecommendationList).
class HabitTemplateCheckboxList extends StatelessWidget {
  const HabitTemplateCheckboxList({
    super.key,
    required this.templates,
    required this.selected,
    required this.onToggle,
    required this.onTapRow,
  });

  final List<HabitTemplate> templates;
  final Set<HabitTemplate> selected;
  final ValueChanged<HabitTemplate> onToggle;
  final ValueChanged<HabitTemplate> onTapRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final t in templates)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () => onTapRow(t),
              leading: Checkbox(
                value: selected.contains(t),
                onChanged: (_) => onToggle(t),
              ),
              title: Text(t.name),
              subtitle: Text('${t.goalSummary} • ${t.timeRange.label}'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
      ],
    );
  }
}

class CustomHabitEntryTile extends StatelessWidget {
  const CustomHabitEntryTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.add_rounded),
        ),
        title: const Text('Tambah Habit Kustom'),
        subtitle: const Text('Isi semua detail habit sendiri'),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
