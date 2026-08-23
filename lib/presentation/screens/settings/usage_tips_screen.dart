import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';

/// Quick tips for using the app — reminders, backfilling progress, changing
/// the theme, using Edit Mode. CLAUDE.md v3 §8.
class UsageTipsScreen extends StatelessWidget {
  const UsageTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tips = [
      (icon: Icons.notifications_active_rounded, title: l10n.usageTip1Title, body: l10n.usageTip1Body),
      (icon: Icons.edit_calendar_rounded, title: l10n.usageTip2Title, body: l10n.usageTip2Body),
      (icon: Icons.palette_rounded, title: l10n.usageTip3Title, body: l10n.usageTip3Body),
      (icon: Icons.edit_rounded, title: l10n.usageTip4Title, body: l10n.usageTip4Body),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.usageTipsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: FadeSlideIn(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final (index, tip) in tips.indexed)
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
