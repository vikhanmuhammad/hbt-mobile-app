import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/habit_template.dart';
import '../../../domain/models/onboarding_question.dart';
import '../../../domain/models/onboarding_response.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/template_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/habit_curve_chart.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/navigation_shell.dart';
import '../../widgets/pro_feature_teaser.dart';
import '../../widgets/responsive_grid.dart';
import '../add_habit/add_habit_flow_screen.dart';

/// New user onboarding (CLAUDE.md v3 §4.1): Personal Info Questionnaire ->
/// 3x Lifestyle Questionnaire -> Education -> Pick Goal Phrase ->
/// Habit Recommendations -> Summary. Narrow centered column (max-width 640/880).
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

  /// Templates that have actually been saved to the DB (template -> habit
  /// id) — used by `_RecommendationStep` to reconcile create/delete each
  /// time "Next" is pressed (idempotent, safe to call repeatedly even if
  /// the user navigates back and forth to this page) and by `_SummaryStep`
  /// to sync back when the user removes a habit from the Summary.
  final Map<HabitTemplate, int> _createdHabitIds = {};

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
              createdHabitIds: _createdHabitIds,
              onToggleTemplate: (categoryId, template) => setState(() {
                final set = _selectedTemplates.putIfAbsent(categoryId, () => {});
                if (set.contains(template)) {
                  set.remove(template);
                } else {
                  set.add(template);
                }
              }),
              onHabitCreated: (template, id) =>
                  setState(() => _createdHabitIds[template] = id),
              onHabitRemoved: (template) => setState(() {
                _createdHabitIds.remove(template);
                for (final set in _selectedTemplates.values) {
                  set.remove(template);
                }
              }),
              onBack: () => _goTo(5),
              onNext: () => _goTo(7),
            ),
            _SummaryStep(
              onBack: () => _goTo(6),
              onFinish: _completeOnboarding,
              onRemoveHabit: _removeHabit,
            ),
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

  /// Cancel a habit from the Summary page (§4.1 step 7) — a habit that
  /// originated from a Recommendations checkbox is also unchecked & released
  /// from `_createdHabitIds` to stay consistent if the user goes back to the
  /// Recommendations page. A habit added via the Add Habit shortcut (not
  /// tracked in `_createdHabitIds`) just needs to be deleted from the DB.
  Future<void> _removeHabit(int habitId) async {
    try {
      await ref.read(notificationServiceProvider).cancelForHabit(habitId);
    } catch (_) {
      // Notification cancellation failed (e.g. platform not supported) —
      // don't fail the habit deletion because of this.
    }
    await ref.read(habitRepositoryProvider).deleteHabit(habitId);

    HabitTemplate? matchedTemplate;
    _createdHabitIds.forEach((template, id) {
      if (id == habitId) matchedTemplate = template;
    });
    if (matchedTemplate == null) return;
    setState(() {
      _createdHabitIds.remove(matchedTemplate);
      for (final set in _selectedTemplates.values) {
        set.remove(matchedTemplate);
      }
    });
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

/// Step 1 (no progress bar): name (required) + age (optional). CLAUDE.md v3
/// §4.1 step 2.
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
          Text('What\'s your name?', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'So we can greet you more personally.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Name', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          const SizedBox(height: 16),
          Text('Age (optional)',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'e.g. 25'),
          ),
        ],
      ),
      bottomButton: AnimatedBuilder(
        animation: nameController,
        builder: (context, _) => ElevatedButton(
          onPressed: nameController.text.trim().isEmpty ? null : onNext,
          child: const Text('Next'),
        ),
      ),
    );
  }
}

/// Step 2-4: 1 single-select lifestyle question per page, incremental
/// progress bar + Skip button. CLAUDE.md v3 §4.1 step 3.
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
          TextButton(onPressed: onSkip, child: const Text('Skip')),
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
          Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: selectedAnswer == null ? null : onNext,
              child: const Text('Next'),
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

/// Step 5: habit-formation curve chart + motivational statement. CLAUDE.md
/// v3 §4.1 step 4.
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
          Text('Consistency Builds Habits', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'According to research by Lally et al. (UCL), a new habit takes about 66 days '
            'of repetition to become automatic — not just a fleeting intention.',
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
              'Building good habits increases happiness!',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.5),
            ),
          ),
        ],
      ),
      bottomButton: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton(onPressed: onNext, child: const Text('Next'))),
        ],
      ),
    );
  }
}

