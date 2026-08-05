import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/habit_template.dart';
import '../../../domain/models/onboarding_question.dart';
import '../../../domain/models/onboarding_response.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/template_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/habit_curve_chart.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/navigation_shell.dart';
import '../../widgets/responsive_grid.dart';
import '../add_habit/add_habit_flow_screen.dart';

/// Onboarding user baru (CLAUDE.md v3 §4.1): Kuesioner Data Diri -> 3x
/// Kuesioner Gaya Hidup -> Edukasi -> Pilih Goal Phrase -> Rekomendasi
/// Habit -> Ringkasan. Kolom sempit terpusat (max-width 640/880).
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final Map<String, String> _lifestyleAnswers = {};
  final Set<int> _selectedCategoryIds = {};
  final Map<int, Set<HabitTemplate>> _selectedTemplates = {};

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
    _nameController.dispose();
    _ageController.dispose();
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
            _PersonalInfoStep(
              nameController: _nameController,
              ageController: _ageController,
              onNext: () => _goTo(1),
            ),
            for (var i = 0; i < lifestyleQuestions.length; i++)
              _LifestyleQuestionStep(
                question: lifestyleQuestions[i],
                stepIndex: i + 1,
                totalSteps: lifestyleQuestions.length,
                selectedAnswer: _lifestyleAnswers[lifestyleQuestions[i].key],
                onSelect: (answer) =>
                    setState(() => _lifestyleAnswers[lifestyleQuestions[i].key] = answer),
                onBack: () => _goTo(i),
                onNext: () => _goTo(i + 2),
                onSkip: () => _goTo(i + 2),
              ),
            _EducationStep(onBack: () => _goTo(3), onNext: () => _goTo(5)),
            _GoalPhrasePickStep(
              selected: _selectedCategoryIds,
              onToggle: (id) => setState(() {
                if (_selectedCategoryIds.contains(id)) {
                  _selectedCategoryIds.remove(id);
                } else {
                  _selectedCategoryIds.add(id);
                }
              }),
              onCategoriesChanged: (ids) => setState(() => _selectedCategoryIds.addAll(ids)),
              onBack: () => _goTo(4),
              onNext: () => _goTo(6),
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
              onBack: () => _goTo(5),
              onNext: () => _goTo(7),
            ),
            _SummaryStep(onBack: () => _goTo(6), onFinish: _completeOnboarding),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final age = int.tryParse(_ageController.text.trim());
    final responses = [
      for (final q in lifestyleQuestions)
        if (_lifestyleAnswers[q.key] != null)
          OnboardingResponse(questionKey: q.key, answerValue: _lifestyleAnswers[q.key]!),
    ];

    await ref.read(profileRepositoryProvider).completeOnboarding(
          name: _nameController.text.trim(),
          age: age,
          responses: responses,
        );

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NavigationShell()),
        (route) => false,
      );
    }
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.child, required this.bottomButton, this.topBar});

  final Widget child;
  final Widget bottomButton;
  final Widget? topBar;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width >= 600 ? 880.0 : 640.0;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          children: [
            if (topBar != null) Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 0), child: topBar),
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

/// Step 1 (tanpa progress bar): nama (wajib) + usia (opsional). CLAUDE.md v3
/// §4.1 langkah 2.
class _PersonalInfoStep extends StatelessWidget {
  const _PersonalInfoStep({
    required this.nameController,
    required this.ageController,
    required this.onNext,
  });

  final TextEditingController nameController;
  final TextEditingController ageController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text('Siapa nama kamu?', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Biar kami bisa menyapamu dengan lebih personal.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Nama', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Nama kamu'),
          ),
          const SizedBox(height: 16),
          Text('Usia (opsional)',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'mis. 25'),
          ),
        ],
      ),
      bottomButton: AnimatedBuilder(
        animation: nameController,
        builder: (context, _) => ElevatedButton(
          onPressed: nameController.text.trim().isEmpty ? null : onNext,
          child: const Text('Lanjut'),
        ),
      ),
    );
  }
}

/// Step 2-4: 1 pertanyaan gaya hidup single-select per halaman, progress bar
/// bertahap + tombol Lewati. CLAUDE.md v3 §4.1 langkah 3.
class _LifestyleQuestionStep extends StatelessWidget {
  const _LifestyleQuestionStep({
    required this.question,
    required this.stepIndex,
    required this.totalSteps,
    required this.selectedAnswer,
    required this.onSelect,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  final OnboardingQuestion question;
  final int stepIndex;
  final int totalSteps;
  final String? selectedAnswer;
  final ValueChanged<String> onSelect;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StepScaffold(
      topBar: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: stepIndex / totalSteps,
                minHeight: 6,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(onPressed: onSkip, child: const Text('Lewati')),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        children: [
          Text(question.prompt, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 20),
          for (final option in question.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionTile(
                label: option,
                selected: selectedAnswer == option,
                onTap: () => onSelect(option),
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
              onPressed: selectedAnswer == null ? null : onNext,
              child: const Text('Lanjut'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: selected ? Color.lerp(theme.cardColor, theme.colorScheme.primary, 0.14) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: selected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? theme.colorScheme.primary : theme.dividerColor,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 5: grafik kurva pembentukan kebiasaan + statement motivasi. CLAUDE.md
/// v3 §4.1 langkah 4.
class _EducationStep extends StatelessWidget {
  const _EducationStep({required this.onBack, required this.onNext});

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text('Konsistensi Membentuk Kebiasaan', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Berdasarkan riset Lally dkk. (UCL), kebiasaan baru butuh sekitar 66 hari '
            'pengulangan sampai terasa otomatis — bukan sekadar niat sesaat.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: const HabitCurveChart(),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Membangun kebiasaan baik meningkatkan kebahagiaan!',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.5),
            ),
          ),
        ],
      ),
      bottomButton: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Kembali'))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton(onPressed: onNext, child: const Text('Lanjut'))),
        ],
      ),
    );
  }
}

