import 'package:flutter/material.dart';

/// Frequently asked questions about the offline principle & data security. CLAUDE.md v3 §8.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    (
      q: 'Why is this app fully offline?',
      a: 'So your daily habit data stays private and can be used anytime without '
          'needing an internet connection. No account, no server, no tracking.',
    ),
    (
      q: 'How is my data stored and is it safe?',
      a: 'All data (categories, habits, progress history, profile) is stored in a local '
          'database on your own device — never sent anywhere.',
    ),
    (
      q: 'What if I switch phones? Does my data move too?',
      a: 'Since there\'s no cloud sync, data doesn\'t transfer automatically. Use the '
          'Export Data feature in Settings (coming soon) to make a manual backup before '
          'switching devices, then Import Data on the new phone.',
    ),
    (
      q: 'Do I need to log in or sign up for an account?',
      a: 'No. This app has no account system at all — open it and start using it right away.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final faq in _faqs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}
