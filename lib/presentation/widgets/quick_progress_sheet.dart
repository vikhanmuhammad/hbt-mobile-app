import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/language.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/habit_with_progress.dart';
import '../../domain/models/spending_breakdown.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/settings_providers.dart';
import 'category_breakdown_list.dart';
import 'currency_amount_field.dart';
import 'segmented_pill_toggle.dart';

/// Result of the quick progress sheet: the new period-total value, plus any
/// spending-breakdown items the user built up the amount from this save
/// (see `_EntryModeToggle`/`_BreakdownEditor`) — empty when the user typed
/// the total directly instead.
class QuickProgressResult {
  const QuickProgressResult({required this.value, required this.breakdownItems});

  final int value;
  final List<SpendingBreakdownDraft> breakdownItems;
}

/// Quick progress input bottom sheet for habits with goalValue > 1 or a
/// unit — +/- stepper plus direct number input. For time-unit habits
/// (minute/hour) a timer is added so it can be run directly from the app —
/// but manual input is still available for activities done outside the
/// app. CLAUDE.md v3 §6.2. For a spending-limit habit (rupiah, `atMost`),
/// the user picks between typing the total directly or building it up from
/// categorized breakdown items — mutually exclusive, so the total being
/// saved is always exactly one or the other, never both.
Future<QuickProgressResult?> showQuickProgressSheet(BuildContext context, HabitWithProgress item) {
  return showModalBottomSheet<QuickProgressResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _QuickProgressSheet(item: item),
  );
}

class _QuickProgressSheetState extends ConsumerState<_QuickProgressSheet> {
  late int _value = widget.item.progressValue;
  late final _controller = TextEditingController(text: '$_value');
  final List<SpendingBreakdownDraft> _breakdownItems = [];

  /// Rincian yang sudah tersimpan untuk habit+tanggal ini dari sesi
  /// sebelumnya — dimuat di [initState] supaya tetap kelihatan saat sheet
  /// dibuka lagi, bukan seolah hilang padahal totalnya tetap terhitung.
  /// Read-only di sini (bukan bagian dari [_breakdownItems]/[_breakdownTotal]
  /// yang baru ditambahkan sesi ini) — total yang disimpan tetap dihitung
  /// sebagai delta di atas `widget.item.progressValue` seperti sebelumnya.
  List<SpendingBreakdownEntry> _existingBreakdownEntries = [];

  /// The draft auto-created (once per sheet session) when the user switches
  /// from "Enter total" to "Break down by category" while today's progress
  /// already has an un-categorized direct-entry amount — without this, that
  /// amount would keep counting toward the saved total (via
  /// `widget.item.progressValue`) while being invisible in the breakdown
  /// list/category totals, silently under-representing spending by category.
  /// Tracked by reference so it can be excluded from the total-being-saved
  /// again if the user deletes it from the list (see [_migratedAmountStillIncluded]).
  SpendingBreakdownDraft? _migratedItem;

  /// Which of the two mutually exclusive ways to log this save the user
  /// picked — only relevant when [_supportsBreakdown]. `false` = type the
  /// total directly (the stepper/text field, existing behavior). `true` =
  /// build the amount up from categorized items instead; the total is then
  /// *derived* as their sum, never entered separately, so there's no way
  /// for the breakdown to disagree with the total being saved.
  bool _useBreakdownMode = false;

  final _stopwatch = Stopwatch();
  Timer? _tickTimer;
  Duration _elapsed = Duration.zero;

  /// Only spending-limit habits (rupiah, `atMost`) get the choice between
  /// entering the total directly or building it up from breakdown items —
  /// a savings deposit or a plain counted habit has nothing meaningful to
  /// categorize.
  bool get _supportsBreakdown =>
      widget.item.habit.isRupiah && widget.item.habit.goalDirection == GoalDirection.atMost;

  /// Same predicate as [_supportsBreakdown] — every habit that supports the
  /// breakdown feature IS the Budget Tracker habit (the app's one rupiah +
  /// atMost habit), so this is where Budget-Tracker-only UI (no steppers,
  /// no Mark Achieved, thousand-separator input) gets gated.
  bool get _isBudgetTracker => _supportsBreakdown;

