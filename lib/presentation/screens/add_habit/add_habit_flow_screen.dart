import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/language.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/habit.dart';
import '../../../domain/models/habit_draft.dart';
import '../../../domain/models/habit_template.dart';
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
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/icon_picker_sheet.dart';
import '../../widgets/pro_feature_teaser.dart';
import '../../widgets/currency_amount_field.dart';
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
/// Community Group Habit (see `AddHabitFlowScreen.lockGoalFields`). Returns
/// true if the habit was actually saved (vs. the user backing/canceling
/// out) — callers use this to tell a real save apart from a no-op close
/// (e.g. Home's edit mode only auto-exits on an actual save, #9).
Future<bool> openEditHabitFlow(
  BuildContext context,
  Habit habit, {
  bool lockGoalFields = false,
}) async {
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => AddHabitFlowScreen(editingHabit: habit, lockGoalFields: lockGoalFields),
    ),
  );
  return saved ?? false;
}

/// Open the flow directly at the "Create New Category" step (from
/// Settings/onboarding), then return to the caller once the category is
/// created (does not continue to recommendations).
Future<int?> openCreateCategoryFlow(BuildContext context) {
  return Navigator.of(context).push<int>(
    MaterialPageRoute(builder: (_) => const AddHabitFlowScreen(startAtNewCategory: true)),
  );
}

/// Open the flow directly at the "Budget Tracker" (kategori Save Money)
/// singleton form — no template picker, ever (see `startAtSpendingMoneyForm`
/// doc). Used from Home's Step 1 tile, onboarding's goal-phrase pick step,
/// and the Finance summary page's FAB. Pro-gate and "already has one" checks
/// happen inside the screen itself. Returns true if a habit was actually
/// saved.
Future<bool> openBudgetTrackerFlow(BuildContext context) async {
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const AddHabitFlowScreen(startAtSpendingMoneyForm: true)),
  );
  return saved ?? false;
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
    this.startAtSpendingMoneyForm = false,
    this.lockGoalFields = false,
  });

  final int? initialCategoryId;
  final Habit? editingHabit;
  final bool startAtNewCategory;

  /// Lompat langsung ke Step 3 dengan draft habit "Spending Money" (kategori
  /// Save Money) — tidak pernah melewati Step 2 (pilih template), karena
  /// kategori ini cuma punya 1 jenis habit singleton. Dipakai dari
  /// `openSpendingMoneyFlow` (Home/onboarding/halaman Finance). Pro-gate dan
  /// pengecekan singleton (sudah punya habit Finance atau belum) dilakukan
  /// setelah frame pertama (`_initSpendingMoneyEntry`), bukan sinkron di
  /// `initState`, karena keduanya butuh `context` (dialog) dan/atau provider
  /// async.
  final bool startAtSpendingMoneyForm;

  /// When editing a habit that's linked to a Community Group Habit, locks
  /// every field except Reminder and Time Range — name, icon, goal phrase/
  /// period/value/unit/direction, task days, and start/end date all stay
  /// exactly what the Group Habit was published/adopted with, so tracking
  /// against the shared leaderboard target never silently drifts out of
  /// sync from one device's local edit. Reminder and Time Range are purely
  /// local "when" preferences never synced to the group, so they're always
  /// editable. Unlink from Community first to change any of the locked ones.
  final bool lockGoalFields;

  @override
  ConsumerState<AddHabitFlowScreen> createState() => _AddHabitFlowScreenState();
}

class _AddHabitFlowScreenState extends ConsumerState<AddHabitFlowScreen> {
  late List<int> _stepStack;
  int? _categoryId;
  bool _saving = false;

  // Step 2 multi-select state — templates picked from the recommendation
  // list, added together via "Add N Habits" instead of one at a time. Each
  // entry carries its own categoryId (not just the template) so the user
  // can switch goal phrases via the chip row without losing selections
  // already made under a different one — every entry still gets created
  // under the goal phrase it was actually picked from.
  final Set<({int categoryId, HabitTemplate template})> _selectedTemplates = {};

  // Step 3 form state.
  final _nameController = TextEditingController();
  final _nameIdController = TextEditingController();
  // True kalau title (nama Inggris & Indonesia) boleh diedit user — false
  // untuk habit yang berasal dari template bawaan (dikunci, CLAUDE.md
  // §Bahasa), true untuk habit custom buatan user sendiri.
  bool _isCustomDraft = true;
  String? _templateKeyDraft;
  final _goalUnitController = TextEditingController(text: 'x');
  final _goalValueController = TextEditingController(text: '1');
  // Override goalValue khusus Sabtu-Minggu untuk habit daily — lihat toggle
  // "Custom weekend goal" di Step 3. `_customWeekendGoal` OFF (default) =
  // goalValueWeekend null saat disimpan (perilaku lama, sama tiap hari).
  final _goalValueWeekendController = TextEditingController(text: '1');
  bool _customWeekendGoal = false;
  int _goalValueWeekend = 1;
  String _habitIcon = defaultHabitIconKey;
  String _unitDropdownValue = 'x';
  GoalPeriod _goalPeriod = GoalPeriod.daily;
  int _goalValue = 1;
  GoalDirection _goalDirection = GoalDirection.atLeast;
  Set<String> _taskDays = {allDaysKey};
  TimeRange _timeRange = TimeRange.anytime;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  // null = single reminder at _reminderTime; otherwise repeats every N
  // minutes starting there until end of day (#19).
  int? _reminderIntervalMinutes;
  DateTime _startDate = today();
  DateTime? _endDate;

