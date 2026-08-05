import 'package:flutter/material.dart';

import '../../domain/models/habit_with_progress.dart';

/// Bottom sheet input progress cepat untuk habit dengan goalValue > 1 atau
/// bersatuan — stepper +/- plus input angka langsung. CLAUDE.md v3 §6.2.
Future<int?> showQuickProgressSheet(BuildContext context, HabitWithProgress item) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _QuickProgressSheet(item: item),
  );
}

class _QuickProgressSheet extends StatefulWidget {
  const _QuickProgressSheet({required this.item});

  final HabitWithProgress item;

  @override
  State<_QuickProgressSheet> createState() => _QuickProgressSheetState();
}

class _QuickProgressSheetState extends State<_QuickProgressSheet> {
  late int _value = widget.item.progressValue;
  late final _controller = TextEditingController(text: '$_value');

  int get _step {
    final goal = widget.item.habit.goalValue;
    if (goal >= 1000) return 100;
    if (goal >= 100) return 10;
    return 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Dipakai oleh stepper/"Tandai Tercapai" — sinkronkan `_value` dan teks
  /// field sekaligus. Input manual dari user ditangani terpisah lewat
  /// `TextField.onChanged` supaya kursor tidak lompat saat mengetik.
  void _setValue(int newValue) {
    final clamped = newValue.clamp(0, 1 << 30);
    setState(() => _value = clamped);
    _controller.text = '$clamped';
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = widget.item.habit;
    final unit = habit.goalUnit == 'x' ? '' : habit.goalUnit;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habit.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Target: ${habit.goalValueLabel}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
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
                  if (unit.isNotEmpty) Text(unit, style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(width: 24),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: () => _setValue(_value + _step),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _setValue(habit.goalValue),
                  child: const Text('Tandai Tercapai'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_value),
                  child: const Text('Simpan'),
                ),
              ),
            ],
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