  int get _breakdownTotal => _breakdownItems.fold<int>(0, (sum, i) => sum + i.amount);

  /// [_migratedItem]'s amount if it's still in [_breakdownItems] (the user
  /// hasn't deleted it since), else 0 — see [_migrateDirectAmountIfNeeded].
  int get _migratedAmountStillIncluded {
    final migrated = _migratedItem;
    if (migrated == null) return 0;
    return _breakdownItems.any((i) => identical(i, migrated)) ? migrated.amount : 0;
  }

  /// Folds today's existing un-categorized direct-entry progress into the
  /// breakdown list as a single editable item, the moment the user switches
  /// into breakdown mode — runs at most once per sheet session. Skipped when
  /// [_existingBreakdownEntries] already has data, since in that case
  /// today's total is already (at least partly) categorized and guessing
  /// would risk double-counting instead of filling a real gap.
  void _migrateDirectAmountIfNeeded() {
    if (_migratedItem != null) return;
    if (_existingBreakdownEntries.isNotEmpty) return;
    final amount = widget.item.progressValue;
    if (amount <= 0) return;
    final lang = ref.read(appLanguageProvider);
    final draft = SpendingBreakdownDraft(
      category: SpendingBreakdownCategory.dailyNeeds,
      label: lang == AppLang.id ? 'Input sebelumnya (catat langsung)' : 'Previous direct entry',
      amount: amount,
    );
    _migratedItem = draft;
    _breakdownItems.add(draft);
  }

  /// True once there's any breakdown data at all — added this session or
  /// already persisted for the day — used to lock the entry mode to
  /// breakdown-only (req: disable "Enter Total" once breakdown data exists,
  /// to avoid the two ever disagreeing).
  bool get _hasAnyBreakdownData => _breakdownItems.isNotEmpty || _existingBreakdownEntries.isNotEmpty;

  bool get _isBreakdownEntry => _supportsBreakdown && (_useBreakdownMode || _hasAnyBreakdownData);

  /// In breakdown mode, at least one item must be added — an empty
  /// breakdown has nothing to add to today's total, so Save stays disabled
  /// instead of silently saving a zero delta.
  bool get _canSave => !_isBreakdownEntry || _breakdownItems.isNotEmpty;

  int get _step {
    final goal = widget.item.habit.goalValueFor(widget.item.date);
    if (widget.item.habit.isRupiah) {
      if (goal >= 100000) return 5000;
      if (goal >= 10000) return 1000;
      return 500;
    }
    if (goal >= 1000) return 100;
    if (goal >= 100) return 10;
    return 1;
  }

  bool get _isTimeUnit => const {'minute', 'hour'}.contains(widget.item.habit.goalUnit);

  int get _secondsPerUnit => widget.item.habit.goalUnit == 'hour' ? 3600 : 60;

  @override
  void initState() {
    super.initState();
    if (_supportsBreakdown) _loadExistingBreakdownEntries();
  }

  Future<void> _loadExistingBreakdownEntries() async {
    final entries = await ref
        .read(spendingBreakdownRepositoryProvider)
        .getEntriesForHabitAndDate(widget.item.habit.id, widget.item.date);
    if (mounted) setState(() => _existingBreakdownEntries = entries);
  }

