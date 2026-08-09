/// Onboarding lifestyle questionnaire questions (CLAUDE.md v3 §4.1 step 3).
class OnboardingQuestion {
  const OnboardingQuestion({
    required this.key,
    required this.prompt,
    required this.options,
  });

  /// Matches `OnboardingResponses.questionKey`.
  final String key;
  final String prompt;
  final List<String> options;
}

const List<OnboardingQuestion> lifestyleQuestions = [
  OnboardingQuestion(
    key: 'lifestyle_challenge',
    prompt: 'What do you often experience?',
    options: [
      'No clear goals',
      'Tend to procrastinate before starting tasks',
      'Often feel stressed or anxious',
      'Struggle to stay consistent with plans',
      'Struggle to finish tasks on time',
    ],
  ),
  OnboardingQuestion(
    key: 'action_timing',
    prompt: 'When do you usually take action after setting a goal?',
    options: [
      'Right away',
      'Later (1–3 days)',
      'Waiting for the right time',
      'Need a reminder',
      'At the last minute',
    ],
  ),
  OnboardingQuestion(
    key: 'motivation',
    prompt: 'What drives you to build good habits?',
    options: [
      'Achieving goals',
      'Feeling better',
      'Improving health',
      'Becoming the person I want to be',
    ],
  ),
];
