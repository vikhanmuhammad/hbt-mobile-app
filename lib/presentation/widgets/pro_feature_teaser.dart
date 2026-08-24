import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/community_providers.dart';

/// Full-screen teaser for features entirely gated behind Pro (Community,
/// Finance) — different from [showProRequiredDialog], which only blocks 1
/// specific action (e.g. picking the Finance category, adding the 6th habit).
/// Shows a blurred preview of what the unlocked feature looks like behind a
/// frosted overlay, a short benefits list, and an "Upgrade to Pro" button
/// that opens the real Play Billing purchase flow (`PurchaseService`) — Pro
/// only unlocks once Cloud Functions verify the purchase server-side and
/// update `users/{uid}` in Firestore, which [IAPEntitlementService] streams.
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
    ref.listen(purchaseErrorsProvider, (previous, next) {
      final message = next.asData?.value;
      if (message != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    });
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
              // Toned back down from an earlier pass that went too far —
              // sigma 16 + alpha 0.58 wiped the preview out into a flat gray
              // with no silhouette left at all. This keeps a "frosted glass"
              // look: shapes/colors of the preview still read faintly
              // through it, just clearly darker/less legible than before.
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),
          // Tapping anywhere on the dimmed backdrop also goes back, not just
          // the small corner icon below — matches how a modal over content
          // is expected to dismiss.
          if (Navigator.of(context).canPop())
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          if (Navigator.of(context).canPop())
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          Center(
            // Absorbs taps on the dialog itself so they don't fall through
            // to the full-backdrop dismiss layer behind it — only tapping
            // outside this card should count as "tap outside to go back".
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
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
                            child: Text(AppLocalizations.of(context)!.proFeatureUpgradeButton),
                          ),
                        ),
                      ],
                    ),
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
    final l10n = AppLocalizations.of(context)!;
    var uid = ref.read(currentUidProvider);
    if (uid == null) {
      // Purchasing requires an account (to attribute the purchase), but the
      // Pro paywall is often the first thing a not-yet-signed-in user sees —
      // sign them in here instead of dead-ending with an error, so "Upgrade
      // to Pro" alone is enough to get through the whole flow.
      try {
        final user = await ref.read(authServiceProvider).signInWithGoogle();
        uid = user?.uid;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.proFeatureSignInFailed('$e'))),
          );
        }
        return;
      }
      if (uid == null) return;
    }

    final purchaseService = ref.read(purchaseServiceProvider);
    List<ProductDetails> products;
    try {
      products = await purchaseService.queryProducts();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proFeatureCouldNotLoadPlans)),
        );
      }
      return;
    }
    if (products.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proFeatureNoPlansAvailable)),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final selected = await showModalBottomSheet<ProductDetails>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProPlanSheet(products: products),
    );
    if (selected == null) return;

    await purchaseService.buy(selected, uid: uid);
  }
}

/// Bottom sheet listing the live subscription plans (title/price straight
/// from Play Billing via [ProductDetails] — never hardcoded, Play Console is
/// the source of truth for pricing).
class _ProPlanSheet extends StatelessWidget {
  const _ProPlanSheet({required this.products});

  final List<ProductDetails> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.proFeatureChooseYourPlan,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            for (final product in products)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(product),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Column(
                    children: [
                      Text(product.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(product.price, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
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
      title: Text(AppLocalizations.of(context)!.proFeatureTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.commonOk),
        ),
      ],
    ),
  );
}
