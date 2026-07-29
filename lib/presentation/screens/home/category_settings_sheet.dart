import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/category_repository.dart';
import '../../../domain/models/category.dart';
import '../../../providers/core_providers.dart';

/// Menu cepat dari header Category Detail: ganti nama, atau
/// sembunyikan/hapus kategori. Data safety: kategori bawaan hanya
/// disembunyikan, kategori custom minta konfirmasi kalau masih ada habit
/// (CLAUDE.md §5/§7).
Future<void> showCategorySettingsSheet(BuildContext context, Category category) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CategorySettingsSheet(category: category),
  );
}

class _CategorySettingsSheet extends ConsumerWidget {
  const _CategorySettingsSheet({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline_rounded),
            title: const Text('Ganti nama'),
            onTap: () async {
              Navigator.of(context).pop();
              await _renameDialog(context, ref);
            },
          ),
          ListTile(
            leading: Icon(category.isDefault
                ? Icons.visibility_off_rounded
                : Icons.delete_outline_rounded),
            title: Text(category.isDefault ? 'Sembunyikan kategori' : 'Hapus kategori'),
            onTap: () async {
              Navigator.of(context).pop();
              await _delete(context, ref);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _renameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: category.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti nama kategori'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await ref.read(categoryRepositoryProvider).renameCategory(category.id, newName);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(categoryRepositoryProvider);
    try {
      await repo.deleteOrArchive(category);
    } on CategoryDeletionBlocked {
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kategori masih punya habit'),
          content: Text(
            'Kategori "${category.name}" masih punya habit dengan riwayat. '
            'Menghapusnya juga akan menghapus semua habit dan riwayatnya. Lanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await repo.deleteOrArchive(category, confirmedWithHabits: true);
      }
    }
  }
}
