import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/settings_providers.dart';
import '../../theme/app_palettes.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/animations/tap_scale.dart';

/// Pick the app's color theme — 5 palettes with swatch previews. CLAUDE.md v3 §8.
class PersonalizeScreen extends ConsumerWidget {
  const PersonalizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final active = ref.watch(activePaletteProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.personalizeTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: FadeSlideIn(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                l10n.personalizeDescription,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              for (final (index, palette) in AppPalettes.all.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FadeSlideIn(
                    delay: staggeredDelay(index),
                    child: TapScale(
                      child: _PaletteTile(
                        palette: palette,
                        selected: active.key == palette.key,
                        onTap: () => ref.read(activePaletteProvider.notifier).setPalette(palette.key),
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

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.palette, required this.selected, required this.onTap});

  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: selected ? Color.lerp(theme.cardColor, palette.accent, 0.14) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: selected ? BorderSide(color: palette.accent, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(palette.label, style: theme.textTheme.titleSmall),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: palette.accent),
            ],
          ),
        ),
      ),
    );
  }
}
