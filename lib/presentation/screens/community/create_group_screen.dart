import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../services/avatar_image_service.dart';
import '../../widgets/animations/fade_slide_in.dart';
import 'group_detail_screen.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final uid = ref.read(currentUidProvider);
      final displayName = ref.read(currentDisplayNameProvider);
      if (uid == null) return;

      final localProfile = await ref.read(profileRepositoryProvider).getProfile();
      final photoBase64 =
          await AvatarImageService().thumbnailBase64FromFile(localProfile?.photoPath);

      final group = await ref.read(communityRepositoryProvider).createGroup(
            name: name,
            creatorUid: uid,
            creatorDisplayName: displayName,
            creatorPhotoBase64: photoBase64,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.createGroupFailed('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createGroupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.createGroupNameLabel, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.createGroupNameHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _create,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.createGroupTitle),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
