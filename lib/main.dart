import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/language.dart';
import 'l10n/generated/app_localizations.dart';
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
    final language = ref.watch(appLanguageProvider);
    return MaterialApp(
      title: 'Daily Habits',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: accent),
      darkTheme: AppTheme.dark(accent: accent),
      themeMode: themeMode,
      locale: Locale(language == AppLang.id ? 'id' : 'en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Many fixed-size elements throughout the app (bottom nav bar, circular
      // icon badges, checkboxes, category tiles) are sized for roughly 1x
      // text scale and don't grow to match. Without a ceiling, an elder user
      // who cranks their device's font/display size setting up gets text
      // that overflows/clips out of those containers instead of scaling
      // responsively. Clamping keeps accessibility scaling meaningful while
      // staying within what the fixed layouts can actually accommodate.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.85,
        maxScaleFactor: 1.3,
        child: child!,
      ),
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
    // Seeding + notification init are usually near-instant, which used to
    // make the splash screen (and its motivational quote) flash by too
    // fast to notice. Enforce a minimum long enough to comfortably read a
    // couple of the rotating quotes below.
    final minDuration = Future.delayed(const Duration(milliseconds: 4200));

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

    // Backfill dwibahasa sekali-jalan (CLAUDE.md §Bahasa) — cocokkan
    // habit/kategori bawaan lama (dari instalasi sebelum fitur ini ada) ke
    // template, supaya title-nya terkunci & terisi nameId tanpa perlu
    // migrasi data yang merusak. Dijaga flag supaya cuma jalan sekali.
    final settingsRepo = ref.read(settingsRepositoryProvider);
    if (!settingsRepo.templateBackfillDone) {
      await ref.read(habitRepositoryProvider).backfillTemplateProvenance(templates);
      await ref.read(categoryRepositoryProvider).backfillTemplateProvenance(templates);
      await settingsRepo.setTemplateBackfillDone(true);
    }

    // Warm the profile stream (which `activePaletteProvider` derives the
    // personalized accent color from) before the splash screen is dismissed
    // — otherwise the splash's first frame(s) render with the default gold
    // palette and only flash to the real personalized color once the
    // stream's first snapshot arrives after the splash is already gone.
    try {
      await ref.read(userProfileStreamProvider.future).timeout(
            const Duration(milliseconds: 1500),
          );
    } catch (_) {
      // Stream didn't resolve in time or errored (e.g. brand-new user with
      // no profile row yet) — fall back to the default palette, same as
      // before this warm-up existed.
    }

    await minDuration;
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
  'Small steps, repeated daily, quietly compound into changes big enough to '
      'transform how your life actually looks a year from now.',
  'Consistency beats intensity every time — showing up in a small way today '
      'matters more than one perfect burst of effort you can\'t repeat tomorrow.',
  'You don\'t have to be perfect. Missing a single day doesn\'t erase your '
      'progress — what matters most is getting back on track quickly.',
  'Every lasting habit starts with one small, deliberate decision, repeated '
      'on purpose until it stops feeling like a decision at all.',
  'Progress, not perfection, is what actually builds a habit that lasts — '
      'give yourself credit for showing up, even imperfectly.',
  'A little discipline today quietly buys you a lot more freedom tomorrow, '
      'even when the payoff isn\'t obvious yet.',
];

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> with TickerProviderStateMixin {
  late final Timer _timer;
  late final AnimationController _progressController;
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _quoteIndex = Random().nextInt(_splashQuotes.length);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _quoteIndex = (_quoteIndex + 1) % _splashQuotes.length);
    });
    // Matches AppBootstrap's minDuration below so the bar reaches a full
    // 100% right around when the splash screen is dismissed, instead of
    // just looping indeterminately.
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..forward();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _logoScale = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _progressController.dispose();
    _logoController.dispose();
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
              ScaleTransition(scale: _logoScale, child: const AppLogo(size: 72)),
              const SizedBox(height: 24),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) => LinearProgressIndicator(
                      value: _progressController.value,
                    ),
                  ),
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
