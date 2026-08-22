import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/habit.dart';
import '../../../domain/models/habit_template.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/finance_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../../providers/template_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/icon_picker_sheet.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/pro_feature_teaser.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/toggle_switch.dart';

/// Active habit limit for Free users — beyond this requires a Pro upgrade.
const _freeActiveHabitLimit = 5;

/// Open the Add Habit flow from the Home FAB — starts at step 1 (pick goal
/// phrase). The Home flat-list automatically shows the new habit once
/// saved, so it's enough to just pop back when done. CLAUDE.md v3 §3.4.
Future<void> openAddHabitFlow(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AddHabitFlowScreen()),
  );
}

/// Open the flow directly at the edit form for an existing habit (from Home
/// Edit Mode or Settings) — after finishing, just pop back to the caller's
/// screen. Pass [lockGoalFields] true when the habit is linked to a
/// Community Group Habit (see `AddHabitFlowScreen.lockGoalFields`).
Future<void> openEditHabitFlow(
  BuildContext context,
  Habit habit, {
  bool lockGoalFields = false,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AddHabitFlowScreen(editingHabit: habit, lockGoalFields: lockGoalFields),
    ),
  );
}

/// Open the flow directly at the "Create New Category" step (from
/// Settings/onboarding), then return to the caller once the category is
/// created (does not continue to recommendations).
Future<void> openCreateCategoryFlow(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AddHabitFlowScreen(startAtNewCategory: true)),
  );
}

/// The Add Habit flow as a single full-screen with 4 internal steps,
/// matching the prototype exactly (`afStepIs1..4` in docs/Habit Tracker.html) —
/// not a combination of a push-route + separate bottom sheet.
class AddHabitFlowScreen extends ConsumerStatefulWidget {
  const AddHabitFlowScreen({
    super.key,
    this.initialCategoryId,
    this.editingHabit,
    this.startAtNewCategory = false,
    this.lockGoalFields = false,
  });

  final int? initialCategoryId;
  final Habit? editingHabit;
  final bool startAtNewCategory;

  /// When editing a habit that's linked to a Community Group Habit, locks
  /// every field except Reminder — name, icon, goal phrase/period/value/
  /// unit/direction, task days, time range, and start/end date all stay
  /// exactly what the Group Habit was published/adopted with, so tracking
  /// against the shared leaderboard target never silently drifts out of
  /// sync from one device's local edit. Unlink from Community first to
  /// change any of those.
  final bool lockGoalFields;

  @override
  ConsumerState<AddHabitFlowScreen> createState() => _AddHabitFlowScreenState();
}

class _AddHabitFlowScreenState extends ConsumerState<AddHabitFlowScreen> {
  late List<int> _stepStack;
  int? _categoryId;
  bool _saving = false;

  // Step 3 form state.
  final _nameController = TextEditingController();
  final _goalUnitController = TextEditingController(text: 'x');
  final _goalValueController = TextEditingController(text: '1');
  String _habitIcon = defaultHabitIconKey;
  String _unitDropdownValue = 'x';
  GoalPeriod _goalPeriod = GoalPeriod.daily;
  int _goalValue = 1;
  GoalDirection _goalDirection = GoalDirection.atLeast;
  Set<String> _taskDays = {allDaysKey};
  TimeRange _timeRange = TimeRange.anytime;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  DateTime _startDate = today();
  DateTime? _endDate;

  // Step 4 form state.
  final _newCatNameController = TextEditingController();
  int _newCatColorIndex = 0;
  String _newCatIcon = 'list-check';

  bool get _isEditing => widget.editingHabit != null;
  int get _step => _stepStack.last;

