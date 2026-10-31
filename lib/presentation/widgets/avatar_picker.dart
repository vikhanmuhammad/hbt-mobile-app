import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/avatar_image_service.dart';
import 'user_avatar.dart';

/// A tappable `UserAvatar` with a small camera badge overlay — tapping it
/// opens a Camera/Gallery picker sheet, processes the result (crop, resize,
/// compress — see `AvatarImageService`), and reports it back via
/// [onPicked]. Used in both onboarding's personal-info step and Settings'
/// profile screen, so the pick-and-process flow lives in exactly one place.
class AvatarPicker extends StatefulWidget {
  const AvatarPicker({
    super.key,
    required this.photoPath,
    required this.displayName,
    required this.onPicked,
    this.size = 72,
  });

  final String? photoPath;
  final String displayName;
  final ValueChanged<ProcessedAvatar> onPicked;
  final double size;

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final _service = AvatarImageService();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final result = await _service.pickAndProcess(source: source);
      if (result != null) widget.onPicked(result);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSourceSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.avatarPickCamera),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.avatarPickGallery),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeSize = widget.size * 0.34;
    return GestureDetector(
      onTap: _busy ? null : _showSourceSheet,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(photoPath: widget.photoPath, displayName: widget.displayName, size: widget.size),
            if (_busy)
              Positioned.fill(
                child: ClipOval(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded, size: badgeSize * 0.55, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
