import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/format_utils.dart';
import '../../domain/language.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/habit_with_progress.dart';
import '../../domain/models/spending_breakdown.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/settings_providers.dart';
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

  int get _breakdownTotal => _breakdownItems.fold<int>(0, (sum, i) => sum + i.amount);

  bool get _isBreakdownEntry => _supportsBreakdown && _useBreakdownMode;

  /// In breakdown mode, at least one item must be added — an empty
  /// breakdown has nothing to add to today's total, so Save stays disabled
  /// instead of silently saving a zero delta.
  bool get _canSave => !_isBreakdownEntry || _breakdownItems.isNotEmpty;

  int get _step {
    final goal = widget.item.habit.goalValue;
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
          Text(l10n.quickProgressTarget(habit.goalValueLabel), style: theme.textTheme.bodySmall),
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
            _EntryModeToggle(
              useBreakdown: _useBreakdownMode,
              onChanged: (v) => setState(() => _useBreakdownMode = v),
            ),
          ],
          const SizedBox(height: 20),
          if (!_isBreakdownEntry)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepButton(
                  icon: Icons.remove_rounded,
                  onTap: _value > 0 ? () => _setValue(_value - _step) : null,
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    SizedBox(
                      width: habit.isRupiah ? 140 : 90,
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.headlineMedium,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          prefixText: habit.isRupiah ? 'Rp ' : null,
                        ),
                        onChanged: (text) {
                          final parsed = int.tryParse(text);
                          if (parsed != null) setState(() => _value = parsed.clamp(0, 1 << 30));
                        },
                      ),
                    ),
                    if (habit.isRupiah)
                      Text(formatRupiah(_value), style: theme.textTheme.bodySmall)
                    else if (unit.isNotEmpty)
                      Text(unit, style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(width: 24),
                _StepButton(
                  icon: Icons.add_rounded,
                  onTap: () => _setValue(_value + _step),
                ),
              ],
            )
          else
            _BreakdownEditor(
              total: _breakdownTotal,
              items: _breakdownItems,
              lang: lang,
              onAdd: (draft) => setState(() => _breakdownItems.add(draft)),
              onRemove: (index) => setState(() => _breakdownItems.removeAt(index)),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (!_isBreakdownEntry) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _setValue(habit.goalValue),
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
                                    value: widget.item.progressValue + _breakdownTotal,
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
/// the total shown here is always the *sum* of [items], never a separately
/// typed number, so it can never disagree with what the breakdown actually
/// adds up to (#no-redundant-total).
class _BreakdownEditor extends StatelessWidget {
  const _BreakdownEditor({
    required this.total,
    required this.items,
    required this.lang,
    required this.onAdd,
    required this.onRemove,
  });

  final int total;
  final List<SpendingBreakdownDraft> items;
  final AppLang lang;
  final ValueChanged<SpendingBreakdownDraft> onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _BreakdownItemRow(
                draft: items[i],
                lang: lang,
                onRemove: () => onRemove(i),
              ),
            ),
          if (items.isNotEmpty) ...[
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.spendingBreakdownTotalLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  formatRupiah(total),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
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
                builder: (context) => const _AddBreakdownItemSheet(),
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

class _BreakdownItemRow extends StatelessWidget {
  const _BreakdownItemRow({required this.draft, required this.lang, required this.onRemove});

  final SpendingBreakdownDraft draft;
  final AppLang lang;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryLabel = draft.category.label(lang);
    final displayLabel = draft.category == SpendingBreakdownCategory.custom &&
            draft.label != null &&
            draft.label!.isNotEmpty
        ? draft.label!
        : categoryLabel;
    return Row(
      children: [
        Expanded(
          child: Text(
            displayLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(formatRupiah(draft.amount), style: theme.textTheme.bodyMedium),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded, size: 18),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

/// Small form to add one breakdown item: pick a category chip, enter an
/// amount, and (only for `custom`) a free-text label.
class _AddBreakdownItemSheet extends ConsumerStatefulWidget {
  const _AddBreakdownItemSheet();

  @override
  ConsumerState<_AddBreakdownItemSheet> createState() => _AddBreakdownItemSheetState();
}

class _AddBreakdownItemSheetState extends ConsumerState<_AddBreakdownItemSheet> {
  static const _step = 1000;

  SpendingBreakdownCategory _category = SpendingBreakdownCategory.dailyNeeds;
  int _amount = 0;
  late final _amountController = TextEditingController(text: '$_amount');
  final _labelController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  /// Mirrors `_QuickProgressSheetState._setValue` — used by the +/- stepper
  /// so the field text and [_amount] stay in sync; manual typing is handled
  /// separately via `TextField.onChanged` so the cursor doesn't jump.
  void _setAmount(int newAmount) {
    final clamped = newAmount.clamp(0, 1 << 30);
    setState(() => _amount = clamped);
    _amountController.text = '$clamped';
    _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final isCustom = _category == SpendingBreakdownCategory.custom;
    final canSave = _amount > 0 && (!isCustom || _labelController.text.trim().isNotEmpty);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.spendingBreakdownAddItem, style: theme.textTheme.titleLarge),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: _amount > 0 ? () => _setAmount(_amount - _step) : null,
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.headlineMedium,
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    prefixText: 'Rp ',
                  ),
                  onChanged: (text) {
                    final parsed = int.tryParse(text);
                    if (parsed != null) setState(() => _amount = parsed.clamp(0, 1 << 30));
                  },
                ),
              ),
              const SizedBox(width: 24),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: () => _setAmount(_amount + _step),
              ),
            ],
          ),
          if (isCustom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(labelText: l10n.spendingBreakdownCustomLabelHint),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSave
                  ? () => Navigator.of(context).pop(
                        SpendingBreakdownDraft(
                          category: _category,
                          label: isCustom ? _labelController.text.trim() : null,
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
