import 'package:flutter/material.dart';

enum EmptyStateVariant { checklist, wallet }

/// Looping animated illustration used above empty-state captions (Home's "No
/// habits scheduled yet", Finance's "No finance habits yet") — replaces flat
/// static icons with a small floating card + badge animation.
class EmptyStateIllustration extends StatefulWidget {
  const EmptyStateIllustration({super.key, this.variant = EmptyStateVariant.checklist});

  final EmptyStateVariant variant;

  @override
  State<EmptyStateIllustration> createState() => _EmptyStateIllustrationState();
}

class _EmptyStateIllustrationState extends State<EmptyStateIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWallet = widget.variant == EmptyStateVariant.wallet;
    return SizedBox(
      height: 140,
      width: 140,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final float = Curves.easeInOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -6 + float * 6),
                child: isWallet
                    ? Container(
                        width: 92,
                        height: 72,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.dividerColor, width: 1.5),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.dividerColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 26,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.dividerColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: 76,
                        height: 92,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.dividerColor, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Column(
                          children: [
                            for (var i = 0; i < 3; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: theme.dividerColor, width: 1.5),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Container(height: 6, color: theme.dividerColor),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              Positioned(
                bottom: 14 - float * 8,
                right: 18,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                  child: Icon(
                    isWallet ? Icons.savings_rounded : Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
