import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/language.dart';
import '../../../domain/models/onboarding_question.dart';
import '../../../domain/models/user_profile.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/settings_providers.dart';
import '../../../services/avatar_image_service.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/avatar_picker.dart';

/// Edit the user's name, age, gender & profile photo. Photo picking/
/// processing lives in `AvatarImageService`/`AvatarPicker` (base64 inline
/// in Firestore, not Firebase Storage — the project is on the Spark plan).
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
  // Gender still lives in SettingsRepository/SharedPreferences (same as
  // where onboarding wrote it), not on UserProfile itself — surfaced here
  // and made editable per #22 without needing a DB schema migration.
  Gender? _gender;

  @override
  void initState() {
    super.initState();
    _gender = Gender.fromValue(ref.read(settingsRepositoryProvider).gender);
  }

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

  Future<void> _onPhotoPicked(ProcessedAvatar avatar, UserProfile current) async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(profileRepositoryProvider).updateProfile(
          UserProfile(
            id: current.id,
            name: current.name,
            age: current.age,
            photoPath: avatar.localFile.path,
            themeKey: current.themeKey,
            createdAt: current.createdAt,
          ),
        );
    final uid = ref.read(currentUidProvider);
    if (uid != null) {
      try {
        await ref.read(communityRepositoryProvider).updateMyPhotoAcrossGroups(
              uid: uid,
              photoBase64: avatar.base64Thumbnail,
            );
      } catch (e) {
        // Local photo already saved above — don't lose that success message
        // over a Community sync failure, but surface it distinctly instead
        // of failing silently (this previously had no error handling at
        // all, making a sync failure indistinguishable from success).
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.profilePhotoCommunitySyncFailed('$e'))),
          );
        }
        return;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    }
  }

  Future<void> _save(UserProfile current) async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileNameEmpty)));
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
      final gender = _gender;
      if (gender != null) {
        await ref.read(settingsRepositoryProvider).setGender(gender.name);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = ref.watch(appLanguageProvider);
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          _loadFrom(profile);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: FadeSlideIn(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        AvatarPicker(
                          photoPath: profile.photoPath,
                          displayName: profile.name,
                          size: 72,
                          onPicked: (avatar) => _onPhotoPicked(avatar, profile),
                        ),
                        const SizedBox(height: 10),
                        Text(l10n.profileChangePhoto, style: theme.textTheme.labelMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.profileNameLabel, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: l10n.profileNameHint),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.profileAgeLabel, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: l10n.profileAgeHint),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.genderLabel, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  DropdownMenu<Gender>(
                    initialSelection: _gender,
                    hintText: l10n.genderHint,
                    expandedInsets: EdgeInsets.zero,
                    // Match the Name/Age fields' fill/border above — see the
                    // same fix's comment in onboarding_flow.dart.
                    inputDecorationTheme: theme.inputDecorationTheme,
                    onSelected: (value) => setState(() => _gender = value),
                    dropdownMenuEntries: [
                      for (final g in Gender.values)
                        DropdownMenuEntry(value: g, label: g.label(lang == AppLang.id)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : () => _save(profile),
                    child: Text(_saving ? l10n.profileSaving : l10n.profileSave),
                  ),
                ],
              ),
              ),
            ),
          );
        },
      ),
    );
  }
}