  /// Opens the add/edit sheet pre-filled with [entry] and, on confirm,
  /// writes the change straight to the DB (unlike [_breakdownItems], which
  /// are only persisted when the whole quick-progress sheet is saved) then
  /// reloads so the list reflects it.
  Future<void> _editExistingEntry(SpendingBreakdownEntry entry) async {
    final draft = await showModalBottomSheet<SpendingBreakdownDraft>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddBreakdownItemSheet(
        currencyPrefix: widget.item.habit.currencyPrefix,
        initial: SpendingBreakdownDraft(category: entry.category, label: entry.label, amount: entry.amount),
      ),
    );
    if (draft == null || !mounted) return;
    await ref.read(spendingBreakdownRepositoryProvider).updateEntry(
          id: entry.id,
          category: draft.category,
          label: draft.label,
          amount: draft.amount,
        );
    await _loadExistingBreakdownEntries();
  }

  Future<void> _deleteExistingEntry(SpendingBreakdownEntry entry) async {
    await ref.read(spendingBreakdownRepositoryProvider).deleteEntry(entry.id);
    await _loadExistingBreakdownEntries();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Used by the stepper/"Mark Achieved" — syncs `_value` and the field
  /// text at once. Manual input from the user is handled separately via
  /// `TextField.onChanged` so the cursor doesn't jump while typing.
  void _setValue(int newValue) {
    final clamped = newValue.clamp(0, 1 << 30);
    setState(() => _value = clamped);
    _controller.text = '$clamped';
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  void _toggleTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _tickTimer?.cancel();
      setState(() {});
    } else {
      _stopwatch.start();
      _tickTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _elapsed = _stopwatch.elapsed),
      );
      setState(() {});
    }
  }

  /// Add the elapsed duration to progress (rounded to the nearest unit,
  /// minimum 1 if any time has elapsed) then reset the timer.
  void _commitTimer() {
    final elapsedSeconds = _stopwatch.elapsed.inSeconds;
    if (elapsedSeconds > 0) {
      final addedUnits = (elapsedSeconds / _secondsPerUnit).round().clamp(1, 1 << 30);
      _setValue(_value + addedUnits);
    }
    _stopwatch
      ..stop()
      ..reset();
    _tickTimer?.cancel();
    _tickTimer = null;
    setState(() => _elapsed = Duration.zero);
  }

  String get _elapsedLabel {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = _elapsed.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final habit = widget.item.habit;
    final unit = habit.isRupiah || habit.goalUnit == 'x' ? '' : habit.goalUnit;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habit.displayName(lang), style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            l10n.quickProgressTarget(habit.goalValueLabelForDate(widget.item.date)),
            style: theme.textTheme.bodySmall,
          ),
          if (_isTimeUnit) ...[
            const SizedBox(height: 20),
            _TimerCard(
              elapsedLabel: _elapsedLabel,
              running: _stopwatch.isRunning,
              hasElapsed: _elapsed > Duration.zero,
              onToggle: _toggleTimer,
              onCommit: _commitTimer,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: theme.dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    l10n.quickProgressOrEnterManually,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                Expanded(child: Divider(color: theme.dividerColor)),
              ],
            ),
          ],
          if (_supportsBreakdown) ...[
            const SizedBox(height: 16),
            if (_hasAnyBreakdownData)
              Text(
                l10n.spendingBreakdownDirectModeLockedHint,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
              )
            else
              _EntryModeToggle(
                useBreakdown: _useBreakdownMode,
                onChanged: (v) => setState(() {
                  _useBreakdownMode = v;
                  if (v) _migrateDirectAmountIfNeeded();
                }),
              ),
          ],
          const SizedBox(height: 20),
          if (!_isBreakdownEntry)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isBudgetTracker)
                  _StepButton(
                    icon: Icons.remove_rounded,
                    onTap: _value > 0 ? () => _setValue(_value - _step) : null,
                  ),
                if (!_isBudgetTracker) const SizedBox(width: 24),
                Column(
                  children: [
                    if (_isBudgetTracker)
                      CurrencyAmountField(
                        controller: _controller,
                        currencyPrefix: habit.currencyPrefix,
                        width: 220,
                        onChanged: (v) => setState(() => _value = v.clamp(0, 1 << 30)),
                      )
                    else
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: theme.textTheme.headlineMedium,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (text) {
                            final parsed = int.tryParse(text);
                            if (parsed != null) setState(() => _value = parsed.clamp(0, 1 << 30));
                          },
                        ),
                      ),
                    if (!_isBudgetTracker && unit.isNotEmpty)
                      Text(unit, style: theme.textTheme.bodySmall),
                  ],
                ),
                if (!_isBudgetTracker) const SizedBox(width: 24),
                if (!_isBudgetTracker)
                  _StepButton(
                    icon: Icons.add_rounded,
                    onTap: () => _setValue(_value + _step),
                  ),
              ],
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: SingleChildScrollView(
                child: _BreakdownEditor(
                  total: _breakdownTotal,
                  items: _breakdownItems,
                  existingEntries: _existingBreakdownEntries,
                  lang: lang,
                  currencyPrefix: habit.currencyPrefix,
                  onAdd: (draft) => setState(() => _breakdownItems.add(draft)),
                  onRemove: (index) => setState(() => _breakdownItems.removeAt(index)),
                  onEditExisting: _editExistingEntry,
                  onDeleteExisting: _deleteExistingEntry,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (!_isBreakdownEntry && !_isBudgetTracker) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _setValue(habit.goalValueFor(widget.item.date)),
                    child: Text(l10n.quickProgressMarkAchieved),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _canSave
                      ? () => Navigator.of(context).pop(
                            _isBreakdownEntry
                                ? QuickProgressResult(
                                    // Subtract back out the direct-entry
                                    // amount that got folded into
                                    // `_breakdownItems` (see
                                    // `_migrateDirectAmountIfNeeded`) — it's
                                    // now counted via `_breakdownTotal`
                                    // instead, so adding both would double it.
                                    value: widget.item.progressValue -
                                        _migratedAmountStillIncluded +
                                        _breakdownTotal,
                                    breakdownItems: _breakdownItems,
                                  )
                                : QuickProgressResult(value: _value, breakdownItems: const []),
                          )
                      : null,
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickProgressSheet extends ConsumerStatefulWidget {
  const _QuickProgressSheet({required this.item});

  final HabitWithProgress item;

  @override
  ConsumerState<_QuickProgressSheet> createState() => _QuickProgressSheetState();
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.elapsedLabel,
    required this.running,
    required this.hasElapsed,
    required this.onToggle,
    required this.onCommit,
  });

  final String elapsedLabel;
  final bool running;
  final bool hasElapsed;
  final VoidCallback onToggle;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            l10n.timerLabel,
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Text(elapsedLabel, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onToggle,
                icon: Icon(running ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
                label: Text(running ? l10n.timerPause : (hasElapsed ? l10n.timerResume : l10n.timerStart)),
              ),
              if (hasElapsed) ...[
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onCommit,
                  child: Text(l10n.commonAdd),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Segmented control choosing how this save's amount is determined — typed
/// directly, or built up from breakdown items — shown only for
/// spending-limit habits (`_QuickProgressSheetState._supportsBreakdown`).
class _EntryModeToggle extends StatelessWidget {
  const _EntryModeToggle({required this.useBreakdown, required this.onChanged});

  final bool useBreakdown;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedPillToggle<bool>(
      segments: [
        PillSegment(value: false, label: l10n.quickProgressEntryModeDirect),
        PillSegment(value: true, label: l10n.quickProgressEntryModeBreakdown),
      ],
      selected: useBreakdown,
      onChanged: onChanged,
    );
  }
}

/// Builds the amount being saved up from individually categorized items —
/// the total shown here is always the *sum* of [items] + already-persisted
/// [existingEntries], never a separately typed number, so it can never
/// disagree with what the breakdown actually adds up to
/// (#no-redundant-total). Already-persisted entries are editable/deletable
/// in place (writes straight to the DB via [onEditExisting]/
/// [onDeleteExisting]); this-session drafts are only removable from memory
/// via [onRemove] until the whole sheet is saved.
class _BreakdownEditor extends StatelessWidget {
  const _BreakdownEditor({
    required this.total,
    required this.items,
    required this.existingEntries,
    required this.lang,
    required this.currencyPrefix,
    required this.onAdd,
    required this.onRemove,
    required this.onEditExisting,
    required this.onDeleteExisting,
  });

  final int total;
  final List<SpendingBreakdownDraft> items;
  final List<SpendingBreakdownEntry> existingEntries;
  final AppLang lang;
  final String currencyPrefix;
  final ValueChanged<SpendingBreakdownDraft> onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<SpendingBreakdownEntry> onEditExisting;
  final ValueChanged<SpendingBreakdownEntry> onDeleteExisting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final combinedItems = <CategoryBreakdownItem>[
      for (final entry in existingEntries)
        CategoryBreakdownItem(category: entry.category, label: entry.label, amount: entry.amount, id: entry),
      for (var i = 0; i < items.length; i++)
        CategoryBreakdownItem(category: items[i].category, label: items[i].label, amount: items[i].amount, id: i),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (combinedItems.isNotEmpty) ...[
            CategoryBreakdownList(
              items: combinedItems,
              editable: true,
              currencyPrefix: currencyPrefix,
              onEdit: (item) async {
                final id = item.id;
                if (id is SpendingBreakdownEntry) {
                  onEditExisting(id);
                  return;
                }
                if (id is int) {
                  final updated = await showModalBottomSheet<SpendingBreakdownDraft>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => _AddBreakdownItemSheet(
                      currencyPrefix: currencyPrefix,
                      initial: items[id],
                    ),
                  );
                  if (updated != null) {
                    onRemove(id);
                    onAdd(updated);
                  }
                }
              },
              onDelete: (item) {
                final id = item.id;
                if (id is SpendingBreakdownEntry) {
                  onDeleteExisting(id);
                } else if (id is int) {
                  onRemove(id);
                }
              },
            ),
            const SizedBox(height: 14),
          ],
          OutlinedButton.icon(
            onPressed: () async {
              final draft = await showModalBottomSheet<SpendingBreakdownDraft>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _AddBreakdownItemSheet(currencyPrefix: currencyPrefix),
              );
              if (draft != null) onAdd(draft);
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n.spendingBreakdownAddItem),
          ),
        ],
      ),
    );
  }
}

