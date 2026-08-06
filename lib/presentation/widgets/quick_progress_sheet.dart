import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/format_utils.dart';
import '../../domain/models/habit_with_progress.dart';

/// Bottom sheet input progress cepat untuk habit dengan goalValue > 1 atau
/// bersatuan — stepper +/- plus input angka langsung. Untuk habit bersatuan
/// waktu (menit/jam) ditambah timer supaya bisa dijalankan langsung dari app
/// — tapi input manual tetap tersedia untuk aktivitas yang dilakukan di luar
/// app. CLAUDE.md v3 §6.2.
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

class _QuickProgressSheetState extends State<_QuickProgressSheet> {
  late int _value = widget.item.progressValue;
  late final _controller = TextEditingController(text: '$_value');

  final _stopwatch = Stopwatch();
  Timer? _tickTimer;
  Duration _elapsed = Duration.zero;

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

  bool get _isTimeUnit => const {'menit', 'jam'}.contains(widget.item.habit.goalUnit);

  int get _secondsPerUnit => widget.item.habit.goalUnit == 'jam' ? 3600 : 60;

  @override
  void dispose() {
    _tickTimer?.cancel();
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

  /// Tambahkan durasi yang sudah berjalan ke progress (dibulatkan ke satuan
  /// terdekat, minimal 1 kalau ada waktu yang berjalan) lalu reset timer.
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
    final habit = widget.item.habit;
    final unit = habit.isRupiah || habit.goalUnit == 'x' ? '' : habit.goalUnit;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habit.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Target: ${habit.goalValueLabel}', style: theme.textTheme.bodySmall),
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
                    'atau input manual',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                Expanded(child: Divider(color: theme.dividerColor)),
              ],
            ),
          ],
          const SizedBox(height: 20),
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

class _QuickProgressSheet extends StatefulWidget {
  const _QuickProgressSheet({required this.item});

  final HabitWithProgress item;

  @override
  State<_QuickProgressSheet> createState() => _QuickProgressSheetState();
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
            'TIMER',
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
                label: Text(running ? 'Jeda' : (hasElapsed ? 'Lanjut' : 'Mulai')),
              ),
              if (hasElapsed) ...[
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onCommit,
                  child: const Text('Tambahkan'),
                ),
              ],
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
