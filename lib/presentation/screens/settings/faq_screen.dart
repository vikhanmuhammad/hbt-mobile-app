import 'package:flutter/material.dart';

/// Pertanyaan umum seputar prinsip offline & keamanan data. CLAUDE.md v3 §8.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    (
      q: 'Kenapa app ini sepenuhnya offline?',
      a: 'Supaya data kebiasaan harianmu tetap privat dan bisa dipakai kapan saja tanpa '
          'perlu koneksi internet. Tidak ada akun, tidak ada server, tidak ada tracking.',
    ),
    (
      q: 'Bagaimana data saya tersimpan dan apakah aman?',
      a: 'Semua data (kategori, habit, riwayat progress, profil) disimpan di database lokal '
          'di perangkatmu sendiri — tidak pernah dikirim ke mana pun.',
    ),
    (
      q: 'Bagaimana kalau saya ganti HP? Apakah data ikut pindah?',
      a: 'Karena tidak ada sinkronisasi cloud, data tidak otomatis berpindah. Pakai fitur '
          'Export Data di Pengaturan (segera hadir) untuk membuat cadangan manual sebelum '
          'ganti perangkat, lalu Import Data di HP baru.',
    ),
    (
      q: 'Apakah saya perlu login atau mendaftar akun?',
      a: 'Tidak. App ini tidak punya sistem akun sama sekali — buka dan langsung pakai.',
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
