import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/screens/onboarding/onboarding_flow.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/app_logo.dart';
import 'presentation/widgets/navigation_shell.dart';
import 'providers/core_providers.dart';
import 'providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends ConsumerWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const AppBootstrap(),
    );
  }
}

/// Menjalankan seeding kategori bawaan + inisialisasi notifikasi sebelum
/// menentukan halaman awal (Onboarding vs Beranda). Lihat CLAUDE.md §5.
class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.init();
      await notificationService.requestPermissions();
    } catch (_) {
      // Platform notifikasi tidak tersedia (mis. saat testing) — jangan
      // blokir seeding & tampilan app karena ini.
    }

    final templates = await ref.read(habitTemplateRepositoryProvider).getAll();
    await ref.read(categoryRepositoryProvider).seedDefaultCategories(templates);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        final hasOnboarded = ref.watch(onboardingStatusProvider);
        return hasOnboarded ? const NavigationShell() : const OnboardingFlow();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: AppLogo(size: 72)),
    );
  }
}
