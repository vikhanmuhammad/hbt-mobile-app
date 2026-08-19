/// Gender option on the "What's your name?" onboarding step (replaces the
/// old, effectively-unused "Choose your goals" dropdown — the real goal
/// phrase selection happens later in `_GoalPhrasePickStep`).
enum Gender {
  male,
  female,
  preferNotToSay;

  static Gender? fromValue(String? value) {
    for (final g in Gender.values) {
      if (g.name == value) return g;
    }
    return null;
  }

  String label(bool indonesian) => switch (this) {
        Gender.male => indonesian ? 'Laki-laki' : 'Male',
        Gender.female => indonesian ? 'Perempuan' : 'Female',
        Gender.preferNotToSay => indonesian ? 'Tidak ingin menyebutkan' : 'Prefer not to say',
      };
}

/// Onboarding lifestyle questionnaire questions (CLAUDE.md v3 §4.1 step 3).
/// Holds both English and Indonesian copy — the intro language toggle (point
/// 4) only affects instructional/question text like this, not the whole app.
class OnboardingQuestion {
  const OnboardingQuestion({
    required this.key,
    required this.prompt,
    required this.promptId,
    required this.options,
    required this.optionsId,
  });

  /// Matches `OnboardingResponses.questionKey`. The stored answer value is
  /// always the English option text, regardless of the intro language, so
  /// answers stay comparable/consistent in the database.
  final String key;
  final String prompt;
  final String promptId;
  final List<String> options;
  final List<String> optionsId;

  String promptFor(bool indonesian) => indonesian ? promptId : prompt;
  List<String> optionsFor(bool indonesian) => indonesian ? optionsId : options;
}

const List<OnboardingQuestion> lifestyleQuestions = [
  OnboardingQuestion(
    key: 'lifestyle_challenge',
    prompt: 'What do you often experience?',
    promptId: 'Apa yang sering kamu alami?',
    options: [
      'No clear goals',
      'Tend to procrastinate before starting tasks',
      'Often feel stressed or anxious',
      'Struggle to stay consistent with plans',
      'Struggle to finish tasks on time',
    ],
    optionsId: [
      'Tidak punya tujuan yang jelas',
      'Sering menunda sebelum memulai tugas',
      'Sering merasa stres atau cemas',
      'Sulit konsisten dengan rencana',
      'Sulit menyelesaikan tugas tepat waktu',
    ],
  ),
  OnboardingQuestion(
    key: 'action_timing',
    prompt: 'When do you usually take action after setting a goal?',
    promptId: 'Kapan biasanya kamu mulai bertindak setelah menetapkan tujuan?',
    options: [
      'Right away',
      'Later (1–3 days)',
      'Waiting for the right time',
      'Need a reminder',
      'At the last minute',
    ],
    optionsId: [
      'Langsung saat itu juga',
      'Beberapa hari kemudian (1–3 hari)',
      'Menunggu waktu yang tepat',
      'Butuh pengingat',
      'Di menit-menit terakhir',
    ],
  ),
  OnboardingQuestion(
    key: 'motivation',
    prompt: 'What drives you to build good habits?',
    promptId: 'Apa yang mendorongmu untuk membangun kebiasaan baik?',
    options: [
      'Achieving goals',
      'Feeling better',
      'Improving health',
      'Becoming the person I want to be',
    ],
    optionsId: [
      'Mencapai tujuan',
      'Merasa lebih baik',
      'Meningkatkan kesehatan',
      'Menjadi pribadi yang saya inginkan',
    ],
  ),
];
