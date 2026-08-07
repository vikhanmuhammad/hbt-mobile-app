import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/screens/onboarding/onboarding_flow.dart';
import 'presentation/screens/onboarding/returning_welcome_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/app_logo.dart';
import 'providers/core_providers.dart';
import 'providers/settings_providers.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    final accent = ref.watch(activePaletteProvider).accent;
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: accent),
      darkTheme: AppTheme.dark(accent: accent),
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
        // Deteksi user baru vs lama: keberadaan row UserProfile (CLAUDE.md v3
        // §4.2) — bukan flag SharedPreferences terpisah lagi.
        final profileAsync = ref.watch(userProfileStreamProvider);
        return profileAsync.when(
          loading: () => const _SplashScreen(),
          error: (e, st) => const OnboardingFlow(),
          data: (profile) => profile == null
              ? const OnboardingFlow()
              : ReturningWelcomeScreen(name: profile.name),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 72),
            const SizedBox(height: 24),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