  @override
  void initState() {
    super.initState();
    if (widget.editingHabit != null) {
      _categoryId = widget.editingHabit!.categoryId;
      _loadFormFromHabit(widget.editingHabit!);
      _stepStack = [3];
    } else if (widget.startAtNewCategory) {
      _stepStack = [4];
    } else if (widget.initialCategoryId != null) {
      _categoryId = widget.initialCategoryId;
      _stepStack = [2];
    } else {
      _stepStack = [1];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalUnitController.dispose();
    _goalValueController.dispose();
    _newCatNameController.dispose();
    super.dispose();
  }

  /// Progress unit presets (CLAUDE.md v3 §8) — 'x' means no unit
  /// (simple on/off habit). Anything else is treated as a custom unit.
  static const List<String> unitPresetValues = [
    'x',
    'minute',
    'hour',
    'step',
    'glass',
    'page',
    'time',
    'kilometer',
    'rupiah',
  ];

  static const Map<String, String> unitPresetLabels = {
    'x': 'No unit',
    'minute': 'Minute',
    'hour': 'Hour',
    'step': 'Step',
    'glass': 'Glass',
    'page': 'Page',
    'time': 'Time',
    'kilometer': 'Kilometer',
    'rupiah': 'Rupiah',
    'custom': 'Custom...',
  };

  void _applyUnit(String goalUnit) {
    _goalUnitController.text = goalUnit;
    _unitDropdownValue = unitPresetValues.contains(goalUnit) ? goalUnit : 'custom';
  }

  bool get _isRupiahUnit => _goalUnitController.text.trim() == 'rupiah';

  /// Updates [_goalValue] and keeps the text field in sync — used by every
  /// programmatic change (steppers, loading a habit/template, unit presets)
  /// so typing directly into the field (which sets `_goalValue` without
  /// touching the controller) doesn't get fought over/reset the cursor.
  void _setGoalValue(int value) {
    _goalValue = value.clamp(0, 1 << 30);
    final text = '$_goalValue';
    if (_goalValueController.text != text) {
      _goalValueController.text = text;
    }
  }

  /// Larger step for the rupiah unit so users don't have to press +/-
  /// hundreds of times to reach a reasonable amount.
  int get _goalValueStep {
    if (!_isRupiahUnit) return 1;
    if (_goalValue >= 100000) return 5000;
    if (_goalValue >= 10000) return 1000;
    return 500;
  }

  void _loadFormFromHabit(Habit habit) {
    _nameController.text = habit.name;
    _habitIcon = habit.icon ?? defaultHabitIconKey;
    _applyUnit(habit.goalUnit);
    _goalPeriod = habit.goalPeriod;
    _setGoalValue(habit.goalValue);
    _goalDirection = habit.goalDirection;
    _taskDays = habit.taskDays.toSet();
    _timeRange = habit.timeRange;
    _reminderEnabled = habit.reminderEnabled;
    _reminderTime = _parseTime(habit.reminderTime) ?? const TimeOfDay(hour: 8, minute: 0);
    _startDate = habit.startDate;
    _endDate = habit.endDate;
  }

  void _resetFormDraft({
    String? name,
    String? icon,
    GoalPeriod? goalPeriod,
    int? goalValue,
    String? goalUnit,
    TimeRange? timeRange,
    GoalDirection? goalDirection,
    DateTime? startDate,
  }) {
    _nameController.text = name ?? '';
    _habitIcon = icon ?? defaultHabitIconKey;
    _applyUnit(goalUnit ?? 'x');
    _goalPeriod = goalPeriod ?? GoalPeriod.daily;
    _setGoalValue(goalValue ?? 1);
    _goalDirection = goalDirection ?? GoalDirection.atLeast;
    _taskDays = {allDaysKey};
    _timeRange = timeRange ?? TimeRange.anytime;
    _reminderEnabled = false;
    _reminderTime = const TimeOfDay(hour: 8, minute: 0);
    _startDate = startDate ?? today();
    _endDate = null;
  }

  TimeOfDay? _parseTime(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// True if [categoryId] is the built-in Finance category — checked via
  /// the `categoriesProvider` cache already watched in build(), so it's
  /// safe to call from an async handler without waiting for a reload.
  bool _categoryIdIsFinance(int? categoryId) {
    final categories = ref.read(categoriesProvider).value ?? const <Category>[];
    for (final c in categories) {
      if (c.id == categoryId) return isFinanceCategory(c);
    }
    return false;
  }

  /// Finance category (Save Money) is Pro-only — checked at the category
  /// pick point (step 1) AND at the submit point (step 3 has its own goal
  /// phrase dropdown that can change _categoryId without going through step 1 again).
  Future<bool> _blockedByFinanceGate() async {
    if (!_categoryIdIsFinance(_categoryId) || ref.read(isProProvider)) return false;
    await showProRequiredDialog(
      context,
      message: 'The Finance category (Save Money) is Pro-only. Upgrade to Pro '
          'to manage finance habits & see your savings summary.',
    );
    return true;
  }

  /// Free users are capped at 5 active habits — only relevant when creating
  /// a new habit, not when editing an existing one.
  Future<bool> _blockedByFreeHabitLimit() async {
    if (ref.read(isProProvider)) return false;
    final activeHabits = await ref.read(habitRepositoryProvider).getAllActive();
    if (activeHabits.length < _freeActiveHabitLimit) return false;
    if (mounted) {
      await showProRequiredDialog(
        context,
        message: 'You\'ve reached the $_freeActiveHabitLimit active habit limit for '
            'Free users. Upgrade to Pro to add unlimited habits.',
      );
    }
    return true;
  }

  void _push(int step) => setState(() => _stepStack.add(step));

  void _back() {
    if (_stepStack.length <= 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _stepStack.removeLast());
  }

  String get _title {
    switch (_step) {
      case 1:
        return 'Pick Goal Phrase';
      case 2:
        return 'Add Habit';
      case 3:
        return _isEditing ? 'Edit Habit' : 'Habit Form';
      case 4:
        return 'New Goal';
      default:
        return '';
    }
  }

  bool get _showBack => _step != 1 && !_isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.sizeOf(context).width >= 900;
    final maxWidth = MediaQuery.sizeOf(context).width >= 600 ? 880.0 : 640.0;

    return Scaffold(
      // Step 1 (Pick Goal Phrase) gets a grayer backdrop than the app default
      // so the white goal-phrase cards stand out against it.
      backgroundColor: _step == 1
          ? (theme.brightness == Brightness.light ? AppColors.lightSurfaceAlt : AppColors.darkSurfaceAlt)
          : theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: FadeSlideIn(
            child: ListView(
              padding: EdgeInsets.fromLTRB(isTablet ? 44 : 16, isTablet ? 32 : 20, isTablet ? 44 : 16, 40),
              children: [
                Row(
                  children: [
                    if (_showBack)
                      _RoundIconButton(icon: Icons.chevron_left_rounded, onTap: _back)
                    else
                      const SizedBox(width: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_title, style: theme.textTheme.titleLarge),
                    ),
                    _RoundIconButton(
                      icon: Icons.close_rounded,
                      iconSize: 14,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                switch (_step) {
                  1 => _buildStep1(),
                  2 => _buildStep2(),
                  3 => _buildStep3(),
                  4 => _buildStep4(),
                  _ => const SizedBox.shrink(),
                },
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Step 1: pick category ----------------

  Widget _buildStep1() {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick a goal phrase for the new habit.', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('Failed to load categories: $e'),
          data: (categories) {
            final columns = categoryGridColumns(MediaQuery.sizeOf(context).width);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.74,
              ),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return FadeSlideIn(
                    delay: staggeredDelay(index),
                    child: DashedBorder(
                    borderRadius: 20,
                    onTap: () => _push(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              // Not surfaceContainerHighest — that's an M3
                              // tone auto-generated from the gold seed that's
                              // off from the app's neutral palette (same as the dividerColor case).
                              color: theme.brightness == Brightness.light
                                  ? AppColors.lightSurfaceAlt
                                  : AppColors.darkSurfaceAlt,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add_rounded, color: theme.textTheme.bodySmall?.color),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Create New Goal',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontFamily: 'Poppins',
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  );
                }
                final category = categories[index];
                final color = AppColors.categoryColorFromHex(category.colorHex, index);
                return FadeSlideIn(
                  delay: staggeredDelay(index),
                  child: _CategoryGridTile(
                    name: category.name,
                    description: goalPhraseDescriptionFor(category),
                    icon: isFinanceCategory(category) ? 'credit-card' : category.icon,
                    color: color,
                    onTap: () {
                      if (isFinanceCategory(category) && !ref.read(isProProvider)) {
                        showProRequiredDialog(
                          context,
                          message:
                              'The Finance category (Save Money) is Pro-only. Upgrade to '
                              'Pro to manage finance habits & see your savings summary.',
                        );
                        return;
                      }
                      _categoryId = category.id;
                      _push(2);
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ---------------- Step 2: recommendations / custom ----------------

  Widget _buildStep2() {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final templatesAsync = ref.watch(habitTemplatesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('$e'),
      data: (categories) {
        Category? category;
        for (final c in categories) {
          if (c.id == _categoryId) category = c;
        }
        final color = category == null
            ? Theme.of(context).colorScheme.primary
            : AppColors.categoryColorFromHex(category.colorHex, categories.indexOf(category));

        return templatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text('$e'),
          data: (allTemplates) {
            final match = category == null
                ? const <CategoryTemplate>[]
                : allTemplates.where((t) => t.defaultGoalPhrase == category!.name).toList();
            final templates = match.isEmpty ? const <HabitTemplate>[] : match.first.habits;

            final displayIcon =
                category != null && isFinanceCategory(category) ? 'credit-card' : category?.icon;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: Center(child: HabitIcon(icon: displayIcon, size: 22, color: Colors.white)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        category?.name ?? '',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (templates.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('No recommendations for this category yet.', style: theme.textTheme.bodySmall),
                  ),
                for (final t in templates)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _openFormForTemplate(t),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.name, style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 2),
                                  Text(t.goalLabel, style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          PrimaryPillButton(
                            label: 'Add',
                            onPressed: _saving ? null : () => _quickAddTemplate(t),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                DashedBorder(
                  borderRadius: 14,
                  onTap: () => _openCustomForm(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text('+ Add Custom Habit', style: theme.textTheme.titleSmall),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openFormForTemplate(HabitTemplate template) {
    setState(() {
      _resetFormDraft(
        name: template.name,
        icon: template.icon,
        goalPeriod: template.goalPeriod,
        goalValue: template.goalValue,
        goalUnit: template.goalUnit,
        goalDirection: template.goalDirection,
        timeRange: template.timeRange,
      );
      _stepStack.add(3);
    });
  }

  void _openCustomForm() {
    setState(() {
      // Finance habits are nominal (rupiah) only — seed the form with that
      // unit already applied instead of landing on the generic 'x' default
      // that the locked Unit dropdown (see _buildStep3) can't then change.
      _resetFormDraft(goalUnit: _categoryIdIsFinance(_categoryId) ? 'rupiah' : null);
      if (_categoryIdIsFinance(_categoryId) && _goalValue < 1000) _setGoalValue(50000);
      _stepStack.add(3);
    });
  }

  Future<void> _quickAddTemplate(HabitTemplate template) async {
    if (_categoryId == null) return;
    if (await _blockedByFinanceGate() || await _blockedByFreeHabitLimit()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(habitRepositoryProvider);
      final id = await repo.createHabit(
        categoryId: _categoryId!,
        name: template.name,
        icon: template.icon,
        goalPeriod: template.goalPeriod,
        goalValue: template.goalValue,
        goalUnit: template.goalUnit,
        goalDirection: template.goalDirection,
        taskDays: const [allDaysKey],
        timeRange: template.timeRange,
        reminderEnabled: false,
        startDate: today(),
      );
      final created = await repo.getById(id);
      if (created != null) {
        await _tryScheduleNotification(created);
      }
      await _finishAndReturn(toastMessage: 'Habit added');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add habit: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _tryScheduleNotification(Habit habit) async {
    try {
      await ref.read(notificationServiceProvider).rescheduleForHabit(habit);
    } catch (_) {
      // Notification scheduling failed (e.g. platform not supported) —
      // don't fail the habit save because of this.
    }
  }

  // ---------------- Step 3: habit form ----------------

  Widget _buildStep3() {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.lockGoalFields) ...[
          const _CommunityLockedNotice(),
          const SizedBox(height: 16),
        ],
        _LockableSection(
          locked: widget.lockGoalFields,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        _FieldLabel('Habit Name'),
        const SizedBox(height: 6),
        TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Habit name')),
        const SizedBox(height: 16),
        _FieldLabel('Icon'),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final picked = await showIconPickerSheet(context, currentIcon: _habitIcon);
            if (picked != null) setState(() => _habitIcon = picked);
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                child: Center(child: HabitIcon(icon: _habitIcon, size: 16, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Text('Change icon', style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FieldLabel('Goal Phrase'),
        const SizedBox(height: 6),
        categoriesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, st) => Text('$e'),
          data: (categories) {
            final validId = categories.any((c) => c.id == _categoryId) ? _categoryId : null;
            return DropdownButtonFormField<int>(
              initialValue: validId,
              items: [for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name))],
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _categoryId = v;
                  // Finance habits only ever take a nominal (rupiah) input —
                  // no plain checkbox habits under this goal phrase. Force
                  // the unit the moment the goal phrase is switched to
                  // Finance instead of leaving it user-editable.
                  if (_categoryIdIsFinance(v) && !_isRupiahUnit) {
                    _applyUnit('rupiah');
                    if (_goalValue < 1000) _setGoalValue(50000);
                  }
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),
        _FieldLabel('Goal Period'),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final period in GoalPeriod.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: period == GoalPeriod.values.last ? 0 : 8),
                  child: _SelectablePill(
                    label: period.label,
                    selected: _goalPeriod == period,
                    onTap: () => setState(() => _goalPeriod = period),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Goal Value'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StepperButton(
                        icon: Icons.remove_rounded,
                        onTap: _goalValue > 0
                            ? () => setState(() => _setGoalValue(_goalValue - _goalValueStep))
                            : null,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _goalValueController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: theme.textTheme.titleMedium,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            prefixText: _isRupiahUnit ? 'Rp ' : null,
                          ),
                          onChanged: (text) {
                            final parsed = int.tryParse(text) ?? 0;
                            setState(() => _goalValue = parsed.clamp(0, 1 << 30));
                          },
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add_rounded,
                        onTap: () => setState(() => _setGoalValue(_goalValue + _goalValueStep)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Unit'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _unitDropdownValue,
                    // Locked to Rupiah under the Finance goal phrase — no
                    // plain checkbox/x-count habits allowed there (point 15).
                    onChanged: _categoryIdIsFinance(_categoryId)
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() {
                              _unitDropdownValue = v;
                              if (v != 'custom') _goalUnitController.text = v;
                              // Reasonable starting amount for rupiah — more
                              // sensible than starting at 1 and stepping by 500s.
                              if (v == 'rupiah' && _goalValue < 1000) _setGoalValue(50000);
                            });
                          },
                    items: [
                      for (final value in unitPresetValues)
                        DropdownMenuItem(value: value, child: Text(unitPresetLabels[value]!)),
                      DropdownMenuItem(value: 'custom', child: Text(unitPresetLabels['custom']!)),
                    ],
                  ),
                  if (_unitDropdownValue == 'custom') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _goalUnitController,
                      decoration: const InputDecoration(hintText: 'e.g. book pages'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _FieldLabel('Target Direction'),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final direction in GoalDirection.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: direction == GoalDirection.values.last ? 0 : 8),
                  child: _SelectablePill(
                    label: direction.label,
                    selected: _goalDirection == direction,
                    onTap: () => setState(() => _goalDirection = direction),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(_goalDirection.helperText, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FieldLabel('Task Days'),
            InkWell(
              onTap: () => setState(() => _taskDays = {allDaysKey}),
              child: Text(
                'Every day',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _TaskDaysGrid(
          selected: _taskDays,
          onChanged: (days) => setState(() => _taskDays = days),
        ),
        const SizedBox(height: 16),
        _FieldLabel('Time Range'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tr in TimeRange.values)
              _SelectablePill(
                label: tr.label,
                selected: _timeRange == tr,
                pill: true,
                onTap: () => setState(() => _timeRange = tr),
              ),
          ],
        ),
        ], // end Column children (locked section)
          ), // end Column (locked section)
        ), // end _LockableSection
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reminder', style: theme.textTheme.bodyMedium),
                Row(
                  children: [
                    if (_reminderEnabled) ...[
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: _reminderTime);
                          if (picked != null) setState(() => _reminderTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_formatTime(_reminderTime), style: theme.textTheme.bodySmall),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    ToggleSwitch(
                      value: _reminderEnabled,
                      onChanged: (v) => setState(() => _reminderEnabled = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _LockableSection(
          locked: widget.lockGoalFields,
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Start Date'),
                  const SizedBox(height: 6),
                  _DateField(
                    date: _startDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _startDate = dateOnly(picked));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FieldLabel('End Date'),
                      InkWell(
                        onTap: () => setState(() => _endDate = _endDate == null ? today() : null),
                        child: Text(
                          _endDate == null ? 'Set date' : 'No limit',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_endDate != null)
                    _DateField(
                      date: _endDate!,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate!,
                          firstDate: _startDate,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _endDate = dateOnly(picked));
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('No time limit', style: theme.textTheme.bodySmall),
                    ),
                ],
              ),
            ),
          ],
        ),
        ), // end _LockableSection (start/end date)
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saving ? null : _submitHabitForm,
          child: Text(_isEditing ? 'Save Changes' : 'Save Habit'),
        ),
      ],
    );
  }

  Future<void> _submitHabitForm() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit name is required')));
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick a goal phrase first')));
      return;
    }
    if (_taskDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick at least 1 active day')));
      return;
    }
    if (await _blockedByFinanceGate()) return;
    if (!_isEditing && await _blockedByFreeHabitLimit()) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(habitRepositoryProvider);
      final goalUnit = _goalUnitController.text.trim().isEmpty ? 'x' : _goalUnitController.text.trim();
      final reminderTimeStr = _reminderEnabled ? _formatTime(_reminderTime) : null;
      final taskDaysList = _taskDays.contains(allDaysKey) ? [allDaysKey] : _taskDays.toList();

      if (_isEditing) {
        final updated = Habit(
          id: widget.editingHabit!.id,
          categoryId: _categoryId!,
          name: name,
          description: widget.editingHabit!.description,
          icon: _habitIcon,
          goalPeriod: _goalPeriod,
          goalValue: _goalValue,
          goalUnit: goalUnit,
          goalDirection: _goalDirection,
          taskDays: taskDaysList,
          timeRange: _timeRange,
          reminderEnabled: _reminderEnabled,
          reminderTime: reminderTimeStr,
          startDate: _startDate,
          endDate: _endDate,
          isActive: widget.editingHabit!.isActive,
          sortOrder: widget.editingHabit!.sortOrder,
          createdAt: widget.editingHabit!.createdAt,
        );
        await repo.updateHabit(updated);
        await _tryScheduleNotification(updated);
      } else {
        final id = await repo.createHabit(
          categoryId: _categoryId!,
          name: name,
          icon: _habitIcon,
          goalPeriod: _goalPeriod,
          goalValue: _goalValue,
          goalUnit: goalUnit,
          goalDirection: _goalDirection,
          taskDays: taskDaysList,
          timeRange: _timeRange,
          reminderEnabled: _reminderEnabled,
          reminderTime: reminderTimeStr,
          startDate: _startDate,
          endDate: _endDate,
        );
        final created = await repo.getById(id);
        if (created != null) {
          await _tryScheduleNotification(created);
        }
      }

      await _finishAndReturn(
        toastMessage: _isEditing ? 'Habit updated' : 'Habit added',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save habit: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------- Step 4: new category ----------------

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Goal Phrase Name'),
        const SizedBox(height: 6),
        TextField(
          controller: _newCatNameController,
          decoration: const InputDecoration(hintText: 'e.g. Hobby'),
        ),
        const SizedBox(height: 20),
        _FieldLabel('Color'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < AppColors.customCategoryColorPalette.length; i++)
              _ColorSwatch(
                color: AppColors.customCategoryColorPalette[i],
                selected: _newCatColorIndex == i,
                onTap: () => setState(() => _newCatColorIndex = i),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _FieldLabel('Icon'),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final picked = await showIconPickerSheet(context, currentIcon: _newCatIcon);
            if (picked != null) setState(() => _newCatIcon = picked);
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.customCategoryColorPalette[_newCatColorIndex],
                  shape: BoxShape.circle,
                ),
                child: Center(child: HabitIcon(icon: _newCatIcon, size: 16, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Text(
                'Change icon',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saving ? null : _submitNewCategory,
          child: const Text('Create Goal'),
        ),
      ],
    );
  }

  Future<void> _submitNewCategory() async {
    final name = _newCatNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal phrase name is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      final colorHex =
          '#${AppColors.customCategoryColorPalette[_newCatColorIndex].toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      final id = await ref.read(categoryRepositoryProvider).createCustomCategory(
            name: name,
            icon: _newCatIcon,
            colorHex: colorHex,
          );

      if (widget.startAtNewCategory) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      setState(() {
        _categoryId = id;
        _stepStack = [1, 2];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to create category: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// The Home flat-list (CLAUDE.md v3 §6.1) reactively shows the new habit
  /// once saved — no need to navigate to any category screen anymore, just
  /// invalidate the summaries then pop back.
  Future<void> _finishAndReturn({required String toastMessage}) async {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);
    ref.invalidate(financeSummaryProvider);
    ref.invalidate(financeSummaryForPeriodProvider);

    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.pop();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toastMessage)));
    }
  }
}

class _CategoryGridTile extends StatelessWidget {
  const _CategoryGridTile({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String description;
  final String? icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(child: HabitIcon(icon: icon, size: 24, color: Colors.white)),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                description,
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

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap, this.iconSize = 16});

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: iconSize),
        ),
      ),
    );
  }
}

/// Dims and disables (via `IgnorePointer`) [child] when [locked] — used for
/// every field group except Reminder when editing a habit that's linked to
/// Community (see `AddHabitFlowScreen.lockGoalFields`).
class _LockableSection extends StatelessWidget {
  const _LockableSection({required this.locked, required this.child});

  final bool locked;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return IgnorePointer(
      child: Opacity(opacity: 0.45, child: child),
    );
  }
}

/// Explains why most fields below are locked — shown when editing a habit
/// linked to a Community Group Habit.
class _CommunityLockedNotice extends StatelessWidget {
  const _CommunityLockedNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.groups_rounded, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This habit is linked to a Community group, so its target and '
              'schedule stay locked to match everyone tracking it. Unlink it '
              'from the group\'s Habits tab first to change them. Reminder '
              'settings are still yours to change.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.pill = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(pill ? 999 : 10),
      child: Container(
        padding: pill
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
            : const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Fill netral sama seperti pill/switch lain di app (bukan
          // dividerColor — itu warna border tipis, terlalu gelap/pekat kalau
          // dipakai sebagai fill solid via withValues(alpha:...)).
          color: selected
              ? theme.colorScheme.primary
              : (theme.brightness == Brightness.light
                  ? AppColors.lightSurfaceAlt
                  : AppColors.darkSurfaceAlt),
          borderRadius: BorderRadius.circular(pill ? 999 : 10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: pill ? 12.5 : 13,
            color: selected ? Colors.white : theme.textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 18)),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(formatted, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _TaskDaysGrid extends StatelessWidget {
  const _TaskDaysGrid({required this.selected, required this.onChanged});

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  bool get _isEveryDay => selected.contains(allDaysKey);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1,
      children: [
        for (final day in weekdayKeys)
          Builder(builder: (context) {
            final isSelected = _isEveryDay || selected.contains(day);
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Set<String> next;
                if (_isEveryDay) {
                  next = weekdayKeys.where((d) => d != day).toSet();
                } else {
                  next = Set<String>.from(selected);
                  if (next.contains(day)) {
                    next.remove(day);
                  } else {
                    next.add(day);
                  }
                }
                onChanged(next);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (theme.brightness == Brightness.light
                          ? AppColors.lightSurfaceAlt
                          : AppColors.darkSurfaceAlt),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  weekdayLabels[day]!,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3)
              : null,
        ),
      ),
    );
  }
}
