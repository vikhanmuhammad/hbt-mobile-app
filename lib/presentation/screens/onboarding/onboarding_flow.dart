import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/habit_template.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../providers/template_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/recommendation_list.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/navigation_shell.dart';

/// Onboarding first-launch, pola rekomendasi ala Spotify/Netflix:
/// Welcome -> Pilih Kategori Minat -> Rekomendasi Habit -> Ringkasan.
/// Lihat CLAUDE.md §3.4, DESIGN.md §4.1.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();

  final Set<int> _selectedCategoryIds = {};
  final Map<int, Set<HabitTemplate>> _selectedTemplates = {};
  List<String> _addedHabitNames = [];

  void _goTo(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _WelcomeStep(onNext: () => _goTo(1)),
            _CategoryPickStep(
              selected: _selectedCategoryIds,
              onToggle: (id) => setState(() {
                if (_selectedCategoryIds.contains(id)) {
                  _selectedCategoryIds.remove(id);
                } else {
                  _selectedCategoryIds.add(id);
                }
              }),
              onNext: () => _goTo(2),
            ),
            _RecommendationStep(
              selectedCategoryIds: _selectedCategoryIds,
              selectedTemplates: _selectedTemplates,
              onToggleTemplate: (categoryId, template) => setState(() {
                final set = _selectedTemplates.putIfAbsent(categoryId, () => {});
                if (set.contains(template)) {
                  set.remove(template);
                } else {
                  set.add(template);
                }
              }),
              onFinish: (addedNames) {
                setState(() => _addedHabitNames = addedNames);
                _goTo(3);
              },
            ),
            _SummaryStep(addedHabitNames: _addedHabitNames),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.child,
    required this.bottomButton,
  });

  final Widget child;
  final Widget bottomButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: bottomButton,
        ),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StepScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.spa_rounded, size: 48, color: AppColors.gold),
              ),
              const SizedBox(height: 28),
              Text('Selamat datang', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Aplikasi ini membantumu membangun kebiasaan baru lewat pemantauan '
                'harian yang konsisten. Penelitian Phillippa Lally (UCL) menunjukkan '
                'rata-rata dibutuhkan ~66 hari untuk sebuah kebiasaan terbentuk — '
                'jadi fokus saja pada konsistensi, bukan kesempurnaan.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Semua data tersimpan di perangkatmu. Tidak ada akun, tidak ada cloud.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomButton: FilledButton(
        onPressed: onNext,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Text('Mulai'),
        ),
      ),
    );
  }
}

class _CategoryPickStep extends ConsumerWidget {
  const _CategoryPickStep({
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return _StepScaffold(
      child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
        data: (categories) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          children: [
            Text('Pilih kategori yang diminati', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Boleh pilih lebih dari satu, sesuai gaya hidupmu.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: categoryGridColumns(MediaQuery.sizeOf(context).width),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final c = categories[index];
                final isSelected = selected.contains(c.id);
                final color = AppColors.categoryColorFromHex(c.colorHex, index);
                return _CategoryPickTile(
                  category: c,
                  color: color,
                  selected: isSelected,
                  onTap: () => onToggle(c.id),
                );
              },
            ),
          ],
        ),
      ),
      bottomButton: FilledButton(
        onPressed: selected.isEmpty ? null : onNext,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Text('Lanjut'),
        ),
      ),
    );
  }
}

class _CategoryPickTile extends StatelessWidget {
  const _CategoryPickTile({
    required this.category,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : null,
          border: Border.all(
            color: selected ? color : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(categoryIconData(category.icon), size: 32, color: color),
            const SizedBox(height: 10),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationStep extends ConsumerStatefulWidget {
  const _RecommendationStep({
    required this.selectedCategoryIds,
    required this.selectedTemplates,
    required this.onToggleTemplate,
    required this.onFinish,
  });

  final Set<int> selectedCategoryIds;
  final Map<int, Set<HabitTemplate>> selectedTemplates;
  final void Function(int categoryId, HabitTemplate template) onToggleTemplate;
  final ValueChanged<List<String>> onFinish;

  @override
  ConsumerState<_RecommendationStep> createState() => _RecommendationStepState();
}

class _RecommendationStepState extends ConsumerState<_RecommendationStep> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final templatesAsync = ref.watch(habitTemplatesProvider);

    return _StepScaffold(
      child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
        data: (categories) => templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('$e')),
          data: (allTemplates) {
            final selectedCategories =
                categories.where((c) => widget.selectedCategoryIds.contains(c.id)).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              children: [
                Text('Rekomendasi habit', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Centang habit yang mau langsung dicoba. Boleh dilewati semua.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                for (final category in selectedCategories) ...[
                  Text(category.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Builder(builder: (context) {
                    final match = allTemplates.where((t) => t.name == category.name);
                    final templates = match.isEmpty ? <HabitTemplate>[] : match.first.habits;
                    if (templates.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('Belum ada rekomendasi untuk kategori ini.'),
                      );
                    }
                    return HabitTemplateCheckboxList(
                      templates: templates,
                      selected: widget.selectedTemplates[category.id] ?? {},
                      onToggle: (t) => widget.onToggleTemplate(category.id, t),
                      onTapRow: (t) => widget.onToggleTemplate(category.id, t),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
      bottomButton: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _saving ? null : () => widget.onFinish(const []),
              child: const Text('Lewati'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _saving ? null : _saveSelections,
              child: Text(_saving ? 'Menyimpan...' : 'Lanjut'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSelections() async {
    setState(() => _saving = true);
    final repo = ref.read(habitRepositoryProvider);
    final notif = ref.read(notificationServiceProvider);
    final addedNames = <String>[];

    for (final entry in widget.selectedTemplates.entries) {
      for (final template in entry.value) {
        final id = await repo.createHabit(
          categoryId: entry.key,
          name: template.name,
          goalPeriod: template.goalPeriod,
          goalValue: template.goalValue,
          taskDays: const ['all'],
          timeRange: template.timeRange,
          reminderEnabled: false,
          startDate: today(),
        );
        final created = await repo.getById(id);
        if (created != null) await notif.rescheduleForHabit(created);
        addedNames.add(template.name);
      }
    }

    if (mounted) widget.onFinish(addedNames);
  }
}

class _SummaryStep extends ConsumerWidget {
  const _SummaryStep({required this.addedHabitNames});

  final List<String> addedHabitNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text('Ringkasan', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            addedHabitNames.isEmpty
                ? 'Belum ada habit ditambahkan. Kamu bisa menambah kapan saja lewat '
                    'tombol Tambah Habit di Beranda.'
                : '${addedHabitNames.length} habit berhasil ditambahkan:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final name in addedHabitNames)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.check_circle_rounded, color: AppColors.gold),
                title: Text(name),
              ),
            ),
        ],
      ),
      bottomButton: FilledButton(
        onPressed: () async {
          await ref.read(onboardingStatusProvider.notifier).complete();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const NavigationShell()),
              (route) => false,
            );
          }
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Text('Mulai Tracking'),
        ),
      ),
    );
  }
}