  /// Currency code (IDR/USD/SGD/MYR/EUR) for the Budget Tracker form —
  /// label/prefix only, doesn't change number formatting. Irrelevant for
  /// normal habits.
  String _currency = 'IDR';

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
    } else if (widget.startAtSpendingMoneyForm) {
      // Belum tahu kategori Finance-nya (butuh await categoriesProvider) dan
      // pro-gate/singleton butuh context — mulai dari Step 1 kosong dulu,
      // ganti begitu `_initSpendingMoneyEntry` selesai (lihat post-frame
      // callback di bawah).
      _stepStack = [1];
      WidgetsBinding.instance.addPostFrameCallback((_) => _initSpendingMoneyEntry());
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
    _nameIdController.dispose();
    _goalUnitController.dispose();
    _goalValueController.dispose();
    _goalValueWeekendController.dispose();
    _newCatNameController.dispose();
    super.dispose();
  }

  /// Cari `Category` Finance/Save Money yang sudah pasti di-seed sejak first
  /// launch (lihat `CategoryRepository.seedDefaultCategories`) — dipakai baik
  /// dari tile Step 1 maupun entry langsung (`startAtSpendingMoneyForm`).
  Category? _financeCategory(List<Category> categories) {
    for (final c in categories) {
      if (isFinanceCategory(c)) return c;
    }
    return null;
  }

  /// Habit aktif, dikecualikan yang sedang menunggu penghapusan permanen dari
  /// Home (deferred delete lewat `pendingDeleteHabitIdsProvider` — kartu
  /// langsung hilang dari list Home, tapi baris DB baru benar-benar terhapus
  /// beberapa detik kemudian setelah snackbar undo hilang, jadi tetap
  /// `isActive` di DB selama jeda itu). Dipakai di semua titik yang mengecek
  /// "apakah user sudah punya habit X" (singleton Finance, "Already Added" di
  /// Step 2, nama duplikat) — SATU sumber kebenaran supaya jeda deferred
  /// delete tidak lagi bikin habit yang baru dihapus keliru dianggap masih
  /// ada di titik pengecekan manapun.
  /// Pakai `ref.read` (bukan `watch`) supaya aman dipanggil dari event
  /// handler (onTap/onChanged/async) di luar `build()`, bukan cuma dari
  /// dalam widget tree — sebagian besar caller-nya memang event handler.
  List<Habit> _activeHabitsExcludingPendingDelete() {
    final activeHabits = ref.read(allActiveHabitsProvider).value ?? const <Habit>[];
    final pendingDeleteIds = ref.read(pendingDeleteHabitIdsProvider);
    return activeHabits.where((h) => !pendingDeleteIds.contains(h.id)).toList();
  }

  /// Habit Finance aktif yang sudah ada (selain [excludingId], dipakai saat
  /// edit) — null kalau belum ada. Kategori Save Money singleton: cuma boleh
  /// ada 1 habit aktif per user.
  Habit? _existingFinanceHabit({int? excludingId}) {
    for (final h in _activeHabitsExcludingPendingDelete()) {
      if (_categoryIdIsFinance(h.categoryId) && h.id != excludingId) return h;
    }
    return null;
  }

  /// Template canonical tunggal kategori Finance (`limit_daily_spending`,
  /// lihat `habit_templates.json`) — sumber default nama/ikon/goalValue untuk
  /// form singleton "Spending Money", walau user tidak lagi memilihnya dari
  /// daftar (Step 2 dilewati sepenuhnya untuk kategori ini).
  Future<HabitTemplate?> _financeTemplate() async {
    final categoryTemplates = await ref.read(habitTemplatesProvider.future);
    for (final ct in categoryTemplates) {
      if (ct.habits.isNotEmpty && ct.key == 'finance') return ct.habits.first;
    }
    return null;
  }

  /// Dialog "sudah ada" — kategori Save Money cuma boleh 1 habit aktif.
  /// Tawarkan langsung buka edit habit yang sudah ada alih-alih menambah baru.
  Future<void> _showSpendingMoneyExistsDialog(Habit existing) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldEdit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addHabitSpendingMoneyExistsTitle),
        content: Text(l10n.addHabitSpendingMoneyExistsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonEdit),
          ),
        ],
      ),
    );
    if (shouldEdit == true && mounted) {
      await openEditHabitFlow(context, existing);
    }
  }

  /// Set draft Step 3 langsung ke habit "Spending Money" (kategori Save
  /// Money) — selalu `goalUnit=rupiah`, `goalDirection=atMost` (dikunci di
  /// UI, lihat Step 3), goalPeriod & goalValue tetap bisa diubah user.
  /// Melewati Step 2 sepenuhnya (`_stepStack = [3]`) karena kategori ini
  /// cuma punya 1 jenis habit singleton, tidak ada opsi template dipilih.
  void _openSpendingMoneyForm(int categoryId, HabitTemplate? template) {
    setState(() {
      _resetFormDraft(
        name: template?.name ?? 'Budget Tracker',
        nameId: template?.nameId ?? 'Pelacak Anggaran',
        isCustom: false,
        templateKey: template?.key ?? _spendingMoneyTemplateKey,
        icon: template?.icon ?? 'credit-card',
        goalPeriod: template?.goalPeriod ?? GoalPeriod.daily,
        goalValue: template?.goalValue ?? 50000,
        goalUnit: 'rupiah',
        goalDirection: GoalDirection.atMost,
        goalValueWeekend: template?.goalValueWeekend,
      );
      _currency = 'IDR';
      _formatBudgetTrackerAmountControllers();
      _categoryId = categoryId;
      _stepStack = [3];
    });
  }

  /// Dipanggil sekali lewat post-frame callback saat `startAtSpendingMoneyForm`
  /// — cek Pro-gate & singleton (butuh context/provider async, tidak bisa di
  /// `initState`), lalu buka form atau pop kembali kalau diblokir.
  Future<void> _initSpendingMoneyEntry() async {
    final categories = await ref.read(categoriesProvider.future);
    if (!mounted) return;
    final financeCategory = _financeCategory(categories);
    if (financeCategory == null) {
      Navigator.of(context).pop(false);
      return;
    }
    if (!ref.read(isProProvider)) {
      await showProRequiredDialog(context, message: AppLocalizations.of(context)!.addHabitFinanceProOnly);
      if (mounted) Navigator.of(context).pop(false);
      return;
    }
    final existing = _existingFinanceHabit();
    if (existing != null) {
      await _showSpendingMoneyExistsDialog(existing);
      if (mounted) Navigator.of(context).pop(false);
      return;
    }
    final template = await _financeTemplate();
    if (!mounted) return;
    _openSpendingMoneyForm(financeCategory.id, template);
  }

  /// Key template canonical kategori Finance (Budget Tracker) — dipakai
  /// sebagai `templateKey` fallback saat `_financeTemplate()` gagal
  /// ditemukan (mis. JSON gagal dimuat), supaya habit yang dibuat tetap
  /// konsisten dicocokkan.
  static const String _spendingMoneyTemplateKey = 'budget_tracker';

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

  static Map<String, String> unitPresetLabelsFor(AppLocalizations l10n) => {
        'x': l10n.unitNoUnit,
        'minute': l10n.unitMinute,
        'hour': l10n.unitHour,
        'step': l10n.unitStep,
        'glass': l10n.unitGlass,
        'page': l10n.unitPage,
        'time': l10n.unitTime,
        'kilometer': l10n.unitKilometer,
        'rupiah': l10n.unitRupiah,
        'custom': l10n.unitCustom,
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

  /// Reformats [_goalValueController]/[_goalValueWeekendController]'s text
  /// with thousand separators — only ever called for the Budget Tracker
  /// form, whose amount fields use [ThousandsInputFormatter] (unlike the
  /// normal form's digits-only field), so their *initial* text (set via
  /// [_setGoalValue] as a plain digit string) needs one manual pass to match
  /// what the formatter would produce once the user starts typing.
  void _formatBudgetTrackerAmountControllers() {
    final format = NumberFormat.decimalPattern('id_ID');
    _goalValueController.text = _goalValue == 0 ? '' : format.format(_goalValue);
    _goalValueWeekendController.text = _goalValueWeekend == 0 ? '' : format.format(_goalValueWeekend);
  }

  /// Sama seperti [_setGoalValue] tapi untuk override weekend (Sabtu-Minggu).
  void _setGoalValueWeekend(int value) {
    _goalValueWeekend = value.clamp(0, 1 << 30);
    final text = '$_goalValueWeekend';
    if (_goalValueWeekendController.text != text) {
      _goalValueWeekendController.text = text;
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

  /// Nama yang ditampilkan untuk habit template terkunci (`!_isCustomDraft`)
  /// — satu field saja sesuai bahasa aplikasi aktif, bukan dua field EN/ID
  /// sekaligus. `_nameController`/`_nameIdController` sendiri tetap
  /// menyimpan kedua versi (dipakai apa adanya saat submit/edit).
  String _lockedDisplayName(AppLang lang) {
    if (lang == AppLang.id && _nameIdController.text.isNotEmpty) {
      return _nameIdController.text;
    }
    return _nameController.text;
  }

  void _loadFormFromHabit(Habit habit) {
    _nameController.text = habit.name;
    _nameIdController.text = habit.nameId ?? '';
    _isCustomDraft = habit.isCustom;
    _templateKeyDraft = habit.templateKey;
    _habitIcon = habit.icon ?? defaultHabitIconKey;
    _applyUnit(habit.goalUnit);
    _goalPeriod = habit.goalPeriod;
    _setGoalValue(habit.goalValue);
    _customWeekendGoal = habit.goalValueWeekend != null;
    _setGoalValueWeekend(habit.goalValueWeekend ?? habit.goalValue);
    _goalDirection = habit.goalDirection;
    _taskDays = habit.taskDays.toSet();
    _timeRange = habit.timeRange;
    _reminderEnabled = habit.reminderEnabled;
    _reminderTime = _parseTime(habit.reminderTime) ?? const TimeOfDay(hour: 8, minute: 0);
    _reminderIntervalMinutes = habit.reminderIntervalMinutes;
    _startDate = habit.startDate;
    _endDate = habit.endDate;
    _currency = habit.currency ?? 'IDR';
    if (habit.isRupiah && habit.goalDirection == GoalDirection.atMost) {
      _formatBudgetTrackerAmountControllers();
    }
  }

  void _resetFormDraft({
    String? name,
    String? nameId,
    bool isCustom = true,
    String? templateKey,
    String? icon,
    GoalPeriod? goalPeriod,
    int? goalValue,
    int? goalValueWeekend,
    String? goalUnit,
    TimeRange? timeRange,
    GoalDirection? goalDirection,
    DateTime? startDate,
  }) {
    _nameController.text = name ?? '';
    _nameIdController.text = nameId ?? '';
    _isCustomDraft = isCustom;
    _templateKeyDraft = templateKey;
    _habitIcon = icon ?? defaultHabitIconKey;
    _applyUnit(goalUnit ?? 'x');
    _goalPeriod = goalPeriod ?? GoalPeriod.daily;
    _setGoalValue(goalValue ?? 1);
    _customWeekendGoal = goalValueWeekend != null;
    _setGoalValueWeekend(goalValueWeekend ?? _goalValue);
    _goalDirection = goalDirection ?? GoalDirection.atLeast;
    _taskDays = {allDaysKey};
    _timeRange = timeRange ?? TimeRange.anytime;
    _reminderEnabled = false;
    _reminderTime = const TimeOfDay(hour: 8, minute: 0);
    _reminderIntervalMinutes = null;
    _startDate = startDate ?? today();
    _endDate = null;
    _currency = 'IDR';
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
  /// [categoryId] defaults to the current draft's category; Step 2's
  /// multi-select batch passes each distinct category among the selected
  /// entries, since a batch can span goal phrases other than the one
  /// currently on screen.
  Future<bool> _blockedByFinanceGate([int? categoryId]) async {
    if (!_categoryIdIsFinance(categoryId ?? _categoryId) || ref.read(isProProvider)) return false;
    await showProRequiredDialog(
      context,
      message: AppLocalizations.of(context)!.addHabitFinanceProOnly,
    );
    return true;
  }

  /// Free users are capped at 5 active habits — only relevant when creating
  /// new habit(s), not when editing an existing one. [additional] is how
  /// many new habits this action would add (>1 for the Step 2 multi-select
  /// "Add N Habits" batch) — blocked when the batch would push the total
  /// past the cap, not just when already at/over it.
  Future<bool> _blockedByFreeHabitLimit({int additional = 1}) async {
    if (ref.read(isProProvider)) return false;
    final activeHabits = await ref.read(habitRepositoryProvider).getAllActive();
    if (activeHabits.length + additional <= _freeActiveHabitLimit) return false;
    if (mounted) {
      await showProRequiredDialog(
        context,
        message: AppLocalizations.of(context)!.addHabitFreeLimitMessage(_freeActiveHabitLimit),
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

  String _titleFor(AppLocalizations l10n) {
    switch (_step) {
      case 1:
        return l10n.addHabitTitlePickGoalPhrase;
      case 2:
        return l10n.addHabitTitleAddHabit;
      case 3:
        if (_categoryIdIsFinance(_categoryId)) {
          return _isEditing ? l10n.budgetTrackerTitleEditBudget : l10n.budgetTrackerTitleBudgetForm;
        }
        return _isEditing ? l10n.addHabitTitleEditHabit : l10n.addHabitTitleHabitForm;
      case 4:
        return l10n.addHabitTitleNewGoal;
      default:
        return '';
    }
  }

  bool get _showBack => _step != 1 && !_isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.sizeOf(context).width >= 900;
    final maxWidth = MediaQuery.sizeOf(context).width >= 600 ? 880.0 : 640.0;
    final showSelectionBar = _step == 2 && _selectedTemplates.isNotEmpty;

    return Scaffold(
      // Step 1 (Pick Goal Phrase) gets a grayer backdrop than the app default
      // so the white goal-phrase cards stand out against it.
      backgroundColor: _step == 1
          ? (theme.brightness == Brightness.light ? AppColors.lightSurfaceAlt : AppColors.darkSurfaceAlt)
          : theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: FadeSlideIn(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 44 : 16,
                      isTablet ? 32 : 20,
                      isTablet ? 44 : 16,
                      40,
                    ),
                    children: [
                      Row(
                        children: [
                          if (_showBack)
                            _RoundIconButton(icon: Icons.chevron_left_rounded, onTap: _back)
                          else
                            const SizedBox(width: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(_titleFor(l10n), style: theme.textTheme.titleLarge),
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
            if (showSelectionBar) _buildSelectionBar(context, l10n, maxWidth),
          ],
        ),
      ),
    );
  }

  /// Pinned bar below the Step 2 list (a sibling in the outer `Column`, not
  /// inside the scrolling `ListView`) — appears once at least 1 template is
  /// selected, showing the "Add N Habits" batch action so it's always
  /// reachable without scrolling down. The outer `SafeArea` in `build()`
  /// already keeps this clear of the system nav bar, so no extra one here.
  Widget _buildSelectionBar(BuildContext context, AppLocalizations l10n, double maxWidth) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: ElevatedButton(
              onPressed: _saving ? null : _addSelectedTemplates,
              child: Text(l10n.addHabitAddSelected(_selectedTemplates.length)),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Step 1: pick category ----------------

  Widget _buildStep1() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.addHabitPickGoalPhrase, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Text(l10n.addHabitFailedToLoadCategories('$e')),
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
                            l10n.addHabitCreateNewGoal,
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
                    name: category.displayName(lang),
                    description: goalPhraseDescriptionFor(category),
                    icon: isFinanceCategory(category) ? 'credit-card' : category.icon,
                    color: color,
                    onTap: () async {
                      if (isFinanceCategory(category)) {
                        // Save Money singleton: tidak ada Step 2 (pilih
                        // template) — langsung ke form, atau tawarkan edit
                        // kalau sudah ada habit Finance aktif.
                        if (!ref.read(isProProvider)) {
                          showProRequiredDialog(context, message: l10n.addHabitFinanceProOnly);
                          return;
                        }
                        final existing = _existingFinanceHabit();
                        if (existing != null) {
                          await _showSpendingMoneyExistsDialog(existing);
                          return;
                        }
                        final template = await _financeTemplate();
                        if (!mounted) return;
                        _openSpendingMoneyForm(category.id, template);
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

  /// True kalau user sudah punya habit aktif yang berasal dari template [t]
  /// (dicocokkan lewat `templateKey`, atau nama sebagai fallback untuk habit
  /// lama yang belum ter-backfill) — dipakai supaya template yang sama tidak
  /// bisa ditambahkan dua kali dari Step 2.
  bool _templateAlreadyAdded(HabitTemplate t, List<Habit> activeHabits) {
    final normalizedNames = {
      t.name.trim().toLowerCase(),
      if (t.nameId != null) t.nameId!.trim().toLowerCase(),
    };
    return activeHabits.any((h) {
      if (widget.editingHabit != null && h.id == widget.editingHabit!.id) return false;
      if (h.templateKey != null) return h.templateKey == t.key;
      return normalizedNames.contains(h.name.trim().toLowerCase()) ||
          (h.nameId != null && normalizedNames.contains(h.nameId!.trim().toLowerCase()));
    });
  }

  Widget _buildStep2() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final templatesAsync = ref.watch(habitTemplatesProvider);
    // Kecualikan habit yang sedang menunggu penghapusan permanen (deferred
    // delete dari Home) — kalau tidak, template-nya masih kelihatan "Already
    // Added" walau kartunya sudah hilang dari Home.
    final pendingDeleteIds = ref.watch(pendingDeleteHabitIdsProvider);
    final activeHabits = (ref.watch(allActiveHabitsProvider).value ?? const <Habit>[])
        .where((h) => !pendingDeleteIds.contains(h.id))
        .toList();

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
                : allTemplates.where((t) => t.key == category!.templateKey).toList();
            final templates = match.isEmpty ? const <HabitTemplate>[] : match.first.habits;
            // Custom habits already saved to this category (via "Add Custom
            // Habit" below, from a previous visit to this screen) — these
            // don't match any static template, so without this they'd never
            // show up here even though they already exist.
            final customHabits = category == null
                ? const <Habit>[]
                : activeHabits.where((h) => h.categoryId == category!.id && h.isCustom).toList();

            final displayIcon =
                category != null && isFinanceCategory(category) ? 'credit-card' : category?.icon;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lets the user hop between goal phrases without leaving
                // Step 2 (and without losing selections made under a
                // different one — see `_selectedTemplates`'s doc comment).
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final c = categories[index];
                      final isCurrent = c.id == _categoryId;
                      final chipColor = AppColors.categoryColorFromHex(c.colorHex, index);
                      return ChoiceChip(
                        label: Text(c.displayName(lang)),
                        selected: isCurrent,
                        onSelected: (_) async {
                          if (isCurrent) return;
                          // Save Money singleton: sama seperti tile Step 1,
                          // pindah ke kategori ini lewat chip switch juga
                          // harus langsung lompat ke form (skip Step 2)
                          // alih-alih menampilkan daftar template Finance.
                          if (isFinanceCategory(c)) {
                            if (!ref.read(isProProvider)) {
                              showProRequiredDialog(context, message: l10n.addHabitFinanceProOnly);
                              return;
                            }
                            final existing = _existingFinanceHabit();
                            if (existing != null) {
                              await _showSpendingMoneyExistsDialog(existing);
                              return;
                            }
                            final template = await _financeTemplate();
                            if (!mounted) return;
                            _openSpendingMoneyForm(c.id, template);
                            return;
                          }
                          setState(() => _categoryId = c.id);
                        },
                        selectedColor: chipColor.withValues(alpha: 0.18),
                        side: isCurrent ? BorderSide(color: chipColor) : BorderSide.none,
                        labelStyle: TextStyle(
                          color: isCurrent ? chipColor : theme.textTheme.bodySmall?.color,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
                        category?.displayName(lang) ?? '',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (templates.isEmpty && customHabits.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(l10n.addHabitNoRecommendations, style: theme.textTheme.bodySmall),
                  ),
                for (final h in customHabits)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 14),
                          HabitIcon(icon: h.icon, size: 20, color: theme.textTheme.bodySmall?.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h.displayName(lang), style: theme.textTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text(h.goalLabel(lang), style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.commonRemove,
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => _removeCreatedCustomHabit(h),
                          ),
                        ],
                      ),
                    ),
                  ),
                for (final t in templates)
                  Builder(builder: (context) {
                    final entry = (categoryId: _categoryId!, template: t);
                    final selected = _selectedTemplates.contains(entry);
                    final alreadyAdded = _templateAlreadyAdded(t, activeHabits);
                    return Opacity(
                      opacity: alreadyAdded ? 0.45 : 1,
                      child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: selected ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: selected
                            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: alreadyAdded
                            ? null
                            : () => setState(() {
                                  if (!_selectedTemplates.remove(entry)) _selectedTemplates.add(entry);
                                }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.displayName(lang), style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 2),
                                    Text(t.goalLabel(lang), style: theme.textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (alreadyAdded)
                                Text(l10n.addHabitAlreadyAdded, style: theme.textTheme.bodySmall)
                              else ...[
                                IconButton(
                                  tooltip: l10n.addHabitCustomizeBeforeAdding,
                                  icon: const Icon(Icons.tune_rounded, size: 20),
                                  onPressed: () => _openFormForTemplate(t),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selected ? theme.colorScheme.primary : Colors.transparent,
                                    border: Border.all(
                                      color: selected ? theme.colorScheme.primary : theme.dividerColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: selected
                                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      ),
                    );
                  }),
                const SizedBox(height: 4),
                DashedBorder(
                  borderRadius: 14,
                  onTap: () => _openCustomForm(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Text(l10n.addHabitAddCustomHabit, style: theme.textTheme.titleSmall),
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
        nameId: template.nameId,
        isCustom: false,
        templateKey: template.key,
        icon: template.icon,
        goalPeriod: template.goalPeriod,
        goalValue: template.goalValue,
        goalValueWeekend: template.goalValueWeekend,
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

  /// Creates every habit in [_selectedTemplates] at once (Step 2 multi-select
  /// — replaces the old "Add" pill that saved 1 template and immediately
  /// popped the screen). Entries can span more than 1 goal phrase (the chip
  /// row lets the user switch category without losing earlier picks), so
  /// each is created under its own `categoryId`, and the Finance Pro-gate is
  /// checked once per distinct category in the batch rather than just the
  /// one currently on screen. Free-tier gate is checked against the whole
  /// batch up front so it doesn't fail partway through and leave a mix of
  /// created/not-created habits.
  Future<void> _addSelectedTemplates() async {
    if (_selectedTemplates.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final entries = List<({int categoryId, HabitTemplate template})>.from(_selectedTemplates);
    for (final categoryId in entries.map((e) => e.categoryId).toSet()) {
      if (await _blockedByFinanceGate(categoryId)) return;
    }
    if (await _blockedByFreeHabitLimit(additional: entries.length)) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(habitRepositoryProvider);
      final startDate = today();
      // One batch insert instead of a create+read-back+notification-reschedule
      // loop per habit (previously ~1-2s per habit in a multi-select batch,
      // #29). No notification scheduling here either — every template habit
      // is created with reminderEnabled: false, so the per-habit
      // `_tryScheduleNotification` call was always just a no-op
      // cancel-then-return platform-channel round trip; safe to drop.
      await repo.createHabitsBatch([
        for (final entry in entries)
          HabitDraft(
            categoryId: entry.categoryId,
            name: entry.template.name,
            nameId: entry.template.nameId,
            isCustom: false,
            templateKey: entry.template.key,
            icon: entry.template.icon,
            goalPeriod: entry.template.goalPeriod,
            goalValue: entry.template.goalValue,
            goalValueWeekend: entry.template.goalValueWeekend,
            goalUnit: entry.template.goalUnit,
            goalDirection: entry.template.goalDirection,
            taskDays: const [allDaysKey],
            timeRange: entry.template.timeRange,
            reminderEnabled: false,
            startDate: startDate,
          ),
      ]);
      await _finishAndReturn(
        toastMessage: entries.length == 1
            ? l10n.addHabitAdded
            : l10n.addHabitAddedMultiple(entries.length),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.addHabitFailedToAdd('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _tryScheduleNotification(Habit habit) async {
    try {
      await ref
          .read(notificationServiceProvider)
          .rescheduleForHabit(habit, lang: ref.read(appLanguageProvider));
    } catch (_) {
      // Notification scheduling failed (e.g. platform not supported) —
      // don't fail the habit save because of this.
    }
  }

  // ---------------- Step 3: habit form ----------------

  /// Routes to the purpose-built Budget Tracker form when the current goal
  /// phrase is the Finance category, otherwise the normal habit form —
  /// [_buildStep3Normal] is left byte-for-byte as it was before the Budget
  /// Tracker rework, so normal-habit behavior can't regress from this split.
  Widget _buildStep3() {
    if (_categoryIdIsFinance(_categoryId)) return _buildStep3BudgetTracker();
    return _buildStep3Normal();
  }

  /// Purpose-built form for the Budget Tracker singleton habit — far fewer
  /// fields than the normal habit form (no name/icon/goal-phrase/target-
  /// direction/task-days/time-range/reminder), plus a Currency dropdown and
  /// a weekday/weekend budget split, per product requirements. Reuses the
  /// same underlying state as the normal form (`_goalPeriod`,
  /// `_goalValueController`/`_goalValue`, `_customWeekendGoal`,
  /// `_goalValueWeekendController`/`_goalValueWeekend`, `_submitHabitForm`)
  /// so both forms stay in sync with what actually gets saved.
  Widget _buildStep3BudgetTracker() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(l10n.budgetTrackerGoalPeriod),
        const SizedBox(height: 6),
        DropdownButtonFormField<GoalPeriod>(
          initialValue: _goalPeriod,
          items: [
            for (final period in GoalPeriod.values)
              DropdownMenuItem(value: period, child: Text(period.label(lang))),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _goalPeriod = v;
              if (v != GoalPeriod.daily) _customWeekendGoal = false;
            });
          },
        ),
        const SizedBox(height: 16),
        _FieldLabel(l10n.budgetTrackerCurrency),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _budgetTrackerCurrencies.contains(_currency) ? _currency : _budgetTrackerCurrencies.first,
          items: [
            for (final code in _budgetTrackerCurrencies) DropdownMenuItem(value: code, child: Text(code)),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _currency = v);
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(l10n.budgetTrackerDifferentWeekendGoal, style: theme.textTheme.bodyMedium),
            ),
            Switch(
              value: _customWeekendGoal,
              onChanged: (v) => setState(() => _customWeekendGoal = v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!_customWeekendGoal)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(l10n.budgetTrackerBudgetLabel),
              const SizedBox(height: 6),
              CurrencyAmountField(
                controller: _goalValueController,
                currencyPrefix: '$_currency ',
                onChanged: (v) => setState(() => _goalValue = v),
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(l10n.budgetTrackerWeekdayBudget),
                    const SizedBox(height: 6),
                    CurrencyAmountField(
                      controller: _goalValueController,
                      currencyPrefix: '$_currency ',
                      onChanged: (v) => setState(() => _goalValue = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(l10n.budgetTrackerWeekendBudget),
                    const SizedBox(height: 6),
                    CurrencyAmountField(
                      controller: _goalValueWeekendController,
                      currencyPrefix: '$_currency ',
                      onChanged: (v) => setState(() => _goalValueWeekend = v),
                    ),
                  ],
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
                  _FieldLabel(l10n.addHabitFieldStartDate),
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
                      _FieldLabel(l10n.addHabitFieldEndDate),
                      InkWell(
                        onTap: () => setState(() => _endDate = _endDate == null ? today() : null),
                        child: Text(
                          _endDate == null ? l10n.addHabitSetDate : l10n.addHabitNoLimit,
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
                      child: Text(l10n.addHabitNoTimeLimit, style: theme.textTheme.bodySmall),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saving ? null : _submitHabitForm,
          child: Text(_isEditing ? l10n.addHabitSaveChanges : l10n.budgetTrackerSaveBudget),
        ),
      ],
    );
  }

  static const List<String> _budgetTrackerCurrencies = ['IDR', 'USD', 'SGD', 'MYR', 'EUR'];

  Widget _buildStep3Normal() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final unitLabels = unitPresetLabelsFor(l10n);

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
        _FieldLabel(l10n.addHabitFieldHabitName),
        const SizedBox(height: 6),
        if (_isCustomDraft)
          TextField(
            controller: _nameController,
            enabled: !widget.lockGoalFields,
            decoration: InputDecoration(hintText: l10n.addHabitHintName),
          )
        else ...[
          InputDecorator(
            decoration: const InputDecoration(),
            child: Text(_lockedDisplayName(lang)),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.addHabitLockedNameNotice,
            style: theme.textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 16),
        _FieldLabel(l10n.addHabitFieldIcon),
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
              Text(l10n.addHabitChangeIcon, style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FieldLabel(l10n.addHabitFieldGoalPhrase),
        const SizedBox(height: 6),
        categoriesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, st) => Text('$e'),
          data: (categories) {
            final validId = categories.any((c) => c.id == _categoryId) ? _categoryId : null;
            return DropdownButtonFormField<int>(
              initialValue: validId,
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c.id, child: Text(c.displayName(lang))),
              ],
              onChanged: (v) async {
                if (v == null) return;
                // Save Money singleton: pindah ke Finance lewat dropdown ini
                // (bukan cuma dari tile Step 1) tetap harus dicegat kalau
                // user sudah punya habit Finance lain — supaya tidak bisa
                // diam-diam bikin habit Finance kedua lewat jalur ini.
                if (_categoryIdIsFinance(v) && !_categoryIdIsFinance(_categoryId)) {
                  final existing = _existingFinanceHabit(excludingId: widget.editingHabit?.id);
                  if (existing != null) {
                    await _showSpendingMoneyExistsDialog(existing);
                    return;
                  }
                }
                if (!mounted) return;
                setState(() {
                  _categoryId = v;
                  // Finance habits only ever take a nominal (rupiah) input,
                  // selalu batas maksimal (atMost) — kunci keduanya begitu
                  // goal phrase pindah ke Finance instead of leaving them
                  // user-editable (lihat juga lock di selector Target
                  // Direction/Unit dropdown Step 3).
                  if (_categoryIdIsFinance(v)) {
                    _applyUnit('rupiah');
                    _goalDirection = GoalDirection.atMost;
                    if (_goalValue < 1000) _setGoalValue(50000);
                  }
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),
        _FieldLabel(l10n.addHabitFieldGoalPeriod),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final period in GoalPeriod.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: period == GoalPeriod.values.last ? 0 : 8),
                  child: _SelectablePill(
                    label: period.label(lang),
                    selected: _goalPeriod == period,
                    onTap: () => setState(() {
                      _goalPeriod = period;
                      // Custom weekend goal cuma relevan untuk daily — reset
                      // begitu pindah ke weekly/monthly supaya goalValueWeekend
                      // tidak diam-diam ikut tersimpan untuk period lain.
                      if (period != GoalPeriod.daily) _customWeekendGoal = false;
                    }),
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
                  _FieldLabel(
                    _customWeekendGoal ? l10n.addHabitFieldGoalValueWeekday : l10n.addHabitFieldGoalValue,
                  ),
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
                  _FieldLabel(l10n.addHabitFieldUnit),
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
                        DropdownMenuItem(value: value, child: Text(unitLabels[value]!)),
                      DropdownMenuItem(value: 'custom', child: Text(unitLabels['custom']!)),
                    ],
                  ),
                  if (_unitDropdownValue == 'custom') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _goalUnitController,
                      decoration: InputDecoration(hintText: l10n.addHabitUnitHintCustom),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (_goalPeriod == GoalPeriod.daily) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(l10n.addHabitCustomWeekendGoalToggle, style: theme.textTheme.bodyMedium),
              ),
              Switch(
                value: _customWeekendGoal,
                onChanged: (v) => setState(() => _customWeekendGoal = v),
              ),
            ],
          ),
          if (_customWeekendGoal) ...[
            const SizedBox(height: 8),
            _FieldLabel(l10n.addHabitFieldGoalValueWeekend),
            const SizedBox(height: 6),
            Row(
              children: [
                _StepperButton(
                  icon: Icons.remove_rounded,
                  onTap: _goalValueWeekend > 0
                      ? () => setState(() => _setGoalValueWeekend(_goalValueWeekend - _goalValueStep))
                      : null,
                ),
                Expanded(
                  child: TextField(
                    controller: _goalValueWeekendController,
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
                      setState(() => _goalValueWeekend = parsed.clamp(0, 1 << 30));
                    },
                  ),
                ),
                _StepperButton(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _setGoalValueWeekend(_goalValueWeekend + _goalValueStep)),
                ),
              ],
            ),
          ],
        ],
        const SizedBox(height: 16),
        _FieldLabel(l10n.addHabitFieldTargetDirection),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final direction in GoalDirection.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: direction == GoalDirection.values.last ? 0 : 8),
                  child: _SelectablePill(
                    label: direction.label(lang),
                    selected: _goalDirection == direction,
                    // Selalu "Maks." (atMost) dan terkunci untuk kategori
                    // Finance/Save Money — habit ini murni pelacak batas
                    // pengeluaran, bukan target tabungan (lihat konteks plan).
                    onTap: _categoryIdIsFinance(_categoryId)
                        ? () {}
                        : () => setState(() => _goalDirection = direction),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(_goalDirection.helperText(lang), style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FieldLabel(l10n.addHabitFieldTaskDays),
            InkWell(
              onTap: () => setState(() => _taskDays = {allDaysKey}),
              child: Text(
                l10n.addHabitEveryDay,
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
          lang: lang,
          onChanged: (days) => setState(() => _taskDays = days),
        ),
        const SizedBox(height: 16),
        ], // end Column children (locked section)
          ), // end Column (locked section)
        ), // end _LockableSection
        const SizedBox(height: 16),
        // Time range stays editable even when the rest of the goal fields
        // are locked to a linked Community Group Habit — it's purely a local
        // "when do I usually do this" preference that never gets synced or
        // matched against the shared leaderboard target, so changing it
        // can't drift local tracking out of sync with the group (#10).
        _FieldLabel(l10n.addHabitFieldTimeRange),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tr in TimeRange.values)
              _SelectablePill(
                label: tr.label(lang),
                selected: _timeRange == tr,
                pill: true,
                onTap: () => setState(() => _timeRange = tr),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.addHabitReminder, style: theme.textTheme.bodyMedium),
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
        if (_reminderEnabled) ...[
          const SizedBox(height: 10),
          Text(l10n.addHabitReminderRepeat, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in const [null, 15, 30, 60, 120])
                _SelectablePill(
                  label: minutes == null
                      ? l10n.addHabitReminderOnce
                      : l10n.addHabitReminderEveryMinutes(minutes),
                  selected: _reminderIntervalMinutes == minutes,
                  pill: true,
                  onTap: () => setState(() => _reminderIntervalMinutes = minutes),
                ),
            ],
          ),
        ],
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
                  _FieldLabel(l10n.addHabitFieldStartDate),
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
                      _FieldLabel(l10n.addHabitFieldEndDate),
                      InkWell(
                        onTap: () => setState(() => _endDate = _endDate == null ? today() : null),
                        child: Text(
                          _endDate == null ? l10n.addHabitSetDate : l10n.addHabitNoLimit,
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
                      child: Text(l10n.addHabitNoTimeLimit, style: theme.textTheme.bodySmall),
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
          child: Text(_isEditing ? l10n.addHabitSaveChanges : l10n.addHabitSaveHabit),
        ),
      ],
    );
  }

  Future<void> _submitHabitForm() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    // Habit custom: satu input, `nameId` disimpan sama persis dengan `name`
    // (tidak ada terjemahan terpisah). Habit template (dikunci) tetap pakai
    // `_nameIdController` yang sudah di-prefill dari `habit.nameId` saat load.
    final nameId = _isCustomDraft ? name : _nameIdController.text.trim();
    if (name.isEmpty || nameId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addHabitNameRequired)),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addHabitPickGoalPhraseFirst)),
      );
      return;
    }
    if (_taskDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addHabitPickAtLeastOneDay)),
      );
      return;
    }
    final activeHabits = _activeHabitsExcludingPendingDelete();
    final normalizedName = name.toLowerCase();
    final normalizedNameId = nameId.toLowerCase();
    final isDuplicate = activeHabits.any((h) {
      if (widget.editingHabit != null && h.id == widget.editingHabit!.id) return false;
      final hName = h.name.trim().toLowerCase();
      final hNameId = h.nameId?.trim().toLowerCase();
      return hName == normalizedName || hNameId == normalizedNameId;
    });
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addHabitDuplicateName)),
      );
      return;
    }
    if (await _blockedByFinanceGate()) return;
    // Save Money singleton — race guard: cek ulang di titik submit (bukan
    // cuma di tile Step 1/dropdown goal phrase) sebelum benar-benar insert.
    if (_categoryIdIsFinance(_categoryId)) {
      final existingFinance = _existingFinanceHabit(excludingId: widget.editingHabit?.id);
      if (existingFinance != null) {
        await _showSpendingMoneyExistsDialog(existingFinance);
        return;
      }
    }
    if (!_isEditing && await _blockedByFreeHabitLimit()) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(habitRepositoryProvider);
      final goalUnit = _goalUnitController.text.trim().isEmpty ? 'x' : _goalUnitController.text.trim();
      final reminderTimeStr = _reminderEnabled ? _formatTime(_reminderTime) : null;
      final reminderIntervalValue = _reminderEnabled ? _reminderIntervalMinutes : null;
      final taskDaysList = _taskDays.contains(allDaysKey) ? [allDaysKey] : _taskDays.toList();

      if (_isEditing) {
        final updated = Habit(
          id: widget.editingHabit!.id,
          categoryId: _categoryId!,
          name: name,
          nameId: nameId,
          isCustom: _isCustomDraft,
          templateKey: _templateKeyDraft,
          description: widget.editingHabit!.description,
          icon: _habitIcon,
          goalPeriod: _goalPeriod,
          goalValue: _goalValue,
          goalValueWeekend: _customWeekendGoal ? _goalValueWeekend : null,
          goalUnit: goalUnit,
          goalDirection: _goalDirection,
          taskDays: taskDaysList,
          timeRange: _timeRange,
          reminderEnabled: _reminderEnabled,
          reminderTime: reminderTimeStr,
          reminderIntervalMinutes: reminderIntervalValue,
          startDate: _startDate,
          endDate: _endDate,
          isActive: widget.editingHabit!.isActive,
          sortOrder: widget.editingHabit!.sortOrder,
          createdAt: widget.editingHabit!.createdAt,
          currency: _categoryIdIsFinance(_categoryId) ? _currency : null,
        );
        await repo.updateHabit(updated);
        await _tryScheduleNotification(updated);
      } else {
        final id = await repo.createHabit(
          categoryId: _categoryId!,
          name: name,
          nameId: nameId,
          isCustom: _isCustomDraft,
          templateKey: _templateKeyDraft,
          icon: _habitIcon,
          goalPeriod: _goalPeriod,
          goalValue: _goalValue,
          goalValueWeekend: _customWeekendGoal ? _goalValueWeekend : null,
          goalUnit: goalUnit,
          goalDirection: _goalDirection,
          taskDays: taskDaysList,
          timeRange: _timeRange,
          reminderEnabled: _reminderEnabled,
          reminderTime: reminderTimeStr,
          reminderIntervalMinutes: reminderIntervalValue,
          startDate: _startDate,
          endDate: _endDate,
          currency: _categoryIdIsFinance(_categoryId) ? _currency : null,
        );
        final created = await repo.getById(id);
        if (created != null) {
          await _tryScheduleNotification(created);
        }
      }

      await _finishAndReturn(
        toastMessage: _isEditing ? l10n.addHabitUpdated : l10n.addHabitAdded,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.addHabitFailedToSave('$e'))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------- Step 4: new category ----------------

  Widget _buildStep4() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(l10n.addHabitFieldGoalPhraseName),
        const SizedBox(height: 6),
        TextField(
          controller: _newCatNameController,
          decoration: InputDecoration(hintText: l10n.addHabitHintCatName),
        ),
        const SizedBox(height: 20),
        _FieldLabel(l10n.addHabitFieldColor),
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
        _FieldLabel(l10n.addHabitFieldIcon),
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
                l10n.addHabitChangeIcon,
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
          child: Text(l10n.addHabitCreateGoal),
        ),
      ],
    );
  }

  Future<void> _submitNewCategory() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _newCatNameController.text.trim();
    // Goal phrase custom: satu input, `nameId` disimpan sama persis dengan
    // `name` (tidak ada terjemahan terpisah).
    final nameId = name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addHabitCatNameRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final colorHex =
          '#${AppColors.customCategoryColorPalette[_newCatColorIndex].toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      final id = await ref.read(categoryRepositoryProvider).createCustomCategory(
            name: name,
            nameId: nameId,
            icon: _newCatIcon,
            colorHex: colorHex,
          );

      if (widget.startAtNewCategory) {
        if (mounted) Navigator.of(context).pop(id);
        return;
      }
      setState(() {
        _categoryId = id;
        _stepStack = [1, 2];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.addHabitFailedToCreateCategory('$e'))));
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
    navigator.pop(true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toastMessage)));
    }
  }

  /// Deletes a custom habit shown as "already added" in Step 2 (see
  /// `customHabits` in `_buildStep2`) — unlike template habits, these aren't
  /// tracked by any local selection state, so removing one is just a direct
  /// DB delete + summary invalidation (`allActiveHabitsProvider` is a
  /// reactive stream, so the row disappears from Step 2 on its own once the
  /// delete lands).
  Future<void> _removeCreatedCustomHabit(Habit habit) async {
    try {
      await ref.read(notificationServiceProvider).cancelForHabit(habit.id);
    } catch (_) {
      // Notification cancellation failed (e.g. platform not supported) —
      // don't fail the habit deletion because of this.
    }
    await ref.read(habitRepositoryProvider).deleteHabit(habit.id);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);
    ref.invalidate(financeSummaryProvider);
    ref.invalidate(financeSummaryForPeriodProvider);
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
              AppLocalizations.of(context)!.addHabitCommunityLockedNotice,
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

/// Budget/amount input for the Budget Tracker form — no +/- stepper (unlike
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
  const _TaskDaysGrid({required this.selected, required this.lang, required this.onChanged});

  final Set<String> selected;
  final AppLang lang;
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
                  weekdayLabel(day, lang),
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
