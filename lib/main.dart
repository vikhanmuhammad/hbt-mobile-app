import 'dart:async';
import 'dart:math';

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
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await dotenv.load(fileName: '.env');
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

const _splashQuotes = [
  'Small steps, repeated daily, become big changes.',
  'Consistency beats intensity.',
  'You don\'t have to be perfect — just show up.',
  'Every habit starts with a single decision.',
  'Progress, not perfection.',
  'Discipline today, freedom tomorrow.',
];

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  late final Timer _timer;
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _quoteIndex = Random().nextInt(_splashQuotes.length);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _quoteIndex = (_quoteIndex + 1) % _splashQuotes.length);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
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
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _splashQuotes[_quoteIndex],
                  key: ValueKey(_quoteIndex),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.textTheme.bodySmall?.color,
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
