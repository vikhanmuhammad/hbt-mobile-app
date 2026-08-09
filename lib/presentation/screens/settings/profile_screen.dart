import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/user_profile.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../widgets/app_logo.dart';

/// Edit the user's name & age profile. Profile photo (CLAUDE.md v3 §8) is
/// not yet implemented — marked "not available yet" following the
/// Export/Import pattern in Settings, to avoid adding a native picker
/// dependency outside this iteration's scope.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadFrom(UserProfile profile) {
    if (_loaded) return;
    _loaded = true;
    _nameController.text = profile.name;
    _ageController.text = profile.age?.toString() ?? '';
  }

  Future<void> _save(UserProfile current) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            UserProfile(
              id: current.id,
              name: name,
              age: int.tryParse(_ageController.text.trim()),
              photoPath: current.photoPath,
              themeKey: current.themeKey,
              createdAt: current.createdAt,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          _loadFrom(profile);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        const AppLogo(size: 64),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile photo is not available in this version yet')),
                          ),
                          child: const Text('Change photo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Name', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Your name')),
                  const SizedBox(height: 16),
                  Text('Age', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 25'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : () => _save(profile),
                    child: Text(_saving ? 'Saving...' : 'Save'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
