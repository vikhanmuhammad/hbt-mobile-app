import 'package:flutter/material.dart';

/// Static mock of the real Finance summary screen (dummy numbers, not live
/// data) — used both as the blurred backdrop behind the Finance
/// `ProFeatureTeaser` paywall and, wrapped in a blur, behind the onboarding
/// Recommendations step when the user selected "Save Money" but isn't Pro
/// (see `onboarding_flow.dart`'s `_RecommendationStep`).
class FinancePreviewMock extends StatelessWidget {
  const FinancePreviewMock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Text('Finance', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Spending', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text('Rp 850.000', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        minHeight: 8,
                        valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.savings_rounded, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(height: 10),
                          Text('Total Saved', style: theme.textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Text('Rp 1.200.000',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(height: 10),
                          Text('Total Deposited', style: theme.textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Text('Rp 2.000.000',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
