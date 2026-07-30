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
import '../../widgets/category_shape_icon.dart';
import '../../widgets/navigation_shell.dart';
import '../../widgets/responsive_grid.dart';

/// Onboarding first-launch, pola rekomendasi ala Spotify/Netflix:
/// Welcome -> Pilih Kategori Minat -> Rekomendasi Habit -> Ringkasan.
/// Kolom sempit terpusat (max-width 640/880), persis prototipe baris
/// ~275-367. Lihat CLAUDE.md §3.4, DESIGN.md §4.1.
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
              onBack: () => _goTo(0),
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
              onBack: () => _goTo(1),
              onFinish: (addedNames) {
                setState(() => _addedHabitNames = addedNames);
                _goTo(3);
              },
            ),
            _SummaryStep(
              addedHabitNames: _addedHabitNames,
              onBack: () => _goTo(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.child, required this.bottomButton});

  final Widget child;
  final Widget bottomButton;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width >= 600 ? 880.0 : 640.0;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          children: [
            Expanded(child: child),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: bottomButton,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo({this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.check_rounded, color: Colors.white, size: size * 0.5),
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Column(
            children: [
              const _AppLogo(),
              const SizedBox(height: 14),
              Text('Habit Tracker', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Pilih kategori yang kamu minati, lalu kami sarankan kebiasaan yang cocok untukmu.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
                children: const [
                  TextSpan(text: 'Berdasarkan riset Lally dkk. (UCL), kebiasaan baru butuh sekitar '),
                  TextSpan(text: '66 hari', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(
                      text:
                          ' pengulangan agar terasa otomatis. Tracker ini soal konsistensi — bukan kesempurnaan.'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomButton: ElevatedButton(onPressed: onNext, child: const Text('Lanjut')),
    );
  }
}

class _CategoryPickStep extends ConsumerWidget {
  const _CategoryPickStep({
    required this.selected,
    required this.onToggle,
    required this.onBack,
    required this.onNext,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final VoidCallback onBack;
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
            Text('Pilih Kategori Minat', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Pilih minimal satu kategori.', style: theme.textTheme.bodySmall),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: categoryGridColumns(MediaQuery.sizeOf(context).width),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
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
      bottomButton: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Kembali'))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: selected.isEmpty ? null : onNext,
              child: const Text('Lanjut'),
            ),
          ),
        ],
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
    return Card(
      color: selected ? Color.lerp(Colors.white, color, 0.14) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: selected ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(child: CategoryShapeIcon(token: category.icon, size: 18)),
              ),
              const SizedBox(height: 10),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
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
    required this.onBack,
    required this.onFinish,
  });

  final Set<int> selectedCategoryIds;
  final Map<int, Set<HabitTemplate>> selectedTemplates;
  final void Function(int categoryId, HabitTemplate template) onToggleTemplate;
  final VoidCallback onBack;
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
                Text('Rekomendasi Habit', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Centang habit yang ingin kamu mulai. Bisa lewati sisanya.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                for (final category in selectedCategories) ...[
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.categoryColorFromHex(
                              category.colorHex, categories.indexOf(category)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(category.name, style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Builder(builder: (context) {
                    final match = allTemplates.where((t) => t.name == category.name);
                    final templates = match.isEmpty ? <HabitTemplate>[] : match.first.habits;
                    if (templates.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text('Belum ada rekomendasi untuk kategori ini.',
                            style: theme.textTheme.bodySmall),
                      );
                    }
                    final selectedSet = widget.selectedTemplates[category.id] ?? {};
                    return Column(
                      children: [
                        for (final t in templates)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => widget.onToggleTemplate(category.id, t),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      _SquareCheckbox(checked: selectedSet.contains(t)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(t.name, style: theme.textTheme.titleSmall),
                                            const SizedBox(height: 2),
                                            Text(t.goalLabel, style: theme.textTheme.bodySmall),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 6),
                ],
              ],
            );
          },
        ),
      ),
      bottomButton: Row(
        children: [
          Expanded(
            child: OutlinedButton(onPressed: _saving ? null : widget.onBack, child: const Text('Kembali')),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
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
    try {
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
            goalUnit: template.goalUnit,
            taskDays: const ['all'],
            timeRange: template.timeRange,
            reminderEnabled: false,
            startDate: today(),
          );
          final created = await repo.getById(id);
          if (created != null) {
            try {
              await notif.rescheduleForHabit(created);
            } catch (_) {
              // Notifikasi gagal dijadwalkan (mis. platform tidak
              // mendukung) — jangan gagalkan penyimpanan habit karena ini.
            }
          }
          addedNames.add(template.name);
        }
      }

      if (mounted) widget.onFinish(addedNames);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan habit: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SquareCheckbox extends StatelessWidget {
  const _SquareCheckbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: checked ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: checked ? theme.colorScheme.primary : theme.dividerColor,
          width: 2,
        ),
      ),
      child: checked ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
    );
  }
}

class _SummaryStep extends ConsumerWidget {
  const _SummaryStep({required this.addedHabitNames, required this.onBack});

  final List<String> addedHabitNames;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text('Ringkasan', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            addedHabitNames.isEmpty
                ? 'Belum ada habit ditambahkan. Kamu bisa menambah kapan saja lewat '
                    'tombol Tambah Habit di Beranda.'
                : '${addedHabitNames.length} habit berhasil ditambahkan',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          for (final name in addedHabitNames)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(name, style: theme.textTheme.titleSmall)),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomButton: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Kembali'))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(onboardingStatusProvider.notifier).complete();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const NavigationShell()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Mulai Tracking'),
            ),
          ),
        ],
      ),
    );
  }
}
