/// Language used purely for onboarding's instructional copy and the 3
/// lifestyle questions (point 4) — does not affect the rest of the app,
/// which stays in English/data-driven habit names regardless.
enum OnboardingLang { en, id }

/// Instructional copy for the onboarding flow, in English and Indonesian.
/// Habit/category *names* (data-driven, from `habit_templates.json`) are
/// intentionally out of scope — only fixed UI copy here.
class OnboardingStrings {
  const OnboardingStrings(this.lang);

  final OnboardingLang lang;

  bool get _id => lang == OnboardingLang.id;
  String _t(String en, String id) => _id ? id : en;

  // Language pick step.
  String get chooseLanguageTitle => _t('Choose your language', 'Pilih bahasa kamu');
  String get englishLabel => 'English';
  String get indonesianLabel => 'Bahasa Indonesia';

  // Feature highlight step (intro carousel, between language pick and
  // personal info).
  List<String> get introTitles => _id
      ? const [
          'Catat progresmu dalam hitungan detik',
          'Lihat konsistensimu sekilas pandang',
          'Bertumbuh bersama teman',
          'Semua kebiasaanmu, dalam satu layar',
        ]
      : const [
          'Log your progress in seconds',
          'See your consistency at a glance',
          'Grow together with friends',
          'Every habit, right on one screen',
        ];
  List<String> get introSubtitles => _id
      ? const [
          'Tap untuk selesaikan kebiasaan sederhana, atau tambahkan angka untuk yang kamu ukur.',
          'Kalender bulanan dengan ring progress menunjukkan seberapa konsisten kamu selama ini.',
          'Gabung Community, lacak kebiasaan bareng, dan naik di papan peringkat bersama.',
          'Beranda menunjukkan progres dan target tiap kebiasaan dengan jelas, setiap hari.',
        ]
      : const [
          'Tap to check off simple habits, or add a quick number for the ones you measure.',
          'A monthly calendar with progress rings shows exactly how consistent you\'ve been.',
          'Join a Community group, track shared habits, and climb the leaderboard together.',
          'Home shows your progress against each goal clearly, right from the first glance.',
        ];
  String get getStarted => _t('Get Started', 'Mulai');

  // Personal info step.
  String get whatsYourName => _t('What\'s your name?', 'Siapa namamu?');
  String get soWeCanGreet =>
      _t('So we can greet you more personally.', 'Supaya kami bisa menyapamu lebih personal.');
  String get nameLabel => _t('Name', 'Nama');
  String get nameHint => _t('Your name', 'Nama kamu');
  String get ageLabel => _t('Age (optional)', 'Umur (opsional)');
  String get ageHint => _t('e.g. 25', 'contoh: 25');
  String get genderLabel => _t('Gender', 'Jenis kelamin');
  String get genderHint => _t('Select a gender', 'Pilih jenis kelamin');
  String get next => _t('Next', 'Lanjut');
  String get back => _t('Back', 'Kembali');
  String get skip => _t('Skip', 'Lewati');

  // Education step.
  String get consistencyBuildsHabits =>
      _t('Consistency Builds Habits', 'Konsistensi Membangun Kebiasaan');
  String get educationBody => _t(
        'According to research by Lally et al. (UCL), a new habit takes about 66 days '
            'of repetition to become automatic — not just a fleeting intention.',
        'Menurut riset Lally dkk. (UCL), kebiasaan baru butuh sekitar 66 hari pengulangan '
            'untuk menjadi otomatis — bukan sekadar niat sesaat.',
      );
  String get habitsIncreaseHappiness =>
      _t('Building good habits increases happiness!', 'Membangun kebiasaan baik meningkatkan kebahagiaan!');
  String get goodToKnow => _t('Good to know', 'Perlu diketahui');
  List<String> get habitTips => _id
      ? const [
          'Melewatkan satu hari tidak menghapus progresmu — yang penting cepat kembali ke jalur.',
          'Mulai dari hal kecil. Kebiasaan kecil yang bisa dijalani lebih baik daripada kebiasaan ambisius yang berhenti setelah 3 hari.',
          'Gabungkan kebiasaan baru dengan rutinitas yang sudah ada (mis. setelah sikat gigi) agar lebih mudah menempel.',
          'Melacak progres secara visual membuatmu jauh lebih mungkin untuk terus melakukannya.',
        ]
      : const [
          'Missing a day doesn\'t reset your progress — what matters is getting back on track quickly.',
          'Start small. A tiny, doable habit beats an ambitious one you abandon after 3 days.',
          'Stack a new habit onto an existing routine (e.g. after brushing your teeth) to make it stick faster.',
          'Tracking your streak visually makes you far more likely to keep it going.',
        ];

  // Goal phrase pick step.
  String get chooseHabitsTitle =>
      _t('Choose Habits That Match Your Goals', 'Pilih Kebiasaan yang Sesuai Tujuanmu');
  String get pickOneOrMoreGoals =>
      _t('Pick one or more goals you want to achieve.', 'Pilih satu atau lebih tujuan yang ingin kamu capai.');
  String get createNewGoal => _t('+ Create New Goal', '+ Buat Tujuan Baru');

  // Recommendation step.
  String get habitRecommendations => _t('Habit Recommendations', 'Rekomendasi Kebiasaan');
  String get checkHabitsYouWant =>
      _t('Check the habits you want to start. You can skip the rest.', 'Centang kebiasaan yang ingin kamu mulai. Sisanya boleh dilewati.');
  String get upgradeToPro => _t('Upgrade to Pro', 'Upgrade ke Pro');
  String get exploreOtherCategories =>
      _t('+ Explore Other Categories / Add Custom Habit', '+ Jelajahi Kategori Lain / Tambah Kebiasaan Kustom');
  String get saving => _t('Saving...', 'Menyimpan...');

  // Summary step.
  String get summary => _t('Summary', 'Ringkasan');
  String get noHabitsAddedYet => _t(
        'No habits added yet. You can add one anytime via the Add Habit button on Home.',
        'Belum ada kebiasaan yang ditambahkan. Kamu bisa menambahkannya kapan saja lewat tombol Tambah Kebiasaan di Beranda.',
      );
  String habitsAddedSuccessfully(int count) =>
      _t('$count habit(s) added successfully', '$count kebiasaan berhasil ditambahkan');
  String get startTracking => _t('Start Tracking', 'Mulai Melacak');
}
