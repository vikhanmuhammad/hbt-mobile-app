import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../l10n/generated/app_localizations.dart';
import 'habit_icon.dart';

/// Curated icon picker bottom sheet — grouped by context + a search bar
/// filtering by keyword. CLAUDE.md v3 §9. Used for both goal
/// phrase/category icons and individual habit icons.
Future<String?> showIconPickerSheet(BuildContext context, {String? currentIcon}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _IconPickerSheet(currentIcon: currentIcon),
  );
}

class _IconPickerSheet extends StatefulWidget {
  const _IconPickerSheet({this.currentIcon});

  final String? currentIcon;

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final query = _query.trim().toLowerCase();
    final grouped = <String, List<CuratedIcon>>{};
    for (final c in curatedHabitIcons) {
      if (query.isNotEmpty &&
          !c.key.contains(query) &&
          !c.group.toLowerCase().contains(query)) {
        continue;
      }
      grouped.putIfAbsent(c.group, () => []).add(c);
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.viewInsetsOf(context).bottom + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.iconPickerChooseIcon, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.iconPickerSearchHint,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: grouped.isEmpty
                  ? Center(
                      child: Text(l10n.iconPickerNoIconsFound, style: theme.textTheme.bodySmall),
                    )
                  : ListView(
                      children: [
                        for (final group in grouped.keys) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Text(
                              group.toUpperCase(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final c in grouped[group]!)
                                _IconOption(
                                  curated: c,
                                  selected: widget.currentIcon == c.key,
                                  onTap: () => Navigator.of(context).pop(c.key),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconOption extends StatelessWidget {
  const _IconOption({required this.curated, required this.selected, required this.onTap});

  final CuratedIcon curated;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: theme.colorScheme.onSurface, width: 3)
              : null,
        ),
        child: Center(child: FaIcon(curated.icon, size: 16, color: Colors.white)),
      ),
    );
  }
}
