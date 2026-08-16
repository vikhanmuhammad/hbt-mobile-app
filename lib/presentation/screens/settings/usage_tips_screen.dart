import 'package:flutter/material.dart';

import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';

/// Quick tips for using the app — reminders, backfilling progress, changing
/// the theme, using Edit Mode. CLAUDE.md v3 §8.
class UsageTipsScreen extends StatelessWidget {
  const UsageTipsScreen({super.key});

  static const _tips = [
    (
      icon: Icons.notifications_active_rounded,
      title: 'Use Reminders',
      body: 'When adding or editing a habit, turn on the Reminder toggle and set a time. '
          'The app will send a local notification at that time on the habit\'s active days.',
    ),
    (
      icon: Icons.edit_calendar_rounded,
      title: 'Backfill Progress',
      body: 'From the Dashboard tab, tap a past date on the calendar to see that day\'s habit detail. '
          'You can still mark/change progress for previous days from there.',
    ),
    (
      icon: Icons.palette_rounded,
      title: 'Change Theme',
      body: 'Open Settings > Personalize to pick one of 5 color palettes. '
          'The change applies instantly throughout the app.',
    ),
    (
      icon: Icons.edit_rounded,
      title: 'Use Edit Mode',
      body: 'Tap the pencil button at the bottom right of Home to enter Edit Mode — from there you '
          'can reorder (drag), edit, or deactivate habits. Tap the '
          'check button or "Done" to exit.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Usage Tips')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: FadeSlideIn(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final (index, tip) in _tips.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FadeSlideIn(
                    delay: staggeredDelay(index),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(tip.icon, color: theme.colorScheme.primary),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tip.title, style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 6),
                                  Text(
                                    tip.body,
                                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
