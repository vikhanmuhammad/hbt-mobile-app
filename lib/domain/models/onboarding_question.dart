/// Pertanyaan kuesioner gaya hidup onboarding (CLAUDE.md v3 §4.1 langkah 3).
class OnboardingQuestion {
  const OnboardingQuestion({
    required this.key,
    required this.prompt,
    required this.options,
  });

  /// Cocok dengan `OnboardingResponses.questionKey`.
  final String key;
  final String prompt;
  final List<String> options;
}

const List<OnboardingQuestion> lifestyleQuestions = [
  OnboardingQuestion(
    key: 'lifestyle_challenge',
    prompt: 'Apa yang sering kamu alami?',
    options: [
      'Tidak punya tujuan yang jelas',
      'Suka menunda sebelum memulai tugas',
      'Sering merasa stres atau cemas',
      'Susah konsisten dengan rencana',
      'Susah menyelesaikan tugas tepat waktu',
    ],
  ),
  OnboardingQuestion(
    key: 'action_timing',
    prompt: 'Kapan biasanya kamu bertindak setelah menetapkan tujuan?',
    options: [
      'Langsung',
      'Nanti (1–3 hari)',
      'Menunggu waktu yang tepat',
      'Butuh pengingat',
      'Di menit-menit terakhir',
    ],
  ),
  OnboardingQuestion(
    key: 'motivation',
    prompt: 'Apa yang mendorongmu membangun kebiasaan baik?',
    options: [
      'Mencapai tujuan',
      'Merasa lebih baik',
      'Meningkatkan kesehatan',
      'Menjadi versi diri yang diinginkan',
    ],
  ),
];
