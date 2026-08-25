import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_undraw/flutter_undraw.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/language.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/habit_template.dart';
import '../../../domain/models/onboarding_question.dart';
import '../../../domain/models/onboarding_response.dart';
import '../../../domain/onboarding_strings.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/finance_providers.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/template_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/daily_progress_ring.dart';
import '../../widgets/finance_preview_mock.dart';
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

  /// Total onboarding pages, matching the `PageView.children` list below
  /// 1:1 — drives the overall progress bar shown above every step. +1 for
  /// the language pick step (point 4) at index 0, +1 for the feature
  /// highlight carousel at index 1.
  int get _totalSteps => 1 + 1 + 1 + lifestyleQuestions.length + 1 + 1 + 1 + 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeSlideIn(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, _) {
                    final theme = Theme.of(context);
                    final page = _pageController.hasClients
                        ? (_pageController.page ?? 0)
                        : 0.0;
                    final progress = ((page + 1) / _totalSteps).clamp(0.0, 1.0);
                    return Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: theme.dividerColor,
                              valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${(progress * 100).round()}%',
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _LanguagePickStep(onNext: () => _goTo(1)),
                    _FeatureHighlightStep(onNext: () => _goTo(2)),
                    _PersonalInfoStep(
                      nameController: _nameController,
                      ageController: _ageController,
                      onNext: () => _goTo(3),
                    ),
                    for (var i = 0; i < lifestyleQuestions.length; i++)
                      _LifestyleQuestionStep(
                        question: lifestyleQuestions[i],
                        stepIndex: i + 1,
                        totalSteps: lifestyleQuestions.length,
                        selectedAnswer:
                            _lifestyleAnswers[lifestyleQuestions[i].key],
                        onSelect: (answer) => setState(
                          () => _lifestyleAnswers[lifestyleQuestions[i].key] =
                              answer,
                        ),
                        onBack: () => _goTo(i + 2),
                        onNext: () => _goTo(i + 4),
                        onSkip: () => _goTo(i + 4),
                      ),
                    _EducationStep(
                      onBack: () => _goTo(5),
                      onNext: () => _goTo(7),
                    ),
                    _GoalPhrasePickStep(
                      selected: _selectedCategoryIds,
                      onToggle: (id) => setState(() {
                        if (_selectedCategoryIds.contains(id)) {
                          _selectedCategoryIds.remove(id);
                        } else {
                          _selectedCategoryIds.add(id);
                        }
                      }),
                      onCategoriesChanged: (ids) =>
                          setState(() => _selectedCategoryIds.addAll(ids)),
                      onBack: () => _goTo(6),
                      onNext: () => _goTo(8),
                    ),
                    _RecommendationStep(
                      selectedCategoryIds: _selectedCategoryIds,
                      selectedTemplates: _selectedTemplates,
                      createdHabitIds: _createdHabitIds,
                      onToggleTemplate: (categoryId, template) => setState(() {
                        final set = _selectedTemplates.putIfAbsent(
                          categoryId,
                          () => {},
                        );
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
                      onBack: () => _goTo(7),
                      onNext: () => _goTo(9),
                    ),
                    _SummaryStep(
                      onBack: () => _goTo(8),
                      onFinish: _completeOnboarding,
                      onRemoveHabit: _removeHabit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final age = int.tryParse(_ageController.text.trim());
    final responses = [
      for (final q in lifestyleQuestions)
        if (_lifestyleAnswers[q.key] != null)
          OnboardingResponse(
            questionKey: q.key,
            answerValue: _lifestyleAnswers[q.key]!,
          ),
    ];

    await ref
        .read(profileRepositoryProvider)
        .completeOnboarding(
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
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);
    ref.invalidate(financeSummaryProvider);
    ref.invalidate(financeSummaryForPeriodProvider);

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
  const _StepScaffold({
    required this.child,
    required this.bottomButton,
    this.topBar,
    this.background,
  });

  final Widget child;
  final Widget bottomButton;
  final Widget? topBar;

  /// Undraw artwork painted behind the step's content — anchored to the
  /// bottom of the content column (where the form/question content leaves
  /// empty space) so it reads as page background texture rather than a
  /// discrete "added" illustration competing with the content on top of it.
  final UndrawIllustration? background;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width >= 600 ? 880.0 : 640.0;
    final theme = Theme.of(context);
    return Stack(
      children: [
        if (background != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: Opacity(
                          opacity: 0.18,
                          child: Undraw(
                            illustration: background!,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                if (topBar != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: topBar,
                  ),
                Expanded(child: child),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: bottomButton,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Step 0 (no progress bar yet): pick the app-wide display language — sets
/// both `introLanguageProvider` (onboarding copy) and the persistent
/// `appLanguageProvider` (everywhere else, editable later in Settings).
class _LanguagePickStep extends ConsumerWidget {
  const _LanguagePickStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(introLanguageProvider);
    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        children: [
          Text(
            'Choose your language / Pilih bahasa',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'This sets the language for the whole app — you can change it later in '
            'Settings.\n\nIni mengatur bahasa untuk seluruh aplikasi — bisa diubah lagi nanti '
            'lewat Settings.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          _OptionTile(
            label: 'English',
            selected: selected == OnboardingLang.en,
            onTap: () {
              ref.read(introLanguageProvider.notifier).state = OnboardingLang.en;
              ref.read(appLanguageProvider.notifier).setLanguage(AppLang.en);
            },
          ),
          const SizedBox(height: 10),
          _OptionTile(
            label: 'Bahasa Indonesia',
            selected: selected == OnboardingLang.id,
            onTap: () {
              ref.read(introLanguageProvider.notifier).state = OnboardingLang.id;
              ref.read(appLanguageProvider.notifier).setLanguage(AppLang.id);
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Undraw(
              illustration: UndrawIllustration.chatting,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      bottomButton: ElevatedButton(
        onPressed: onNext,
        child: const Text('Next / Lanjut'),
      ),
    );
  }
}

/// Step 1: feature highlight carousel — a swipeable mini-carousel of 4
/// slides pairing a headline with a small mock preview of a real app screen
/// (quick logging, calendar glance, Community, streaks). Pure marketing, no
/// data collected — like `_LanguagePickStep` there's no "Back"; "Skip" jumps
/// straight past all 4 slides to Personal Info. Copy follows the language
/// chosen in step 0 via `OnboardingStrings`.
class _FeatureHighlightStep extends ConsumerStatefulWidget {
  const _FeatureHighlightStep({required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<_FeatureHighlightStep> createState() =>
      _FeatureHighlightStepState();
}

class _FeatureHighlightStepState extends ConsumerState<_FeatureHighlightStep> {
  final _introController = PageController();
  int _introIndex = 0;

  static const _mocks = [
    _HabitDetailScreenMock(),
    _CalendarScreenMock(),
    _CommunityScreenMock(),
    _HomeListScreenMock(),
  ];

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = OnboardingStrings(ref.watch(introLanguageProvider));
    final titles = lang.introTitles;
    final subtitles = lang.introSubtitles;
    final isLast = _introIndex == _mocks.length - 1;

    return _StepScaffold(
      topBar: Align(
        alignment: Alignment.centerRight,
        child: TextButton(onPressed: widget.onNext, child: Text(lang.skip)),
      ),
      child: PageView.builder(
        controller: _introController,
        itemCount: _mocks.length,
        onPageChanged: (i) => setState(() => _introIndex = i),
        itemBuilder: (context, i) => _FeatureSlide(
          title: titles[i],
          subtitle: subtitles[i],
          mock: _mocks[i],
        ),
      ),
      bottomButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _mocks.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _introIndex ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _introIndex
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (isLast) {
                widget.onNext();
              } else {
                _introController.animateToPage(
                  _introIndex + 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            child: Text(isLast ? lang.getStarted : lang.next),
          ),
        ],
      ),
    );
  }
}

/// One feature-highlight slide: headline + subtitle + mock preview, each
/// fading/sliding in with a slight stagger (mirrors the reference video's
/// entrance animation) — replays every time the slide scrolls into view.
class _FeatureSlide extends StatelessWidget {
  const _FeatureSlide({
    required this.title,
    required this.subtitle,
    required this.mock,
  });

  final String title;
  final String subtitle;
  final Widget mock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      children: [
        FadeSlideIn(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 32),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          duration: const Duration(milliseconds: 450),
          child: mock,
        ),
      ],
    );
  }
}

/// Wraps a mock screen so onboarding's feature highlights read as
/// screenshots of the real app rather than isolated snippets — border +
/// shadow + a small top notch, no OS chrome.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  /// Fixed (not aspect-ratio-derived) so every slide's content — including
  /// the tallest one (slide 1's quick-add chips) — reliably fits without
  /// silently clipping in release mode, where overflow shows no debug
  /// warning stripes.
  static const _height = 460.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: 300,
        height: _height,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: theme.dividerColor, width: 6),
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slide 1 mock: a screenshot-style recreation of the real quick-progress
/// bottom sheet (`quick_progress_sheet.dart`, opened by tapping a
/// measured habit on Beranda) — title + "Target: X" subtitle, a −/+
/// stepper around the current value, then "Mark Achieved"/"Save" buttons,
/// shown sliding up over a dimmed glimpse of the habit row it was opened
/// from. Plays a one-shot animation: the number rises as if the + button
/// had just been tapped a couple of times.
class _HabitDetailScreenMock extends StatefulWidget {
  const _HabitDetailScreenMock();

  @override
  State<_HabitDetailScreenMock> createState() => _HabitDetailScreenMockState();
}

class _HabitDetailScreenMockState extends State<_HabitDetailScreenMock> {
  static const _goal = 2000;
  int _value = 1200;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() => _value = 1400);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PhoneFrame(
      child: Column(
        children: [
          // Dimmed glimpse of the Beranda row this sheet was opened from —
          // matches how the real sheet appears as an overlay, not its own
          // full screen.
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
            child: Opacity(
              opacity: 0.35,
              child: _MockHabitRow(
                icon: 'glass-water',
                name: 'Drink Water',
                progressLabel: 'Progress $_value ml • Goal $_goal ml',
                progress: (_value / _goal).clamp(0.0, 1.0),
                color: Colors.blue,
                done: _value >= _goal,
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drink Water',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('Target: $_goal ml', style: theme.textTheme.labelSmall),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _MockStepButton(icon: Icons.remove_rounded),
                    const SizedBox(width: 18),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _value.toDouble()),
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => Text(
                        '${value.round()}',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 18),
                    const _MockStepButton(icon: Icons.add_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _MockPillButton(label: 'Mark Achieved', filled: false)),
                    const SizedBox(width: 10),
                    Expanded(child: _MockPillButton(label: 'Save', filled: true)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small circular −/+ button matching `_StepButton` in the real
/// `quick_progress_sheet.dart`.
class _MockStepButton extends StatelessWidget {
  const _MockStepButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Icon(icon, size: 16),
    );
  }
}

/// Matches the real sheet's "Mark Achieved" (outlined) / "Save" (filled)
/// button pair.
class _MockPillButton extends StatelessWidget {
  const _MockPillButton({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: filled ? null : Border.all(color: theme.dividerColor),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}

/// Reused by slide 4's home mock: a `HabitCard`-style row showing the app's
/// 2 progress states (§6.2) — partial fill for in-progress, solid +
/// checkmark for done.
class _MockHabitRow extends StatelessWidget {
  const _MockHabitRow({
    required this.icon,
    required this.name,
    required this.progressLabel,
    required this.progress,
    required this.color,
    required this.done,
  });

  final String icon;
  final String name;
  final String progressLabel;
  final double progress;
  final Color color;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: theme.cardColor),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  color: color.withValues(alpha: done ? 0.28 : 0.16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HabitIcon(
                        icon: icon,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(name, style: theme.textTheme.titleSmall),
                        Text(progressLabel, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(
                    done ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: done ? color : theme.dividerColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide 2 mock: a screenshot-style recreation of the Dashboard's monthly
/// calendar (`monthly_calendar_grid.dart`) — a 7-column grid where each day
/// that has data gets its own small `DailyProgressRing`, matching the real
/// widget exactly rather than a single big ring. One-shot: one more day's
/// ring fills in, as if progress had just synced in.
class _CalendarScreenMock extends StatefulWidget {
  const _CalendarScreenMock();

  @override
  State<_CalendarScreenMock> createState() => _CalendarScreenMockState();
}

class _CalendarScreenMockState extends State<_CalendarScreenMock> {
  static const _weekdayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  // 14 days starting the 17th — null = no data yet (plain number, like the
  // real grid), a value = that day's success ratio.
  final List<double?> _ratios = [
    1, 1, 0.8, 0.5, null, null, null,
    0.9, 0.6, null, null, null, null, null,
  ];
  int _highlightIndex = 3;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _ratios[4] = 0.75;
        _highlightIndex = 4;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PhoneFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'August 2026',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final h in _weekdayHeaders)
                  Expanded(
                    child: Center(
                      child: Text(
                        h,
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 4,
              ),
              itemCount: _ratios.length,
              itemBuilder: (context, i) {
                final ratio = _ratios[i];
                final selected = i == _highlightIndex;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                        : null,
                  ),
                  child: ratio != null
                      ? TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: ratio),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => DailyProgressRing(
                            done: (value * 100).round(),
                            total: 100,
                            size: 28,
                            strokeWidth: 2.5,
                            centerLabel: '${17 + i}',
                            centerLabelStyle: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w800, fontSize: 10),
                          ),
                        )
                      : Text(
                          '${17 + i}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide 3 mock: a screenshot-style recreation of a Community group's
/// leaderboard tab (`_LeaderboardTile` in `group_detail_screen.dart`) — a
/// rank-colored circle avatar, name + secondary stat line, and a big bold
/// primary number + unit on the right. The real tile has no progress bar;
/// this mock matches that instead of inventing one. One-shot: "You"'s value
/// ticks up once, as if progress had just synced in.
class _CommunityScreenMock extends StatefulWidget {
  const _CommunityScreenMock();

  @override
  State<_CommunityScreenMock> createState() => _CommunityScreenMockState();
}

class _CommunityScreenMockState extends State<_CommunityScreenMock> {
  int _youValue = 8;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _youValue = 12);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = [
      (rank: 1, name: 'Alex', value: 14, streak: 9, isMe: false),
      (rank: 2, name: 'You', value: _youValue, streak: 5, isMe: true),
      (rank: 3, name: 'Sam', value: 7, streak: 3, isMe: false),
    ];
    return _PhoneFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HabitIcon(
                  icon: 'people-group',
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Study Group',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Reading — Weekly Leaderboard',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            for (final m in members)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MockLeaderboardTile(
                  rank: m.rank,
                  name: m.name,
                  isMe: m.isMe,
                  value: m.value,
                  streak: m.streak,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MockLeaderboardTile extends StatelessWidget {
  const _MockLeaderboardTile({
    required this.rank,
    required this.name,
    required this.isMe,
    required this.value,
    required this.streak,
  });

  final int rank;
  final String name;
  final bool isMe;
  final int value;
  final int streak;

  // Gold / silver / bronze — matches `_rankColors` in group_detail_screen.dart.
  static const _rankColors = {1: Color(0xFFD4AF37), 2: Color(0xFFA8A9AD), 3: Color(0xFFCD7F32)};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rankColor = _rankColors[rank];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.08) : theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: theme.colorScheme.primary, width: 1.5) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: rankColor ?? theme.colorScheme.surfaceContainerHighest,
            foregroundColor: rankColor != null ? Colors.white : null,
            child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMe ? '$name (You)' : name,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text('$streak day streak', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, v, _) => Text(
                  '${v.round()}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                ),
              ),
              Text('books', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Slide 4 mock: a screenshot-style recreation of the Beranda flat-list
/// top bar (month pill + "Today" pill) and habit rows, reusing
/// `_MockHabitRow`. The app has no streak feature — each row's label is
/// "Progress X • Goal Y", matching the real `HabitProgressCard` (#25), not
/// the streak-count framing this mock used to show. One-shot: the top row
/// flips from in-progress to done, as if it had just been checked off.
class _HomeListScreenMock extends StatefulWidget {
  const _HomeListScreenMock();

  @override
  State<_HomeListScreenMock> createState() => _HomeListScreenMockState();
}

class _HomeListScreenMockState extends State<_HomeListScreenMock> {
  bool _yogaDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() => _yogaDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PhoneFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'August 2026',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Today',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _MockHabitRow(
              icon: 'person-running',
              name: 'Yoga',
              progressLabel: _yogaDone ? 'Progress 1x • Goal 1x' : 'Progress 0x • Goal 1x',
              progress: _yogaDone ? 1 : 0,
              color: theme.colorScheme.primary,
              done: _yogaDone,
            ),
            const SizedBox(height: 12),
            const _MockHabitRow(
              icon: 'glass-water',
              name: 'Drink Water',
              progressLabel: 'Progress 2000 ml • Goal 2000 ml',
              progress: 1,
              color: Colors.blue,
              done: true,
            ),
            const SizedBox(height: 12),
            const _MockHabitRow(
              icon: 'spa',
              name: 'Meditation',
              progressLabel: 'Progress 0 min • Goal 10 min',
              progress: 0,
              color: Colors.deepPurple,
              done: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 2 (no progress bar): name (required) + age (optional) + gender.
/// CLAUDE.md v3 §4.1 step 2. The gender dropdown replaces an earlier
/// "Choose your goals" dropdown that was effectively dead — the real goal
/// phrase selection happens later in `_GoalPhrasePickStep` (point 1).
class _PersonalInfoStep extends ConsumerStatefulWidget {
  const _PersonalInfoStep({
    required this.nameController,
    required this.ageController,
    required this.onNext,
  });

  final TextEditingController nameController;
  final TextEditingController ageController;
  final VoidCallback onNext;

  @override
  ConsumerState<_PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<_PersonalInfoStep> {
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = Gender.fromValue(
      ref.read(settingsRepositoryProvider).gender,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = OnboardingStrings(ref.watch(introLanguageProvider));
    final indonesian = ref.watch(introLanguageProvider) == OnboardingLang.id;
    return _StepScaffold(
      background: UndrawIllustration.sharedGoals,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text(lang.whatsYourName, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(lang.soWeCanGreet, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text(
            lang.nameLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: lang.nameHint),
          ),
          const SizedBox(height: 16),
          Text(
            lang.ageLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: lang.ageHint),
          ),
          const SizedBox(height: 16),
          Text(
            lang.genderLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          // `DropdownMenu` (not `DropdownButtonFormField`) so the options
          // list opens anchored below the field, like a normal dropdown —
          // `DropdownButtonFormField`'s default menu instead opens centered
          // over the field with the selected entry, which reads as if the
          // first item shown were already the current value (#26).
          DropdownMenu<Gender>(
            initialSelection: _selectedGender,
            hintText: lang.genderHint,
            expandedInsets: EdgeInsets.zero,
            onSelected: (value) {
              if (value == null) return;
              setState(() => _selectedGender = value);
              ref.read(settingsRepositoryProvider).setGender(value.name);
            },
            dropdownMenuEntries: [
              for (final g in Gender.values)
                DropdownMenuEntry(value: g, label: g.label(indonesian)),
            ],
          ),
        ],
      ),
      bottomButton: AnimatedBuilder(
        animation: widget.nameController,
        builder: (context, _) => ElevatedButton(
          onPressed: widget.nameController.text.trim().isEmpty
              ? null
              : widget.onNext,
          child: Text(lang.next),
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

  /// One fitting undraw.co illustration per question (point 5) — cycled by
  /// `stepIndex` rather than hand-picked per question key, so it stays in
  /// sync automatically if the question list is reordered.
  static const _illustrations = [
    UndrawIllustration.questions,
    UndrawIllustration.timeManagement,
    UndrawIllustration.feelingProud,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = Theme.of(context);
        final lang = OnboardingStrings(ref.watch(introLanguageProvider));
        final indonesian =
            ref.watch(introLanguageProvider) == OnboardingLang.id;
        final options = question.optionsFor(indonesian);
        return _StepScaffold(
          background: _illustrations[(stepIndex - 1) % _illustrations.length],
          topBar: Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onSkip, child: Text(lang.skip)),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            children: [
              Text(
                question.promptFor(indonesian),
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionTile(
                    label: options[i],
                    // Stored/compared as the canonical English value
                    // regardless of the displayed language, so answers stay
                    // consistent across language toggles/db records.
                    selected: selectedAnswer == question.options[i],
                    onTap: () => onSelect(question.options[i]),
                  ),
                ),
            ],
          ),
          bottomButton: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: Text(lang.back),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null ? null : onNext,
                  child: Text(lang.next),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: selected
          ? Color.lerp(theme.cardColor, theme.colorScheme.primary, 0.14)
          : null,
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
                  color: selected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 5: habit-formation curve chart + motivational statement. CLAUDE.md
/// v3 §4.1 step 4.
class _HabitTip {
  const _HabitTip(this.icon, this.text);
  final IconData icon;
  final String text;
}

const _habitTips = [
  _HabitTip(
    Icons.replay_rounded,
    'Missing a day doesn\'t reset your progress — what matters is getting back on track quickly.',
  ),
  _HabitTip(
    Icons.flag_rounded,
    'Start small. A tiny, doable habit beats an ambitious one you abandon after 3 days.',
  ),
  _HabitTip(
    Icons.link_rounded,
    'Stack a new habit onto an existing routine (e.g. after brushing your teeth) to make it stick faster.',
  ),
  _HabitTip(
    Icons.insights_rounded,
    'Tracking your streak visually makes you far more likely to keep it going.',
  ),
];

class _EducationStep extends ConsumerWidget {
  const _EducationStep({required this.onBack, required this.onNext});

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lang = OnboardingStrings(ref.watch(introLanguageProvider));
    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text(
            lang.consistencyBuildsHabits,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(lang.educationBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: const HabitCurveChart(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            lang.habitsIncreaseHappiness,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Text(lang.goodToKnow, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (var i = 0; i < _habitTips.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _habitTips[i].icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      i < lang.habitTips.length
                          ? lang.habitTips[i]
                          : _habitTips[i].text,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomButton: Row(
        children: [
          Expanded(
            child: OutlinedButton(onPressed: onBack, child: Text(lang.back)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(onPressed: onNext, child: Text(lang.next)),
          ),
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
    final lang = OnboardingStrings(ref.watch(introLanguageProvider));

    return _StepScaffold(
      child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
        data: (categories) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          children: [
            Text(lang.chooseHabitsTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(lang.pickOneOrMoreGoals, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: categoryGridColumns(
                  MediaQuery.sizeOf(context).width,
                ),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.76,
              ),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return DashedBorder(
                    borderRadius: 20,
                    onTap: () async {
                      final beforeIds = categories.map((c) => c.id).toSet();
                      await openCreateCategoryFlow(context);
                      final afterList =
                          ref.read(categoriesProvider).value ??
                          const <Category>[];
                      final newIds = afterList
                          .map((c) => c.id)
                          .toSet()
                          .difference(beforeIds);
                      if (newIds.isNotEmpty) onCategoriesChanged(newIds);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
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
                            child: Icon(
                              Icons.add_rounded,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            lang.createNewGoal,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
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
          Expanded(
            child: OutlinedButton(onPressed: onBack, child: Text(lang.back)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: selected.isEmpty ? null : onNext,
              child: Text(lang.next),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPickTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appLang = ref.watch(appLanguageProvider);
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: HabitIcon(
                    icon: category.icon,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.displayName(appLang),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                goalPhraseDescriptionFor(category),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
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
  ConsumerState<_RecommendationStep> createState() =>
      _RecommendationStepState();
}

/// Same cap as `add_habit_flow_screen.dart`'s `_freeActiveHabitLimit` — kept
/// as a separate constant (not shared/imported) since this file has no
/// dependency on that screen file otherwise; keep both in sync if the free
/// tier limit ever changes.
const _onboardingFreeHabitLimit = 5;

class _RecommendationStepState extends ConsumerState<_RecommendationStep> {
  bool _saving = false;

  /// Guards the checkbox toggle itself (not just the final Save) so a free
  /// user can't check more than 5 habits total during onboarding — mirrors
  /// the Add Habit flow's `_blockedByFreeHabitLimit`, which only covers
  /// habits added after onboarding via that screen.
  void _handleToggle(
    int categoryId,
    HabitTemplate template,
    bool isCurrentlySelected,
  ) {
    if (isCurrentlySelected || ref.read(isProProvider)) {
      widget.onToggleTemplate(categoryId, template);
      return;
    }

    final activeHabits = ref.read(allActiveHabitsProvider).value ?? const [];
    final nonOnboardingActiveCount =
        (activeHabits.length - widget.createdHabitIds.length).clamp(
          0,
          activeHabits.length,
        );
    final currentlySelectedCount = widget.selectedTemplates.values.fold<int>(
      0,
      (sum, set) => sum + set.length,
    );
    final wouldBeSelectedCount = currentlySelectedCount + 1;

    if (nonOnboardingActiveCount + wouldBeSelectedCount >
        _onboardingFreeHabitLimit) {
      showProRequiredDialog(
        context,
        message:
            'You\'ve reached the $_onboardingFreeHabitLimit active habit limit for '
            'Free users. Upgrade to Pro to add unlimited habits.',
      );
      return;
    }
    widget.onToggleTemplate(categoryId, template);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final templatesAsync = ref.watch(habitTemplatesProvider);
    final lang = OnboardingStrings(ref.watch(introLanguageProvider));
    final appLang = ref.watch(appLanguageProvider);

    return _StepScaffold(
      child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
        data: (categories) => templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('$e')),
          data: (allTemplates) {
            final selectedCategories = categories
                .where((c) => widget.selectedCategoryIds.contains(c.id))
                .toList();

            final isPro = ref.watch(isProProvider);

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lang.habitRecommendations,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    if (!isPro)
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProFeatureTeaser(
                              icon: Icons.workspace_premium_rounded,
                              title: 'Daily Habits Pro',
                              description:
                                  'Unlock unlimited habits, the Finance tracker, and '
                                  'Community leaderboards.',
                              benefits: const [
                                'No limit on active habits (Free is capped at 5)',
                                'Track spending & savings with the Finance summary',
                                'Join or create Community groups & leaderboards',
                              ],
                              showBackButton: true,
                            ),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        icon: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 16,
                        ),
                        label: Text(lang.upgradeToPro),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(lang.checkHabitsYouWant, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 20),
                for (final category in selectedCategories) ...[
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.categoryColorFromHex(
                            category.colorHex,
                            categories.indexOf(category),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: HabitIcon(
                            icon: isFinanceCategory(category)
                                ? 'credit-card'
                                : category.icon,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category.displayName(appLang),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Builder(
                    builder: (context) {
                      // Finance (Save Money) for non-Pro users: instead of
                      // showing the (locked, grayed) template list, show a
                      // blurred preview of the real Finance screen + an
                      // upgrade button — gives a clearer sense of what's
                      // behind the paywall than a grayscale checklist.
                      if (isFinanceCategory(category) && !isPro) {
                        return _FinanceLockedPreview(
                          onUpgrade: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProFeatureTeaser(
                                icon: Icons.account_balance_wallet_rounded,
                                title: 'Finance — Pro Feature',
                                description:
                                    'Track spending, savings, and saving habits in one '
                                    'monthly summary. Upgrade to Pro to unlock this feature.',
                                benefits: const [
                                  'Monthly spending & savings totals across all your finance habits',
                                  'Daily spending trend chart so you can spot patterns early',
                                  'Per-habit breakdown to see exactly where your money goes',
                                ],
                                previewBuilder: (context) =>
                                    const FinancePreviewMock(),
                                showBackButton: true,
                              ),
                            ),
                          ),
                        );
                      }

                      final match = allTemplates.where(
                        (t) => t.key == category.templateKey,
                      );
                      final templates = match.isEmpty
                          ? <HabitTemplate>[]
                          : match.first.habits;
                      if (templates.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'No recommendations for this category yet.',
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      }
                      final selectedSet =
                          widget.selectedTemplates[category.id] ?? {};
                      // Finance category (Save Money) is Pro-only — still
                      // shown here (not hidden) so the user knows the feature
                      // exists, but grayscaled + a PRO badge and tapping opens
                      // the paywall instead of toggling. The Add Habit flow
                      // from Home already has the same gate (see
                      // add_habit_flow_screen.dart).
                      final locked =
                          isFinanceCategory(category) &&
                          !ref.watch(isProProvider);
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
                                            message:
                                                'Finance habits (saving/spending with an '
                                                'amount) are Pro-only. Upgrade to Pro to '
                                                'start tracking them.',
                                          )
                                        : () => _handleToggle(
                                            category.id,
                                            t,
                                            selectedSet.contains(t),
                                          ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          locked
                                              ? Icon(
                                                  Icons.lock_rounded,
                                                  size: 20,
                                                  color: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                                )
                                              : _SquareCheckbox(
                                                  checked: selectedSet.contains(
                                                    t,
                                                  ),
                                                ),
                                          const SizedBox(width: 14),
                                          HabitIcon(
                                            icon: t.icon,
                                            size: 20,
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  t.displayName(appLang),
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  t.goalLabel(appLang),
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (locked) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(999),
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
                    },
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Text(
                      lang.exploreOtherCategories,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
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
            child: OutlinedButton(
              onPressed: _saving ? null : widget.onBack,
              child: Text(lang.back),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveSelections,
              child: Text(_saving ? lang.saving : lang.next),
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
            nameId: template.nameId,
            isCustom: false,
            templateKey: template.key,
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
              await notif.rescheduleForHabit(created, lang: ref.read(appLanguageProvider));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.addHabitFailedToSave('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Blurred preview of the real Finance screen + an "Upgrade to Pro" button —
/// shown instead of the Finance template checklist when the user picked
/// "Save Money" during onboarding but isn't Pro yet (point 13).
class _FinanceLockedPreview extends StatelessWidget {
  const _FinanceLockedPreview({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          const SizedBox(
            height: 260,
            child: IgnorePointer(child: FinancePreviewMock()),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.onboardingFinanceProFeature,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onUpgrade,
                    child: Text(AppLocalizations.of(context)!.proFeatureUpgradeButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      child: checked
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
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
    final lang = OnboardingStrings(ref.watch(introLanguageProvider));
    final appLang = ref.watch(appLanguageProvider);

    return _StepScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        children: [
          Text(lang.summary, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          habitsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => Text('$e', style: theme.textTheme.bodySmall),
            data: (habits) => Text(
              habits.isEmpty
                  ? lang.noHabitsAddedYet
                  : lang.habitsAddedSuccessfully(habits.length),
              style: theme.textTheme.bodyLarge,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          HabitIcon(
                            icon: habit.icon,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              habit.displayName(appLang),
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            tooltip: AppLocalizations.of(context)!.onboardingCancelHabit,
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
          Expanded(
            child: OutlinedButton(onPressed: onBack, child: Text(lang.back)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => onFinish(),
              child: Text(lang.startTracking),
            ),
          ),
        ],
      ),
    );
  }
}
