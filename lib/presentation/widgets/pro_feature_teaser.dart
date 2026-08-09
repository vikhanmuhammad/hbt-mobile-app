import 'package:flutter/material.dart';

/// Full-screen teaser for features entirely gated behind Pro (Community,
/// Finance) — different from [showProRequiredDialog], which only blocks 1
/// specific action (e.g. picking the Finance category, adding the 6th habit).
class ProFeatureTeaser extends StatelessWidget {
  const ProFeatureTeaser({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Text(
                'Real Pro purchase integration isn\'t available yet — enable it via '
                'the "Pro Mode (Debug)" toggle in Settings to try this feature.',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          Text(
            'Real Pro purchase integration isn\'t available yet — enable it via '
            'the "Pro Mode (Debug)" toggle in Settings to try this feature.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