/// Step 6: pick goal phrase (multi-select) + create-new-goal card. CLAUDE.md
/// v3 §4.1 step 5.
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
            Text('Choose Habits That Match Your Goals', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Pick one or more goals you want to achieve.', style: theme.textTheme.bodySmall),
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
                            '+ Create New Goal',
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
          Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: selected.isEmpty ? null : onNext,
              child: const Text('Next'),
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
      // Blend from the theme's cardColor (not a hardcoded Colors.white) so
      // that in dark mode the selected tile doesn't turn light and swallow dark text.
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

/// Step 7: habit recommendations per selected goal phrase + a shortcut into
/// the full Add Habit flow (browse other raw/custom categories) without
/// leaving onboarding. CLAUDE.md v3 §4.1 step 6.
class _RecommendationStep extends ConsumerStatefulWidget {
  const _RecommendationStep({
    required this.selectedCategoryIds,
    required this.selectedTemplates,
    required this.createdHabitIds,
    required this.onToggleTemplate,
    required this.onHabitCreated,
    required this.onHabitRemoved,
    required this.onBack,
    required this.onNext,
  });

  final Set<int> selectedCategoryIds;
  final Map<int, Set<HabitTemplate>> selectedTemplates;
  final Map<HabitTemplate, int> createdHabitIds;
  final void Function(int categoryId, HabitTemplate template) onToggleTemplate;
  final void Function(HabitTemplate template, int habitId) onHabitCreated;
  final void Function(HabitTemplate template) onHabitRemoved;
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
                Text('Habit Recommendations', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Check the habits you want to start. You can skip the rest.',
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
                        child: Text('No recommendations for this category yet.',
                            style: theme.textTheme.bodySmall),
                      );
                    }
                    final selectedSet = widget.selectedTemplates[category.id] ?? {};
                    // Finance category (Save Money) is Pro-only — still
                    // shown here (not hidden) so the user knows the feature
                    // exists, but grayscaled + a PRO badge and tapping opens
                    // the paywall instead of toggling. The Add Habit flow
                    // from Home already has the same gate (see
                    // add_habit_flow_screen.dart).
                    final locked = isFinanceCategory(category) && !ref.watch(isProProvider);
                    return Column(
                      children: [
                        for (final t in templates)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Opacity(
                              opacity: locked ? 0.5 : 1,
                              child: Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: locked
                                      ? () => showProRequiredDialog(
                                            context,
                                            message: 'Finance habits (saving/spending with an '
                                                'amount) are Pro-only. Upgrade to Pro to '
                                                'start tracking them.',
                                          )
                                      : () => widget.onToggleTemplate(category.id, t),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        locked
                                            ? Icon(Icons.lock_rounded,
                                                size: 20, color: theme.textTheme.bodySmall?.color)
                                            : _SquareCheckbox(checked: selectedSet.contains(t)),
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
                                        if (locked) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: const Text(
                                              'PRO',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
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
                      '+ Explore Other Categories / Add Custom Habit',
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
            child: OutlinedButton(onPressed: _saving ? null : widget.onBack, child: const Text('Back')),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveSelections,
              child: Text(_saving ? 'Saving...' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  /// Reconcile, not always-create — so it's idempotent even when called
  /// repeatedly (user navigating back and forth between Recommendations <->
  /// Summary): templates that are checked but not yet in `createdHabitIds`
  /// get created, templates that were previously created but are now
  /// unchecked get deleted again. This is what prevents duplicate habits
  /// from a previous bug (checkbox appeared empty even though it was
  /// already saved, then the user re-checked it & continued again).
  Future<void> _saveSelections() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(habitRepositoryProvider);
      final notif = ref.read(notificationServiceProvider);

      final currentlySelected = <HabitTemplate>{
        for (final set in widget.selectedTemplates.values) ...set,
      };

      final toRemove = widget.createdHabitIds.keys
          .where((t) => !currentlySelected.contains(t))
          .toList();
      for (final template in toRemove) {
        final id = widget.createdHabitIds[template]!;
        try {
          await notif.cancelForHabit(id);
        } catch (_) {
          // Notification cancellation failed — don't fail the habit deletion.
        }
        await repo.deleteHabit(id);
        widget.onHabitRemoved(template);
      }

      for (final entry in widget.selectedTemplates.entries) {
        for (final template in entry.value) {
          if (widget.createdHabitIds.containsKey(template)) continue;
          final id = await repo.createHabit(
            categoryId: entry.key,
            name: template.name,
            icon: template.icon,
            goalPeriod: template.goalPeriod,
            goalValue: template.goalValue,
            goalUnit: template.goalUnit,
            goalDirection: template.goalDirection,
            taskDays: const ['all'],
            timeRange: template.timeRange,
            reminderEnabled: false,
            startDate: today(),
          );
          widget.onHabitCreated(template, id);
          final created = await repo.getById(id);
          if (created != null) {
            try {
              await notif.rescheduleForHabit(created);
            } catch (_) {
              // Notification scheduling failed (e.g. platform not
              // supported) — don't fail the habit save because of this.
            }
          }
        }
      }

      if (mounted) widget.onNext();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save habit: $e')));
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

/// Step 8: summary of habits successfully created during onboarding (read
/// live from the DB, not a local snapshot, so habits added via the Add
/// Habit shortcut show up too). CLAUDE.md v3 §4.1 step 7.
class _SummaryStep extends ConsumerWidget {
  const _SummaryStep({
    required this.onBack,
    required this.onFinish,
    required this.onRemoveHabit,
  });

  final VoidCallback onBack;
  final Future<void> Function() onFinish;
  final Future<void> Function(int habitId) onRemoveHabit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(allActiveHabitsProvider);

    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text('Summary', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          habitsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => Text('$e', style: theme.textTheme.bodySmall),
            data: (habits) => Text(
              habits.isEmpty
                  ? 'No habits added yet. You can add one anytime via the '
                      'Add Habit button on Home.'
                  : '${habits.length} habit(s) added successfully',
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          HabitIcon(icon: habit.icon, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(habit.name, style: theme.textTheme.titleSmall)),
                          IconButton(
                            tooltip: 'Cancel this habit',
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => onRemoveHabit(habit.id),
                          ),
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
          Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => onFinish(),
              child: const Text('Start Tracking'),
            ),
          ),
        ],
      ),
    );
  }
}
