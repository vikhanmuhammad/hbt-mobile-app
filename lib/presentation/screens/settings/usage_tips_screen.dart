import 'package:flutter/material.dart';

/// Tips singkat pemakaian app — reminder, backfill progress, ganti tema,
/// pakai Edit Mode. CLAUDE.md v3 §8.
class UsageTipsScreen extends StatelessWidget {
  const UsageTipsScreen({super.key});

  static const _tips = [
    (
      icon: Icons.notifications_active_rounded,
      title: 'Pakai Reminder',
      body: 'Saat menambah atau mengedit habit, aktifkan toggle Reminder dan atur jamnya. '
          'App akan mengirim notifikasi lokal di jam itu pada hari-hari aktif habit tersebut.',
    ),
    (
      icon: Icons.edit_calendar_rounded,
      title: 'Backfill Progress',
      body: 'Lewat tab Dashboard, tap tanggal yang sudah lewat di kalender untuk melihat detail habit hari itu. '
          'Kamu bisa tetap menandai/mengubah progress hari-hari sebelumnya dari sana.',
    ),
    (
      icon: Icons.palette_rounded,
      title: 'Ganti Tema',
      body: 'Buka Pengaturan > Personalize untuk memilih salah satu dari 5 palet warna. '
          'Perubahan berlaku langsung di seluruh app.',
    ),
    (
      icon: Icons.edit_rounded,
      title: 'Pakai Edit Mode',
      body: 'Tap tombol pensil di kanan bawah Beranda untuk masuk Edit Mode — dari sini kamu '
          'bisa mengurutkan ulang (drag), mengedit, atau menonaktifkan habit. Tap tombol '
          'centang atau "Selesai" untuk keluar.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Usage Tips')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final tip in _tips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(tip.icon, color: theme.colorScheme.primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tip.title, style: theme.textTheme.titleSmall),
                                const SizedBox(height: 6),
                                Text(
                                  tip.body,
                                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