/// Step 6: pilih goal phrase (multi-select) + kartu buat goal baru. CLAUDE.md
/// v3 §4.1 langkah 5.
class _GoalPhrasePickStep extends ConsumerWidget {
  const _GoalPhrasePickStep({
    required this.selected,
    required this.onToggle,
    required this.onCategoriesChanged,
    required this.onBack,
    required this.onNext,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final ValueChanged<Set<int>> onCategoriesChanged;
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
            Text('Pilih Habits yang Sesuai dengan Goals Kamu', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Pilih satu atau lebih goal yang ingin kamu capai.', style: theme.textTheme.bodySmall),
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
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return DashedBorder(
                    borderRadius: 20,
                    onTap: () async {
                      final beforeIds = categories.map((c) => c.id).toSet();
                      await openCreateCategoryFlow(context);
                      final afterList = ref.read(categoriesProvider).value ?? const <Category>[];
                      final newIds =
                          afterList.map((c) => c.id).toSet().difference(beforeIds);
                      if (newIds.isNotEmpty) onCategoriesChanged(newIds);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.light
                                  ? AppColors.lightSurfaceAlt
                                  : AppColors.darkSurfaceAlt,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add_rounded, color: theme.textTheme.bodySmall?.color),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '+ Buat Goal Baru',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }
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
    final theme = Theme.of(context);
    return Card(
      // Base blend dari cardColor tema (bukan Colors.white hardcoded) supaya
      // di dark mode tile terpilih tidak jadi terang dan menelan teks gelap.
      color: selected ? Color.lerp(theme.cardColor, color, 0.14) : null,
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
                child: Center(child: HabitIcon(icon: category.icon, size: 18, color: Colors.white)),
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

/// Step 7: rekomendasi habit per goal phrase terpilih + jalan pintas ke alur
/// Tambah Habit penuh (browse kategori mentah lain / custom) tanpa keluar
/// dari onboarding. CLAUDE.md v3 §4.1 langkah 6.
class _RecommendationStep extends ConsumerStatefulWidget {
  const _RecommendationStep({
    required this.selectedCategoryIds,
    required this.selectedTemplates,
    required this.onToggleTemplate,
    required this.onBack,
    required this.onNext,
  });

  final Set<int> selectedCategoryIds;
  final Map<int, Set<HabitTemplate>> selectedTemplates;
  final void Function(int categoryId, HabitTemplate template) onToggleTemplate;
  final VoidCallback onBack;
  final VoidCallback onNext;

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
                    final match = allTemplates.where((t) => t.defaultGoalPhrase == category.name);
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
                                      HabitIcon(icon: t.icon, size: 16, color: theme.textTheme.bodySmall?.color),
                                      const SizedBox(width: 12),
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
                DashedBorder(
                  borderRadius: 14,
                  onTap: _saving
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddHabitFlowScreen(),
                            ),
                          ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text(
                      '+ Jelajahi Kategori Lain / Tambah Habit Kustom',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ),
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

      for (final entry in widget.selectedTemplates.entries) {
        for (final template in entry.value) {
          final id = await repo.createHabit(
            categoryId: entry.key,
            name: template.name,
            icon: template.icon,
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
        }
      }

      if (mounted) widget.onNext();
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

/// Step 8: ringkasan habit yang berhasil dibuat selama onboarding (dibaca
/// live dari DB, bukan snapshot lokal, supaya habit yang ditambah lewat
/// jalan pintas Tambah Habit ikut tampil). CLAUDE.md v3 §4.1 langkah 7.
class _SummaryStep extends ConsumerWidget {
  const _SummaryStep({required this.onBack, required this.onFinish});

  final VoidCallback onBack;
  final Future<void> Function() onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(allActiveHabitsProvider);

    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text('Ringkasan', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          habitsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => Text('$e', style: theme.textTheme.bodySmall),
            data: (habits) => Text(
              habits.isEmpty
                  ? 'Belum ada habit ditambahkan. Kamu bisa menambah kapan saja lewat '
                      'tombol Tambah Habit di Beranda.'
                  : '${habits.length} habit berhasil ditambahkan',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          habitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => const SizedBox.shrink(),
            data: (habits) => Column(
              children: [
                for (final habit in habits)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          HabitIcon(icon: habit.icon, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(habit.name, style: theme.textTheme.titleSmall)),
                        ],
                      ),
                    ),
                  ),
              ],
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
              onPressed: () => onFinish(),
              child: const Text('Mulai Tracking'),
            ),
          ),
        ],
      ),
    );
  }
}
