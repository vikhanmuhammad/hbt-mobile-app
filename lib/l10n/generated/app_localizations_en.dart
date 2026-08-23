// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Daily Habits';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNoName => 'No Name';

  @override
  String get settingsProMember => 'Pro Member';

  @override
  String get settingsSectionSettings => 'Settings';

  @override
  String get settingsHabitManager => 'Habit Manager';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsSectionHealthCalendarSync => 'Health & Calendar Sync';

  @override
  String get settingsSectionProAccess => 'Pro Access';

  @override
  String get settingsSectionDefaultReminder => 'Default Reminder';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsUsageTips => 'Usage Tips';

  @override
  String get settingsFaqs => 'FAQs';

  @override
  String get settingsContactUs => 'Contact us';

  @override
  String get settingsShare => 'Share';

  @override
  String get settingsRestorePurchases => 'Restore Purchases';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsAboutBody =>
      'Built on research by Phillippa Lally et al. (UCL): a new habit takes on average 66 days of repetition to become automatic. Focus on consistency, not perfection.\n\nFully offline. All recommendations come from static data in the app, no account or cloud sync.';

  @override
  String get settingsReplayOnboarding => 'Replay the onboarding flow';

  @override
  String settingsNoEmailApp(String email) {
    return 'No email app found — reach us at $email';
  }

  @override
  String get settingsShareText =>
      'I\'m building better habits with Daily Habits — join me!';

  @override
  String get settingsSignInFirstToRestore =>
      'Sign in first to restore purchases.';

  @override
  String get settingsRestoringPurchases => 'Restoring purchases…';

  @override
  String get settingsDeleteAccountTitle => 'Delete account?';

  @override
  String get settingsDeleteAccountBody =>
      'This permanently deletes your Community account — group memberships, chat history, and Pro entitlement tied to it. Your local habit data on this device is not affected. This action cannot be undone.';

  @override
  String get settingsAccountDeleted => 'Account deleted.';

  @override
  String settingsDeleteAccountFailed(String error) {
    return 'Could not delete account: $error';
  }

  @override
  String get settingsDeleteAllDataTitle => 'Delete all data?';

  @override
  String get settingsDeleteAllDataBody =>
      'All categories, habits, and progress history will be permanently deleted, then the app returns to the onboarding flow from the start. This action cannot be undone.';

  @override
  String get settingsDeleteAll => 'Delete All';

  @override
  String get settingsProMode => 'Pro Mode';

  @override
  String settingsDefaultReminderTime(String time) {
    return 'Default reminder time: $time';
  }

  @override
  String get homeDone => 'Done';

  @override
  String get homeToday => 'Today';

  @override
  String get homeMyHabits => 'My Habits';

  @override
  String get homeCommunity => 'Community';

  @override
  String get homeDeleteHabitTitle => 'Delete this habit?';

  @override
  String homeDeleteHabitBody(String name) {
    return '\"$name\" and all of its progress history will be permanently deleted and will no longer count toward your Dashboard stats. This cannot be undone.';
  }

  @override
  String homeFailedToSaveProgress(String error) {
    return 'Failed to save progress: $error';
  }

  @override
  String get homeNoHabitsScheduledYet => 'No habits scheduled yet';

  @override
  String get homeEmptyStateHint =>
      'Tap the Add Habit button at the bottom left to add your first habit for today.';

  @override
  String get commonByHabit => 'By Habit';

  @override
  String get commonByCategory => 'By Category';

  @override
  String get financeProFeatureTitle => 'Finance — Pro Feature';

  @override
  String get financeProFeatureDescription =>
      'Track spending, savings, and saving habits in one monthly summary. Upgrade to Pro to unlock this feature.';

  @override
  String get financeProBenefit1 =>
      'Monthly spending & savings totals across all your finance habits';

  @override
  String get financeProBenefit2 =>
      'Daily spending trend chart so you can spot patterns early';

  @override
  String get financeProBenefit3 =>
      'Per-habit breakdown to see exactly where your money goes';

  @override
  String get financePeriodDaily => 'Daily';

  @override
  String get financePeriodWeekly => 'Weekly';

  @override
  String get financePeriodMonthly => 'Monthly';

  @override
  String financeFailedToLoad(String error) {
    return 'Failed to load finance summary: $error';
  }

  @override
  String get financeNoFinanceHabitsYet => 'No finance habits yet';

  @override
  String get financeEmptyHint =>
      'Add a Rupiah-unit habit (e.g. a daily spending cap in \"Save Money\") to start seeing a summary here.';

  @override
  String get financeTotalSpending => 'Total Spending';

  @override
  String financeOfBudget(String amount) {
    return 'of $amount budget';
  }

  @override
  String get financeSaveMoneyGoal => 'Save Money Goal';

  @override
  String get financeOverBudget => 'Over Budget';

  @override
  String get financeTotalSaved => 'Total Saved';

  @override
  String get financeTotalDeposited => 'Total Deposited';

  @override
  String get financeOnTrack => 'On Track';

  @override
  String get financeOverspending => 'Overspending';

  @override
  String get financeDailySpendingTrend => 'Daily Spending Trend';

  @override
  String get financeNoDataYet => 'No data yet';

  @override
  String dashboardFailedToLoadCalendar(String error) {
    return 'Failed to load calendar: $error';
  }

  @override
  String dashboardFailedToLoadDashboard(String error) {
    return 'Failed to load dashboard: $error';
  }

  @override
  String get dashboardFilterHabit => 'Filter Habit';

  @override
  String get dashboardSwipeToSeeMore => 'Swipe to see more';

  @override
  String get dashboardAll => 'All';

  @override
  String get dashboardNoHabitsScheduledToday => 'No habits scheduled today.';

  @override
  String dashboardFailedToUpdateProgress(String error) {
    return 'Failed to update progress: $error';
  }

  @override
  String dashboardDateToday(String date) {
    return '$date (Today)';
  }

  @override
  String get dashboardNoDataToShowYet => 'No data to show yet';

  @override
  String get dashboardEmptyHint =>
      'Start checking off habits today to get the dashboard filled in.';

  @override
  String dashboardDaysTracked(int count) {
    return '$count days tracked';
  }

  @override
  String get dashboardOverallAvgSuccessRate => 'Overall average success rate';

  @override
  String get dashboardMonthlyTrend => 'Monthly Trend';

  @override
  String get addHabitPickGoalPhrase => 'Pick a goal phrase for the new habit.';

  @override
  String addHabitFailedToLoadCategories(String error) {
    return 'Failed to load categories: $error';
  }

  @override
  String get addHabitCreateNewGoal => 'Create New Goal';

  @override
  String get addHabitFinanceProOnly =>
      'The Finance category (Save Money) is Pro-only. Upgrade to Pro to manage finance habits & see your savings summary.';

  @override
  String addHabitFreeLimitMessage(int limit) {
    return 'You\'ve reached the $limit active habit limit for Free users. Upgrade to Pro to add unlimited habits.';
  }

  @override
  String get addHabitNoRecommendations =>
      'No recommendations for this category yet.';

  @override
  String get addHabitAdd => 'Add';

  @override
  String get addHabitAddCustomHabit => '+ Add Custom Habit';

  @override
  String get addHabitAdded => 'Habit added';

  @override
  String addHabitFailedToAdd(String error) {
    return 'Failed to add habit: $error';
  }

  @override
  String get addHabitTitlePickGoalPhrase => 'Pick Goal Phrase';

  @override
  String get addHabitTitleAddHabit => 'Add Habit';

  @override
  String get addHabitTitleEditHabit => 'Edit Habit';

  @override
  String get addHabitTitleHabitForm => 'Habit Form';

  @override
  String get addHabitTitleNewGoal => 'New Goal';

  @override
  String get addHabitFieldHabitName => 'Habit Name';

  @override
  String get addHabitHintNameEn => 'Name (English)';

  @override
  String get addHabitHintNameId => 'Nama (Indonesia)';

  @override
  String get addHabitLockedNameNotice =>
      'Built into the app — the name can\'t be changed.';

  @override
  String get addHabitFieldIcon => 'Icon';

  @override
  String get addHabitChangeIcon => 'Change icon';

  @override
  String get addHabitFieldGoalPhrase => 'Goal Phrase';

  @override
  String get addHabitFieldGoalPeriod => 'Goal Period';

  @override
  String get addHabitFieldGoalValue => 'Goal Value';

  @override
  String get addHabitFieldUnit => 'Unit';

  @override
  String get addHabitUnitHintCustom => 'e.g. book pages';

  @override
  String get addHabitFieldTargetDirection => 'Target Direction';

  @override
  String get addHabitFieldTaskDays => 'Task Days';

  @override
  String get addHabitEveryDay => 'Every day';

  @override
  String get addHabitFieldTimeRange => 'Time Range';

  @override
  String get addHabitReminder => 'Reminder';

  @override
  String get addHabitFieldStartDate => 'Start Date';

  @override
  String get addHabitFieldEndDate => 'End Date';

  @override
  String get addHabitSetDate => 'Set date';

  @override
  String get addHabitNoLimit => 'No limit';

  @override
  String get addHabitNoTimeLimit => 'No time limit';

  @override
  String get addHabitSaveChanges => 'Save Changes';

  @override
  String get addHabitSaveHabit => 'Save Habit';

  @override
  String get addHabitNameRequired =>
      'Habit name (English & Indonesia) is required';

  @override
  String get addHabitPickGoalPhraseFirst => 'Pick a goal phrase first';

  @override
  String get addHabitPickAtLeastOneDay => 'Pick at least 1 active day';

  @override
  String get addHabitUpdated => 'Habit updated';

  @override
  String addHabitFailedToSave(String error) {
    return 'Failed to save habit: $error';
  }

  @override
  String get addHabitFieldGoalPhraseName => 'Goal Phrase Name';

  @override
  String get addHabitHintCatNameEn => 'Name (English), e.g. Hobby';

  @override
  String get addHabitHintCatNameId => 'Nama (Indonesia), mis. Hobi';

  @override
  String get addHabitFieldColor => 'Color';

  @override
  String get addHabitCreateGoal => 'Create Goal';

  @override
  String get addHabitCatNameRequired =>
      'Goal phrase name (English & Indonesia) is required';

  @override
  String addHabitFailedToCreateCategory(String error) {
    return 'Failed to create category: $error';
  }

  @override
  String get addHabitCommunityLockedNotice =>
      'This habit is linked to a Community group, so its target and schedule stay locked to match everyone tracking it. Unlink it from the group\'s Habits tab first to change them. Reminder settings are still yours to change.';

  @override
  String get unitNoUnit => 'No unit';

  @override
  String get unitMinute => 'Minute';

  @override
  String get unitHour => 'Hour';

  @override
  String get unitStep => 'Step';

  @override
  String get unitGlass => 'Glass';

  @override
  String get unitPage => 'Page';

  @override
  String get unitTime => 'Time';

  @override
  String get unitKilometer => 'Kilometer';

  @override
  String get unitRupiah => 'Rupiah';

  @override
  String get unitCustom => 'Custom...';

  @override
  String get communityProFeatureTitle => 'Community — Pro Feature';

  @override
  String get communityProFeatureDescription =>
      'Create/join habit groups with friends, compete via leaderboards, and chat in real-time. Upgrade to Pro to unlock this feature.';

  @override
  String get communityProBenefit1 =>
      'Create or join unlimited habit groups with friends and family';

  @override
  String get communityProBenefit2 =>
      'Compete on real-time leaderboards to stay motivated together';

  @override
  String get communityProBenefit3 =>
      'Group chat to cheer each other on and stay accountable';

  @override
  String get communityTitle => 'Community';

  @override
  String get communityCreateGroup => '+ Create Group';

  @override
  String get communityJoinViaCode => 'Join via Code';

  @override
  String communityMembersCount(int count) {
    return '$count members';
  }

  @override
  String get communitySignInTitle => 'Sign In to Continue';

  @override
  String get communitySignInBody =>
      'Community requires an account so your progress can be shared to a group.';

  @override
  String get communitySignInWithGoogle => 'Sign in with Google';

  @override
  String communityFailedToSignIn(String error) {
    return 'Failed to sign in: $error';
  }

  @override
  String get communityLogOut => 'Log out';

  @override
  String communityFailedToLoadGroups(String error) {
    return 'Failed to load groups: $error';
  }

  @override
  String get communityNoGroupsYet =>
      'No groups yet. Create a new group or join with an invite code from a friend.';

  @override
  String get communityLogOutTitle => 'Log out of Community?';

  @override
  String get communityLogOutBody =>
      'You\'ll need to sign in again to see or sync your groups. Your local habit data is not affected.';

  @override
  String get communityLogOutConfirm => 'Log Out';

  @override
  String get createGroupTitle => 'Create Group';

  @override
  String get createGroupNameLabel => 'Group Name';

  @override
  String get createGroupNameHint => 'e.g. Morning Run Squad';

  @override
  String createGroupFailed(String error) {
    return 'Failed to create group: $error';
  }

  @override
  String get joinGroupTitle => 'Join Group';

  @override
  String get joinGroupInviteCodeLabel => 'Invite Code';

  @override
  String get joinGroupInviteCodeHint => 'e.g. A1B2C3D4';

  @override
  String get joinGroupAskMember =>
      'Ask an existing group member for the invite code.';

  @override
  String get joinGroupInviteCodeNotFound => 'Invite code not found';

  @override
  String get joinGroupAlreadyMember => 'You\'re already a member of this group';

  @override
  String joinGroupFailed(String error) {
    return 'Failed to join: $error';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRemove => 'Remove';

  @override
  String get groupNotAvailable => 'This group is no longer available.';

  @override
  String groupFailedToLoad(String error) {
    return 'Failed to load group: $error';
  }

  @override
  String groupInviteCodeCopied(String code) {
    return 'Invite code \"$code\" copied';
  }

  @override
  String get groupPromoteAdminFirstTitle => 'Promote another admin first';

  @override
  String get groupPromoteAdminFirstBody =>
      'You\'re the only admin in this group. Make another member an admin before you leave, or delete the group instead.';

  @override
  String get groupLeaveOnlyMemberBody =>
      'You\'re the only member — leaving means you\'ll need the invite code to rejoin later. Delete the group instead if you want to remove it for good.';

  @override
  String groupLeaveNeedInviteBody(String name) {
    return 'You\'ll need a new invite code to rejoin \"$name\" later.';
  }

  @override
  String get groupLeaveTitle => 'Leave group?';

  @override
  String get groupLeaveConfirm => 'Leave';

  @override
  String groupLeftMessage(String name) {
    return 'You left \"$name\".';
  }

  @override
  String groupFailedToLeave(String error) {
    return 'Failed to leave group: $error';
  }

  @override
  String get groupDeleteTitle => 'Delete group?';

  @override
  String groupDeleteBody(String name) {
    return 'This permanently deletes \"$name\", its Group Habits, and its invite code for everyone in it. This can\'t be undone.';
  }

  @override
  String groupDeletedMessage(String name) {
    return '\"$name\" was deleted.';
  }

  @override
  String groupFailedToDelete(String error) {
    return 'Failed to delete group: $error';
  }

  @override
  String get groupCopyInviteCode => 'Copy invite code';

  @override
  String get groupLeaveGroup => 'Leave Group';

  @override
  String get groupDeleteGroup => 'Delete Group';

  @override
  String get groupTabHabits => 'Habits';

  @override
  String get groupTabLeaderboard => 'Leaderboard';

  @override
  String get groupTabChat => 'Chat';

  @override
  String get groupTabMembers => 'Members';

  @override
  String groupFailedToLoadGeneric(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get groupNoHabitsYetBody =>
      'You don\'t have any habits yet — add one from Home first, then come back here to bring it online with the group.';

  @override
  String get groupYourHabits => 'Your Habits';

  @override
  String get groupCommunityHabits => 'Community Habits';

  @override
  String get groupLinked => 'Linked';

  @override
  String get groupAlreadyTrackedViaOther =>
      'Already tracked in this group via another habit of yours';

  @override
  String get groupMatchesExisting => 'Matches an existing community habit';

  @override
  String get groupLinkAction => 'Link';

  @override
  String get groupPublishAction => 'Publish';

  @override
  String groupFailedToLink(String error) {
    return 'Failed to link: $error';
  }

  @override
  String get groupRemoveFromCommunity => 'Remove from community';

  @override
  String get groupReconnectBefore =>
      'You tracked this before — reconnect to resume';

  @override
  String get groupReconnectAction => 'Reconnect';

  @override
  String get groupAddToMyHabits => 'Add to My Habits';

  @override
  String groupLinkedTo(String name) {
    return 'Linked to \"$name\"';
  }

  @override
  String get groupUnlink => 'Unlink';

  @override
  String groupFailedToUnlink(String error) {
    return 'Failed to unlink: $error';
  }

  @override
  String get groupNoLeaderboardYetBody =>
      'No habits yet. Go to the Habits tab and publish one of your own to start the first leaderboard.';

  @override
  String get leaderboardStreak => 'Streak';

  @override
  String get leaderboardProgress => 'Progress';

  @override
  String leaderboardFailedToLoad(String error) {
    return 'Failed to load leaderboard: $error';
  }

  @override
  String get leaderboardNoProgressYet => 'No progress recorded yet.';

  @override
  String get leaderboardDaysUnit => 'days';

  @override
  String leaderboardStreakLabel(int count) {
    return '$count-day streak';
  }

  @override
  String leaderboardTotalLabel(String count, String unit) {
    return '$count $unit total';
  }

  @override
  String get leaderboardYouSuffix => ' (You)';

  @override
  String get leaderboardJustNow => 'just now';

  @override
  String leaderboardMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String leaderboardHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String leaderboardDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String leaderboardUpdatedLabel(String label, String time) {
    return '$label • Updated $time';
  }

  @override
  String get groupNoGoalPhraseAvailable => 'No goal phrase available yet';

  @override
  String get groupAddToHabitsTitle => 'Add to your habits?';

  @override
  String groupAddToHabitsBody(String name, String target, String period) {
    return '\"$name\" ($target · $period) will be added to your habit list, tracked exactly as published in this group.';
  }

  @override
  String groupAddedRestored(String name, int count) {
    return 'Added \"$name\" — restored $count day(s) of history';
  }

  @override
  String groupLinkedExistingHabit(String name) {
    return 'Linked your existing \"$name\" habit';
  }

  @override
  String groupAddedPlain(String name) {
    return 'Added \"$name\" to your habits';
  }

  @override
  String groupAddedRestoreFailed(String name, String error) {
    return 'Added \"$name\", but restoring past history failed: $error';
  }

  @override
  String groupFailedToAddHabit(String error) {
    return 'Failed to add habit: $error';
  }

  @override
  String get groupRemoveFromCommunityTitle => 'Remove from community?';

  @override
  String groupRemoveFromCommunityBody(String name) {
    return '\"$name\" and its leaderboard will be removed for everyone in the group. Everyone\'s own local habit and progress history stay untouched — this can\'t be undone.';
  }

  @override
  String groupFailedToRemove(String error) {
    return 'Failed to remove: $error';
  }

  @override
  String chatFailedToSend(String error) {
    return 'Failed to send message: $error';
  }

  @override
  String chatFailedToLoad(String error) {
    return 'Failed to load chat: $error';
  }

  @override
  String get chatNoMessagesYet => 'No messages yet. Start the conversation!';

  @override
  String get chatWriteMessageHint => 'Write a message...';

  @override
  String get membersInviteCodeLabel => 'Invite Code';

  @override
  String get membersMakeAdmin => 'Make Admin';

  @override
  String get membersRemoveAdmin => 'Remove Admin';

  @override
  String get membersRemove => 'Remove';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqQ1 => 'Why is this app fully offline?';

  @override
  String get faqA1 =>
      'So your daily habit data stays private and can be used anytime without needing an internet connection. No account, no server, no tracking.';

  @override
  String get faqQ2 => 'How is my data stored and is it safe?';

  @override
  String get faqA2 =>
      'All data (categories, habits, progress history, profile) is stored in a local database on your own device — never sent anywhere.';

  @override
  String get faqQ3 => 'What if I switch phones? Does my data move too?';

  @override
  String get faqA3 =>
      'Since there\'s no cloud sync, data doesn\'t transfer automatically. Use the Export Data feature in Settings (coming soon) to make a manual backup before switching devices, then Import Data on the new phone.';

  @override
  String get faqQ4 => 'Do I need to log in or sign up for an account?';

  @override
  String get faqA4 =>
      'No. This app has no account system at all — open it and start using it right away.';

  @override
  String get usageTipsTitle => 'Usage Tips';

  @override
  String get usageTip1Title => 'Use Reminders';

  @override
  String get usageTip1Body =>
      'When adding or editing a habit, turn on the Reminder toggle and set a time. The app will send a local notification at that time on the habit\'s active days.';

  @override
  String get usageTip2Title => 'Backfill Progress';

  @override
  String get usageTip2Body =>
      'From the Dashboard tab, tap a past date on the calendar to see that day\'s habit detail. You can still mark/change progress for previous days from there.';

  @override
  String get usageTip3Title => 'Change Theme';

  @override
  String get usageTip3Body =>
      'Open Settings > Personalize to pick one of 5 color palettes. The change applies instantly throughout the app.';

  @override
  String get usageTip4Title => 'Use Edit Mode';

  @override
  String get usageTip4Body =>
      'Tap the pencil button at the bottom right of Home to enter Edit Mode — from there you can reorder (drag), edit, or deactivate habits. Tap the check button or \"Done\" to exit.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNameEmpty => 'Name cannot be empty';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profilePhotoNotAvailable =>
      'Profile photo is not available in this version yet';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileNameHint => 'Your name';

  @override
  String get profileAgeLabel => 'Age';

  @override
  String get profileAgeHint => 'e.g. 25';

  @override
  String get profileSaving => 'Saving...';

  @override
  String get profileSave => 'Save';

  @override
  String get personalizeTitle => 'Personalize';

  @override
  String get personalizeDescription =>
      'Pick the color theme you like best. This color is used for buttons, progress rings, and accents throughout the app.';

  @override
  String get healthSyncStepsLabel => 'Sync steps from Health app';

  @override
  String get healthSyncCalendarLabel => 'Sync reminders to Calendar';

  @override
  String get healthSyncAlarmLabel => 'Sync reminders to phone Alarm';

  @override
  String healthSyncDeniedMessage(String feature) {
    return '$feature was denied or unavailable on this device.';
  }

  @override
  String get healthSyncFeatureHealth => 'Health access';

  @override
  String get healthSyncFeatureCalendar => 'Calendar access';

  @override
  String get iconPickerChooseIcon => 'Choose Icon';

  @override
  String get iconPickerSearchHint => 'Search icons...';

  @override
  String get iconPickerNoIconsFound => 'No icons found';

  @override
  String get proFeatureUpgradeButton => 'Upgrade to Pro';

  @override
  String proFeatureSignInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get proFeatureCouldNotLoadPlans =>
      'Could not load subscription plans. Try again later.';

  @override
  String get proFeatureNoPlansAvailable =>
      'No subscription plans available right now.';

  @override
  String get proFeatureChooseYourPlan => 'Choose your plan';

  @override
  String get proFeatureTitle => 'Pro Feature';

  @override
  String get quickProgressOrEnterManually => 'or enter manually';

  @override
  String quickProgressTarget(String label) {
    return 'Target: $label';
  }

  @override
  String get quickProgressMarkAchieved => 'Mark Achieved';

  @override
  String get commonSave => 'Save';

  @override
  String get timerLabel => 'TIMER';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerStart => 'Start';

  @override
  String get financeTitle => 'Finance';

  @override
  String get onboardingFinanceProFeature => 'Finance tracking is a Pro feature';

  @override
  String get onboardingCancelHabit => 'Cancel this habit';

  @override
  String get navHome => 'Home';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCommunity => 'Community';

  @override
  String get navFinance => 'Finance';

  @override
  String get navSettings => 'Settings';
}
