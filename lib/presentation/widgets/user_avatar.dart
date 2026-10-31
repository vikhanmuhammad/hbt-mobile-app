import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular profile photo, used everywhere a user's picture can appear:
/// onboarding's personal-info step, Settings, and Community (member list,
/// leaderboard, chat). Renders, in priority order: a local file (fastest,
/// used for the signed-in user's own profile), a base64 thumbnail (used for
/// other Community members, synced via Firestore since the app has no
/// Firebase Storage on the Spark plan), or — with neither — a colored
/// circle with the name's first letter, deterministic per name so the same
/// person always gets the same fallback color.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.photoPath,
    this.photoBase64,
    required this.displayName,
    this.size = 40,
  });

  final String? photoPath;
  final String? photoBase64;
  final String displayName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final file = photoPath == null ? null : File(photoPath!);
    if (file != null && file.existsSync()) {
      return _circle(child: Image.file(file, fit: BoxFit.cover, width: size, height: size));
    }
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(photoBase64!);
        return _circle(child: Image.memory(bytes, fit: BoxFit.cover, width: size, height: size));
      } catch (_) {
        // Falls through to the initials avatar below on decode failure.
      }
    }
    return _initialsAvatar();
  }

  Widget _circle({required Widget child}) {
    return ClipOval(child: SizedBox(width: size, height: size, child: child));
  }

  Widget _initialsAvatar() {
    final trimmed = displayName.trim();
    final letter = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    final color = AppColors.categoryPalette[trimmed.hashCode.abs() % AppColors.categoryPalette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
