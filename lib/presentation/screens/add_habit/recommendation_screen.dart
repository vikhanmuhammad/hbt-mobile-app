import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/habit_template.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/template_providers.dart';
import '../../widgets/habit_form_sheet.dart';
import '../../widgets/recommendation_list.dart';

/// Step 2 alur Tambah Habit: rekomendasi template dari kategori terpilih
/// (checkbox multi-select, langsung tambah) + entri "Tambah Habit Kustom".
/// Lihat CLAUDE.md §3.3 dan DESIGN.md §4.5.
class RecommendationScreen extends ConsumerStatefulWidget {
  const RecommendationScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  ConsumerState<RecommendationScreen> createState() =>
      _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  final Set<HabitTemplate> _selected = {};
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(habitTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Gagal memuat rekomendasi: $e')),
        data: (categoryTemplates) {
          final match = categoryTemplates
              .where((c) => c.name == widget.categoryName)
              .toList();
          final templates = match.isEmpty ? <HabitTemplate>[] : match.first.habits;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (templates.isNotEmpty) ...[
                Text(
                  'Rekomendasi habit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Centang beberapa habit untuk langsung ditambahkan, atau tap untuk mengubah dulu.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                HabitTemplateCheckboxList(
                  templates: templates,
                  selected: _selected,
                  onToggle: (t) => setState(() {
                    if (_selected.contains(t)) {
                      _selected.remove(t);
                    } else {
                      _selected.add(t);
                    }
                  }),
                  onTapRow: _openFormForTemplate,
                ),
                const SizedBox(height: 8),
              ],
              CustomHabitEntryTile(onTap: _openCustomForm),
            ],
          );
        },
      ),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _adding ? null : _addSelected,
                child: Text('Tambah ${_selected.length} Habit Terpilih'),
              ),
            ),
    );
  }

  Future<void> _openFormForTemplate(HabitTemplate template) async {
    final saved = await showHabitFormSheet(
      context,
      initialCategoryId: widget.categoryId,
      prefill: HabitFormPrefill(
        name: template.name,
        goalPeriod: template.goalPeriod,
        goalValue: template.goalValue,
        timeRange: template.timeRange,
      ),
    );
    if (saved == true && mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  Future<void> _openCustomForm() async {
    final saved = await showHabitFormSheet(
      context,
      initialCategoryId: widget.categoryId,
    );
    if (saved == true && mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  Future<void> _addSelected() async {
    setState(() => _adding = true);
    final repo = ref.read(habitRepositoryProvider);
    final notif = ref.read(notificationServiceProvider);

    for (final t in _selected) {
      final id = await repo.createHabit(
        categoryId: widget.categoryId,
        name: t.name,
        goalPeriod: t.goalPeriod,
        goalValue: t.goalValue,
        taskDays: const ['all'],
        timeRange: t.timeRange,
        reminderEnabled: false,
        startDate: today(),
      );
      final created = await repo.getById(id);
      if (created != null) await notif.rescheduleForHabit(created);
    }

    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);

    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }
}
