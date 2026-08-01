import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/date_utils.dart';
import '../../../domain/habit_schedule.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/habit_with_progress.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/core_providers.dart';
import '../../../providers/progress_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashed_border.dart';
import '../add_habit/add_habit_flow_screen.dart';

/// Level 2 Beranda: daftar habit dalam 1 kategori. Baris flat (bukan kartu
/// terpisah) dengan checkbox + tombol toggle di bawahnya. Tombol "Kelola
/// Habit" membuka mode kelola (edit/hapus per habit + tambah baru) — di
/// luar mode itu, tampilan cuma checklist polos tanpa afordansi manajemen.
/// Dipakai sebagai push route (mobile) & panel kanan master-detail (tablet).
class CategoryDetailView extends ConsumerStatefulWidget {
  const CategoryDetailView({
    super.key,
    required this.categoryId,
    this.showBackButton = false,
    this.onBack,
  });

  final int categoryId;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  ConsumerState<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends ConsumerState<CategoryDetailView> {
  bool _isManaging = false;

  @override
  void didUpdateWidget(covariant CategoryDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      _isManaging = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final date = today();
    final items = ref.watch(habitsWithProgressForCategoryProvider(widget.categoryId, date));

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Gagal memuat: $e')),
      data: (categories) {
        Category? category;
        for (final c in categories) {
          if (c.id == widget.categoryId) category = c;
        }
        if (category == null) {
          return const Center(child: Text('Kategori tidak ditemukan'));
        }

        final index = categories.indexOf(category);
        final accentColor = AppColors.categoryColorFromHex(category.colorHex, index);
        final done = items.where((i) => i.isDone).length;
        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.showBackButton) ...[
                      Material(
                        color: theme.brightness == Brightness.light
                            ? AppColors.lightSurfaceAlt
                            : AppColors.darkSurfaceAlt,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: widget.onBack,
                          child: const SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(Icons.chevron_left_rounded, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(category.name, style: theme.textTheme.titleLarge),
                    ),
                    if (items.isNotEmpty && !_isManaging) ...[
                      Text(
                        '$done/${items.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    _ManageToggleButton(
                      isManaging: _isManaging,
                      onPressed: () => setState(() => _isManaging = !_isManaging),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (items.isEmpty && !_isManaging)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Belum ada habit di kategori ini. Tekan "Kelola Habit" untuk menambahkan.',
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                else
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HabitRow(
                        item: item,
                        accentColor: accentColor,
                        date: date,
                        isManaging: _isManaging,
                      ),
                    ),
                if (_isManaging)
                  DashedBorder(
                    borderRadius: 16,
                    onTap: () => openAddHabitFlowInCategory(context, widget.categoryId),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(
                          '+ Tambah Habit',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({
    required this.item,
    required this.accentColor,
    required this.date,
    required this.isManaging,
  });

  final HabitWithProgress item;
  final Color accentColor;
  final DateTime date;
  final bool isManaging;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habit = item.habit;
    final checked = item.isDone;
    final notDueToday = !isHabitActiveOn(habit, date);
    final bg = checked
        ? Color.lerp(theme.scaffoldBackgroundColor, theme.colorScheme.primary, 0.12)!
        : theme.scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HabitCheckbox(
                checked: checked,
                onTap: () => _toggle(context, ref),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: checked ? theme.textTheme.bodySmall?.color : null,
                        decoration: checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${habit.goalLabel} · ${habit.timeRange.label}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!isManaging && habit.reminderEnabled) ...[
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                ),
              ],
              if (!isManaging && notDueToday)
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Text(
                    'Tidak dijadwalkan',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              if (isManaging) ...[
                Material(
                  color: theme.cardColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => openEditHabitFlow(context, habit),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: Icon(Icons.edit_outlined, size: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Material(
                  color: theme.cardColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _confirmDelete(context, ref),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: Icon(Icons.delete_outline_rounded, size: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _toggle(context, ref),
              style: OutlinedButton.styleFrom(
                backgroundColor: checked ? theme.colorScheme.primary : Colors.transparent,
                foregroundColor: checked ? Colors.white : theme.textTheme.bodyMedium?.color,
                side: BorderSide(
                  color: checked ? theme.colorScheme.primary : theme.dividerColor,
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                checked ? '✓ Selesai' : 'Tandai Selesai',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Checkbox & tombol "Tandai Selesai" adalah toggle penuh (selesai <-> belum),
  // bukan increment — berlaku sama untuk goal 1x maupun goal bertahap (mis. 8
  // gelas). Tap lagi setelah selesai akan membatalkannya kembali ke semula.
  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(habitLogRepositoryProvider);
      await repo.toggleDone(habit: item.habit, date: date, currentlyDone: item.isDone);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(monthSummariesProvider);
      ref.invalidate(daySummaryProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memperbarui progress: $e')));
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final habit = item.habit;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus habit?'),
        content: Text(
          'Menghapus "${habit.name}" juga akan menghapus semua riwayat progress-nya. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(habitRepositoryProvider).deleteHabit(habit.id);
      await ref.read(notificationServiceProvider).cancelForHabit(habit.id);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(monthSummariesProvider);
      ref.invalidate(daySummaryProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menghapus habit: $e')));
      }
    }
  }
}

/// Toggle 2 state: "Kelola Habit" (netral) <-> "Selesai" (primer, saat
/// mode kelola aktif). Beda dari [PrimaryPillButton] karena butuh warna
/// teks yang kontras terhadap keduanya, bukan selalu putih.
class _ManageToggleButton extends StatelessWidget {
  const _ManageToggleButton({required this.isManaging, required this.onPressed});

  final bool isManaging;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Netral: pakai grayLight yang sama dengan bg lingkaran tombol back di
    // sebelahnya (bukan theme.dividerColor — itu tone M3 auto-generate dari
    // seed emas yang jadi coklat pudar, tidak match palet app).
    final bg = isManaging
        ? theme.colorScheme.primary
        : (theme.brightness == Brightness.light
            ? AppColors.lightSurfaceAlt
            : AppColors.darkSurfaceAlt);
    final fg = isManaging ? Colors.white : theme.textTheme.bodyMedium?.color;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            isManaging ? 'Selesai' : 'Kelola Habit',
            style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _HabitCheckbox extends StatelessWidget {
  const _HabitCheckbox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: checked ? theme.colorScheme.primary : theme.scaffoldBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: checked
                ? theme.colorScheme.primary
                : theme.textTheme.bodySmall?.color ?? theme.dividerColor,
            width: checked ? 2 : 2.5,
          ),
        ),
        child: checked
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
