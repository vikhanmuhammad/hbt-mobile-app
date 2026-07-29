import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/date_utils.dart';
import '../../domain/models/category.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/habit.dart';
import '../../providers/category_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/stats_providers.dart';

class HabitFormPrefill {
  const HabitFormPrefill({
    required this.name,
    required this.goalPeriod,
    required this.goalValue,
    required this.timeRange,
  });

  final String name;
  final GoalPeriod goalPeriod;
  final int goalValue;
  final TimeRange timeRange;
}

/// Form lengkap: nama, kategori, goal period/value, task days, time range,
/// reminder, start/end date. Dipakai sama untuk create & edit (DESIGN.md §5).
Future<bool?> showHabitFormSheet(
  BuildContext context, {
  required int initialCategoryId,
  HabitFormPrefill? prefill,
  Habit? editingHabit,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _HabitFormSheet(
      initialCategoryId: initialCategoryId,
      prefill: prefill,
      editingHabit: editingHabit,
    ),
  );
}

class _HabitFormSheet extends ConsumerStatefulWidget {
  const _HabitFormSheet({
    required this.initialCategoryId,
    this.prefill,
    this.editingHabit,
  });

  final int initialCategoryId;
  final HabitFormPrefill? prefill;
  final Habit? editingHabit;

  @override
  ConsumerState<_HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends ConsumerState<_HabitFormSheet> {
  late final TextEditingController _nameController;
  late int _categoryId;
  late GoalPeriod _goalPeriod;
  late int _goalValue;
  late Set<String> _taskDays;
  late TimeRange _timeRange;
  late bool _reminderEnabled;
  TimeOfDay? _reminderTime;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _saving = false;

  bool get _isEditing => widget.editingHabit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.editingHabit;
    final prefill = widget.prefill;

    _nameController = TextEditingController(text: habit?.name ?? prefill?.name ?? '');
    _categoryId = habit?.categoryId ?? widget.initialCategoryId;
    _goalPeriod = habit?.goalPeriod ?? prefill?.goalPeriod ?? GoalPeriod.daily;
    _goalValue = habit?.goalValue ?? prefill?.goalValue ?? 1;
    _taskDays = (habit?.taskDays ?? const [allDaysKey]).toSet();
    _timeRange = habit?.timeRange ?? prefill?.timeRange ?? TimeRange.anytime;
    _reminderEnabled = habit?.reminderEnabled ?? false;
    _reminderTime = _parseTime(habit?.reminderTime);
    _startDate = habit?.startDate ?? today();
    _endDate = habit?.endDate;
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'Edit Habit' : 'Habit Baru',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text('Nama habit', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Mis. Minum air putih'),
              ),
              const SizedBox(height: 20),
              Text('Kategori', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) => _CategoryDropdown(
                  categories: categories,
                  value: _categoryId,
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Gagal memuat kategori: $e'),
              ),
              const SizedBox(height: 20),
              Text('Goal Period', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<GoalPeriod>(
                segments: const [
                  ButtonSegment(value: GoalPeriod.daily, label: Text('Harian')),
                  ButtonSegment(value: GoalPeriod.weekly, label: Text('Mingguan')),
                  ButtonSegment(value: GoalPeriod.monthly, label: Text('Bulanan')),
                ],
                selected: {_goalPeriod},
                onSelectionChanged: (s) => setState(() => _goalPeriod = s.first),
              ),
              const SizedBox(height: 20),
              Text('Goal Value', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              _GoalValueStepper(
                value: _goalValue,
                unitLabel: _goalPeriod.unitLabel,
                onChanged: (v) => setState(() => _goalValue = v),
              ),
              const SizedBox(height: 20),
              Text('Task Days', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              _TaskDaysPicker(
                selected: _taskDays,
                onChanged: (days) => setState(() => _taskDays = days),
              ),
              const SizedBox(height: 20),
              Text('Time Range', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tr in TimeRange.values)
                    ChoiceChip(
                      label: Text(tr.label),
                      selected: _timeRange == tr,
                      onSelected: (_) => setState(() => _timeRange = tr),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reminder'),
                subtitle: Text(_reminderTime == null
                    ? 'Notifikasi lokal harian'
                    : 'Jam ${_formatTime(_reminderTime!)}'),
                value: _reminderEnabled,
                onChanged: (v) async {
                  if (v && _reminderTime == null) {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (picked == null) return;
                    setState(() {
                      _reminderTime = picked;
                      _reminderEnabled = true;
                    });
                    return;
                  }
                  setState(() => _reminderEnabled = v);
                },
              ),
              if (_reminderEnabled)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) setState(() => _reminderTime = picked);
                    },
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text('Ubah jam (${_formatTime(_reminderTime!)})'),
                  ),
                ),
              const SizedBox(height: 12),
              Text('Habit Term', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              _DateRow(
                label: 'Mulai',
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
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanpa batas waktu'),
                value: _endDate == null,
                onChanged: (v) => setState(() => _endDate = v ? null : today()),
              ),
              if (_endDate != null)
                _DateRow(
                  label: 'Selesai',
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
                ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Habit'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nama habit wajib diisi')));
      return;
    }
    if (_taskDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih minimal 1 hari aktif')));
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(habitRepositoryProvider);
    final reminderTimeStr = _reminderTime == null ? null : _formatTime(_reminderTime!);
    final taskDaysList = _taskDays.contains(allDaysKey)
        ? [allDaysKey]
        : _taskDays.toList();

    if (_isEditing) {
      final updated = Habit(
        id: widget.editingHabit!.id,
        categoryId: _categoryId,
        name: name,
        description: widget.editingHabit!.description,
        goalPeriod: _goalPeriod,
        goalValue: _goalValue,
        taskDays: taskDaysList,
        timeRange: _timeRange,
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTimeStr,
        startDate: _startDate,
        endDate: _endDate,
        isActive: widget.editingHabit!.isActive,
        createdAt: widget.editingHabit!.createdAt,
      );
      await repo.updateHabit(updated);
      await ref.read(notificationServiceProvider).rescheduleForHabit(updated);
    } else {
      final id = await repo.createHabit(
        categoryId: _categoryId,
        name: name,
        goalPeriod: _goalPeriod,
        goalValue: _goalValue,
        taskDays: taskDaysList,
        timeRange: _timeRange,
        reminderEnabled: _reminderEnabled,
        reminderTime: reminderTimeStr,
        startDate: _startDate,
        endDate: _endDate,
      );
      final created = await repo.getById(id);
      if (created != null) {
        await ref.read(notificationServiceProvider).rescheduleForHabit(created);
      }
    }

    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(daySummaryProvider);

    if (mounted) Navigator.of(context).pop(true);
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<Category> categories;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final validValue =
        categories.any((c) => c.id == value) ? value : null;
    return DropdownButtonFormField<int>(
      initialValue: validValue,
      items: [
        for (final c in categories)
          DropdownMenuItem(value: c.id, child: Text(c.name)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _GoalValueStepper extends StatelessWidget {
  const _GoalValueStepper({
    required this.value,
    required this.unitLabel,
    required this.onChanged,
  });

  final int value;
  final String unitLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        Expanded(
          child: Center(
            child: Text('$value x / $unitLabel',
                style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _TaskDaysPicker extends StatelessWidget {
  const _TaskDaysPicker({required this.selected, required this.onChanged});

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  bool get _isEveryDay => selected.contains(allDaysKey);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterChip(
          label: const Text('Setiap hari'),
          selected: _isEveryDay,
          onSelected: (v) => onChanged(v ? {allDaysKey} : {}),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final day in weekdayKeys)
              ChoiceChip(
                label: Text(weekdayLabels[day]!),
                selected: !_isEveryDay && selected.contains(day),
                onSelected: (v) {
                  final next = Set<String>.from(selected)..remove(allDaysKey);
                  if (v) {
                    next.add(day);
                  } else {
                    next.remove(day);
                  }
                  onChanged(next);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: [
                Text(formatted),
                const SizedBox(width: 6),
                const Icon(Icons.calendar_today_rounded, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
