import 'package:flutter/material.dart';

/// Full-screen teaser untuk fitur yang seluruhnya di-gate Pro (Community,
/// Keuangan) — beda dari [showProRequiredDialog] yang cuma menghentikan 1
/// aksi spesifik (mis. pilih kategori Keuangan, tambah habit ke-6).
class ProFeatureTeaser extends StatelessWidget {
  const ProFeatureTeaser({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Text(
                'Integrasi pembelian Pro sungguhan belum tersedia — aktifkan lewat '
                'toggle "Mode Pro (Debug)" di Pengaturan untuk mencoba fitur ini.',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog paywall generik untuk 1 aksi spesifik yang di-gate Pro (bukan
/// seluruh layar) — mis. pilih kategori Keuangan atau melewati batas 5
/// habit aktif untuk Free.
Future<void> showProRequiredDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Fitur Pro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          Text(
            'Integrasi pembelian Pro sungguhan belum tersedia — aktifkan lewat '
            'toggle "Mode Pro (Debug)" di Pengaturan untuk mencoba fitur ini.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Oke'),
        ),
      ],
    ),
  );
}
