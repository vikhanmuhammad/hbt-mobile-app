import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/core_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/category_icon.dart';
import 'recommendation_screen.dart';

/// Step 1b: buat kategori custom baru (nama + ikon + warna), lalu lanjut ke
/// step 2 (langsung form custom karena belum ada rekomendasi). Lihat
/// DESIGN.md §4.5 poin 4.
class CreateCategoryScreen extends ConsumerStatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  ConsumerState<CreateCategoryScreen> createState() =>
      _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends ConsumerState<CreateCategoryScreen> {
  final _nameController = TextEditingController();
  String _icon = customCategoryIconChoices.first;
  int _colorIndex = 0;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Kategori Baru')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Nama kategori', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Mis. Hobi'),
          ),
          const SizedBox(height: 24),
          Text('Ikon', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final icon in customCategoryIconChoices)
                _IconChoice(
                  icon: icon,
                  selected: _icon == icon,
                  color: AppColors.categoryPalette[_colorIndex],
                  onTap: () => setState(() => _icon = icon),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Warna', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < AppColors.categoryPalette.length; i++)
                _ColorChoice(
                  color: AppColors.categoryPalette[i],
                  selected: _colorIndex == i,
                  onTap: () => setState(() => _colorIndex = i),
                ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Lanjut'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nama kategori wajib diisi')));
      return;
    }

    setState(() => _saving = true);
    final colorHex =
        '#${AppColors.categoryPalette[_colorIndex].toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    final id = await ref.read(categoryRepositoryProvider).createCustomCategory(
          name: name,
          icon: _icon,
          colorHex: colorHex,
        );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RecommendationScreen(categoryId: id, categoryName: name),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : null,
          border: Border.all(color: selected ? color : Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(categoryIconData(icon), color: selected ? color : null),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
              : null,
        ),
        child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
      ),
    );
  }
}