/// Form to add (or edit, when [initial] is set) one breakdown item: pick a
/// category chip, enter an amount (no +/- stepper, live thousand-separator
/// formatting), and an optional free-text sub-category detail — shown after
/// any category is picked, not just one special "custom" bucket.
class _AddBreakdownItemSheet extends ConsumerStatefulWidget {
  const _AddBreakdownItemSheet({required this.currencyPrefix, this.initial});

  final String currencyPrefix;

  /// When set, pre-fills the form for editing an existing item instead of
  /// adding a new one (caption/button text stays the same either way; only
  /// the initial field values differ).
  final SpendingBreakdownDraft? initial;

  @override
  ConsumerState<_AddBreakdownItemSheet> createState() => _AddBreakdownItemSheetState();
}

class _AddBreakdownItemSheetState extends ConsumerState<_AddBreakdownItemSheet> {
  late SpendingBreakdownCategory _category = widget.initial?.category ?? SpendingBreakdownCategory.dailyNeeds;
  late int _amount = widget.initial?.amount ?? 0;
  late final _amountController = TextEditingController(
    text: _amount == 0 ? '' : NumberFormat.decimalPattern('id_ID').format(_amount),
  );
  late final _labelController = TextEditingController(text: widget.initial?.label ?? '');

  @override
  void dispose() {
    _amountController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final canSave = _amount > 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initial != null ? l10n.spendingBreakdownEditItem : l10n.spendingBreakdownAddItem,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in SpendingBreakdownCategory.values)
                ChoiceChip(
                  label: Text(category.label(lang)),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          if (_category.hint(lang) != null) ...[
            const SizedBox(height: 6),
            Text(_category.hint(lang)!, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 20),
          Center(
            child: CurrencyAmountField(
              controller: _amountController,
              currencyPrefix: widget.currencyPrefix,
              width: 220,
              onChanged: (v) => setState(() => _amount = v),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(labelText: l10n.spendingBreakdownSubcategoryHint),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSave
                  ? () => Navigator.of(context).pop(
                        SpendingBreakdownDraft(
                          category: _category,
                          label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
                          amount: _amount,
                        ),
                      )
                  : null,
              child: Text(l10n.commonAdd),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      shape: CircleBorder(side: BorderSide(color: theme.dividerColor)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 48, height: 48, child: Icon(icon, size: 22)),
      ),
    );
  }
}
