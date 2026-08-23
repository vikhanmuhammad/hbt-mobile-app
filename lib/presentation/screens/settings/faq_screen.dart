import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';

/// Frequently asked questions about the offline principle & data security. CLAUDE.md v3 §8.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final faqs = [
      (q: l10n.faqQ1, a: l10n.faqA1),
      (q: l10n.faqQ2, a: l10n.faqA2),
      (q: l10n.faqQ3, a: l10n.faqA3),
      (q: l10n.faqQ4, a: l10n.faqA4),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.faqTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: FadeSlideIn(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final (index, faq) in faqs.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FadeSlideIn(
                    delay: staggeredDelay(index),
                    child: Card(
                      child: ExpansionTile(
                        title: Text(faq.q, style: theme.textTheme.titleSmall),
                        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(faq.a, style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
                        ],
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
