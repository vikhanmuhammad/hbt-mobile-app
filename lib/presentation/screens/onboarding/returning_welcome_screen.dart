import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/app_logo.dart';
import '../../widgets/navigation_shell.dart';

/// Alur user lama (CLAUDE.md v3 §4.2): "Selamat Datang Kembali, [Nama]" —
/// tampil singkat lalu auto-lanjut ke Beranda, atau bisa ditap langsung.
class ReturningWelcomeScreen extends StatefulWidget {
  const ReturningWelcomeScreen({super.key, required this.name});

  final String name;

  @override
  State<ReturningWelcomeScreen> createState() => _ReturningWelcomeScreenState();
}

class _ReturningWelcomeScreenState extends State<ReturningWelcomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), _continue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const NavigationShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: _continue,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 72),
                  const SizedBox(height: 20),
                  Text(
                    'Selamat Datang Kembali,\n${widget.name}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
