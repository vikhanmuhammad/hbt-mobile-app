import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/community_providers.dart';

/// Full-screen teaser for features entirely gated behind Pro (Community,
/// Finance) — different from [showProRequiredDialog], which only blocks 1
/// specific action (e.g. picking the Finance category, adding the 6th habit).
/// Shows a blurred preview of what the unlocked feature looks like behind a
/// frosted overlay, a short benefits list, and an "Upgrade to Pro" button.
/// Real Play Store/App Store billing isn't wired up yet — the button just
/// flips the local entitlement flag (see `EntitlementService`) — but no
/// user-facing copy should say so; that's an internal implementation detail.
class ProFeatureTeaser extends ConsumerWidget {
  const ProFeatureTeaser({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.benefits,
    this.previewBuilder,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> benefits;

  /// Optional builder for a mock preview of the unlocked screen, rendered
  /// blurred behind the teaser card so the user gets a sense of what they'd
  /// unlock. Falls back to a plain icon backdrop when omitted.
  final WidgetBuilder? previewBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: previewBuilder?.call(context) ??
                Center(child: Icon(icon, size: 160, color: theme.colorScheme.primary.withValues(alpha: 0.15))),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: theme.scaffoldBackgroundColor.withValues(alpha: 0.35)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 34, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 20),
                        Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        Text(description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final benefit in benefits)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 18, color: theme.colorScheme.primary),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(benefit, style: theme.textTheme.bodyMedium)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _upgrade(context, ref),
                            child: const Text('Upgrade to Pro'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _upgrade(BuildContext context, WidgetRef ref) async {
    ref.read(isProProvider.notifier).setPro(true);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pro unlocked — welcome aboard!')),
      );
    }
  }
}

/// Generic paywall dialog for 1 specific action gated behind Pro (not the
/// whole screen) — e.g. picking the Finance category or exceeding the
/// 5-active-habit limit for Free.
Future<void> showProRequiredDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pro Feature'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
