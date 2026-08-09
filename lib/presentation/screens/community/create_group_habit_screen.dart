import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/community_enums.dart';
import '../../../providers/community_providers.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/icon_picker_sheet.dart';

/// Form to create a new Group Habit — name, unit, icon, leaderboard method
/// (update_v2.md §11 point 5). Regular (non-admin) members can still create
/// a Group Habit (collaborative, §6).
class CreateGroupHabitScreen extends ConsumerStatefulWidget {
  const CreateGroupHabitScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<CreateGroupHabitScreen> createState() => _CreateGroupHabitScreenState();
}

class _CreateGroupHabitScreenState extends ConsumerState<CreateGroupHabitScreen> {
  final _nameController = TextEditingController();
  final _unitController = TextEditingController(text: 'x');
  String? _icon;
  LeaderboardMode _mode = LeaderboardMode.streak;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final picked = await showIconPickerSheet(context, currentIcon: _icon);
    if (picked != null) setState(() => _icon = picked);
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final uid = ref.read(currentUidProvider);
      if (uid == null) return;
      await ref.read(communityRepositoryProvider).createGroupHabit(
            groupId: widget.groupId,
            name: name,
            unit: _unitController.text.trim().isEmpty ? 'x' : _unitController.text.trim(),
            icon: _icon,
            leaderboardMode: _mode,
            createdBy: uid,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group Habit')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Challenge Name', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'e.g. 5K Run', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          Text('Progress Unit', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _unitController,
            decoration: const InputDecoration(hintText: 'e.g. km, minute, x', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          Text('Icon', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickIcon,
            icon: HabitIcon(icon: _icon, size: 18),
            label: Text(_icon ?? 'Choose icon'),
          ),
          const SizedBox(height: 20),
          Text('Leaderboard Method', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          SegmentedButton<LeaderboardMode>(
            segments: const [
              ButtonSegment(value: LeaderboardMode.streak, label: Text('Streak')),
              ButtonSegment(value: LeaderboardMode.progress, label: Text('Progress')),
              ButtonSegment(value: LeaderboardMode.both, label: Text('Both')),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _create,
            child: _saving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Group Habit'),
          ),
        ],
      ),
    );
  }
}
