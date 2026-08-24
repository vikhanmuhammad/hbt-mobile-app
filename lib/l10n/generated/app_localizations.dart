import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// App name shown in the OS task switcher / title bar.
  ///
  /// In en, this message translates to:
  /// **'Daily Habits'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// Label for the app language switcher on the Settings screen.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNoName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get settingsNoName;

  /// No description provided for @settingsProMember.
  ///
  /// In en, this message translates to:
  /// **'Pro Member'**
  String get settingsProMember;

  /// No description provided for @settingsSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSectionSettings;

  /// No description provided for @settingsHabitManager.
  ///
  /// In en, this message translates to:
  /// **'Habit Manager'**
  String get settingsHabitManager;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSectionHealthCalendarSync.
  ///
  /// In en, this message translates to:
  /// **'Health & Calendar Sync'**
  String get settingsSectionHealthCalendarSync;

  /// No description provided for @settingsSectionProAccess.
  ///
  /// In en, this message translates to:
  /// **'Pro Access'**
  String get settingsSectionProAccess;

  /// No description provided for @settingsSectionDefaultReminder.
  ///
  /// In en, this message translates to:
  /// **'Default Reminder'**
  String get settingsSectionDefaultReminder;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsUsageTips.
  ///
  /// In en, this message translates to:
  /// **'Usage Tips'**
  String get settingsUsageTips;

  /// No description provided for @settingsFaqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get settingsFaqs;

  /// No description provided for @settingsContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settingsContactUs;

  /// No description provided for @settingsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get settingsShare;

  /// No description provided for @settingsRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get settingsRestorePurchases;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Built on research by Phillippa Lally et al. (UCL): a new habit takes on average 66 days of repetition to become automatic. Focus on consistency, not perfection.\n\nFully offline. All recommendations come from static data in the app, no account or cloud sync.'**
  String get settingsAboutBody;

  /// No description provided for @settingsReplayOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Replay the onboarding flow'**
  String get settingsReplayOnboarding;

  /// No description provided for @settingsNoEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found — reach us at {email}'**
  String settingsNoEmailApp(String email);

  /// No description provided for @settingsShareText.
  ///
  /// In en, this message translates to:
  /// **'I\'m building better habits with Daily Habits — join me!'**
  String get settingsShareText;

  /// No description provided for @settingsSignInFirstToRestore.
  ///
  /// In en, this message translates to:
  /// **'Sign in first to restore purchases.'**
  String get settingsSignInFirstToRestore;

  /// No description provided for @settingsRestoringPurchases.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases…'**
  String get settingsRestoringPurchases;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your Community account — group memberships, chat history, and Pro entitlement tied to it. Your local habit data on this device is not affected. This action cannot be undone.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get settingsAccountDeleted;

  /// No description provided for @settingsDeleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account: {error}'**
  String settingsDeleteAccountFailed(String error);

  /// No description provided for @settingsDeleteAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get settingsDeleteAllDataTitle;

  /// No description provided for @settingsDeleteAllDataBody.
  ///
  /// In en, this message translates to:
  /// **'All categories, habits, and progress history will be permanently deleted, then the app returns to the onboarding flow from the start. This action cannot be undone.'**
  String get settingsDeleteAllDataBody;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get settingsDeleteAll;

  /// No description provided for @settingsProMode.
  ///
  /// In en, this message translates to:
  /// **'Pro Mode'**
  String get settingsProMode;

  /// No description provided for @settingsDefaultReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Default reminder time: {time}'**
  String settingsDefaultReminderTime(String time);

  /// No description provided for @homeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get homeDone;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeMyHabits.
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get homeMyHabits;

  /// No description provided for @homeCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get homeCommunity;

  /// No description provided for @homeDeleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this habit?'**
  String get homeDeleteHabitTitle;

  /// No description provided for @homeDeleteHabitBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and all of its progress history will be permanently deleted and will no longer count toward your Dashboard stats. This cannot be undone.'**
  String homeDeleteHabitBody(String name);

  /// No description provided for @homeHabitDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted.'**
  String homeHabitDeleted(String name);

  /// No description provided for @homeFailedToSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Failed to save progress: {error}'**
  String homeFailedToSaveProgress(String error);

  /// No description provided for @homeNoHabitsScheduledYet.
  ///
  /// In en, this message translates to:
  /// **'No habits scheduled yet'**
  String get homeNoHabitsScheduledYet;

  /// No description provided for @homeEmptyStateHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the Add Habit button at the bottom left to add your first habit for today.'**
  String get homeEmptyStateHint;

  /// No description provided for @commonByHabit.
  ///
  /// In en, this message translates to:
  /// **'By Habit'**
  String get commonByHabit;

  /// No description provided for @commonByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get commonByCategory;

  /// No description provided for @financeProFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance — Pro Feature'**
  String get financeProFeatureTitle;

  /// No description provided for @financeProFeatureDescription.
  ///
  /// In en, this message translates to:
  /// **'Track spending, savings, and saving habits in one monthly summary. Upgrade to Pro to unlock this feature.'**
  String get financeProFeatureDescription;

  /// No description provided for @financeProBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending & savings totals across all your finance habits'**
  String get financeProBenefit1;

  /// No description provided for @financeProBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Daily spending trend chart so you can spot patterns early'**
  String get financeProBenefit2;

  /// No description provided for @financeProBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Per-habit breakdown to see exactly where your money goes'**
  String get financeProBenefit3;

  /// No description provided for @financePeriodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get financePeriodDaily;

  /// No description provided for @financePeriodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get financePeriodWeekly;

  /// No description provided for @financePeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get financePeriodMonthly;

  /// No description provided for @financeFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load finance summary: {error}'**
  String financeFailedToLoad(String error);

  /// No description provided for @financeNoFinanceHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No finance habits yet'**
  String get financeNoFinanceHabitsYet;

  /// No description provided for @financeEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a Rupiah-unit habit (e.g. a daily spending cap in \"Save Money\") to start seeing a summary here.'**
  String get financeEmptyHint;

  /// No description provided for @financeTotalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total Spending'**
  String get financeTotalSpending;

  /// No description provided for @financeOfBudget.
  ///
  /// In en, this message translates to:
  /// **'of {amount} budget'**
  String financeOfBudget(String amount);

  /// No description provided for @financeSaveMoneyGoal.
  ///
  /// In en, this message translates to:
  /// **'Save Money Goal'**
  String get financeSaveMoneyGoal;

  /// No description provided for @financeOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get financeOverBudget;

  /// No description provided for @financeTotalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get financeTotalSaved;

  /// No description provided for @financeTotalDeposited.
  ///
  /// In en, this message translates to:
  /// **'Total Deposited'**
  String get financeTotalDeposited;

  /// No description provided for @financeOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get financeOnTrack;

  /// No description provided for @financeOverspending.
  ///
  /// In en, this message translates to:
  /// **'Overspending'**
  String get financeOverspending;

  /// No description provided for @financeDailySpendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily Spending Trend'**
  String get financeDailySpendingTrend;

  /// No description provided for @financeWeeklySpendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Spending Trend'**
  String get financeWeeklySpendingTrend;

  /// No description provided for @financeMonthlySpendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spending Trend'**
  String get financeMonthlySpendingTrend;

  /// No description provided for @financeSpendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get financeSpendingByCategory;

  /// No description provided for @financeAddSpendingLimit.
  ///
  /// In en, this message translates to:
  /// **'Add Spending Limit'**
  String get financeAddSpendingLimit;

  /// No description provided for @commonProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get commonProgress;

  /// No description provided for @commonGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get commonGoal;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderHint.
  ///
  /// In en, this message translates to:
  /// **'Select a gender'**
  String get genderHint;

  /// No description provided for @settingsAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age} y/o'**
  String settingsAgeYears(int age);

  /// No description provided for @addHabitReminderRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get addHabitReminderRepeat;

  /// No description provided for @addHabitReminderOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get addHabitReminderOnce;

  /// No description provided for @addHabitReminderEveryMinutes.
  ///
  /// In en, this message translates to:
  /// **'Every {minutes} min'**
  String addHabitReminderEveryMinutes(int minutes);

  /// No description provided for @financeNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get financeNoDataYet;

  /// No description provided for @dashboardFailedToLoadCalendar.
  ///
  /// In en, this message translates to:
  /// **'Failed to load calendar: {error}'**
  String dashboardFailedToLoadCalendar(String error);

  /// No description provided for @dashboardFailedToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard: {error}'**
  String dashboardFailedToLoadDashboard(String error);

  /// No description provided for @dashboardFilterHabit.
  ///
  /// In en, this message translates to:
  /// **'Filter Habit'**
  String get dashboardFilterHabit;

  /// No description provided for @dashboardSwipeToSeeMore.
  ///
  /// In en, this message translates to:
  /// **'Swipe to see more'**
  String get dashboardSwipeToSeeMore;

  /// No description provided for @dashboardAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dashboardAll;

  /// No description provided for @dashboardNoHabitsScheduledToday.
  ///
  /// In en, this message translates to:
  /// **'No habits scheduled today.'**
  String get dashboardNoHabitsScheduledToday;

  /// No description provided for @dashboardFailedToUpdateProgress.
  ///
  /// In en, this message translates to:
  /// **'Failed to update progress: {error}'**
  String dashboardFailedToUpdateProgress(String error);

  /// No description provided for @dashboardDateToday.
  ///
  /// In en, this message translates to:
  /// **'{date} (Today)'**
  String dashboardDateToday(String date);

  /// No description provided for @dashboardNoDataToShowYet.
  ///
  /// In en, this message translates to:
  /// **'No data to show yet'**
  String get dashboardNoDataToShowYet;

  /// No description provided for @dashboardEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Start checking off habits today to get the dashboard filled in.'**
  String get dashboardEmptyHint;

  /// No description provided for @dashboardDaysTracked.
  ///
  /// In en, this message translates to:
  /// **'{count} days tracked'**
  String dashboardDaysTracked(int count);

  /// No description provided for @dashboardOverallAvgSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Overall average success rate'**
  String get dashboardOverallAvgSuccessRate;

  /// No description provided for @dashboardMonthlyTrend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Trend'**
  String get dashboardMonthlyTrend;

  /// No description provided for @addHabitPickGoalPhrase.
  ///
  /// In en, this message translates to:
  /// **'Pick a goal phrase for the new habit.'**
  String get addHabitPickGoalPhrase;

  /// No description provided for @addHabitFailedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories: {error}'**
  String addHabitFailedToLoadCategories(String error);

  /// No description provided for @addHabitCreateNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Create New Goal'**
  String get addHabitCreateNewGoal;

  /// No description provided for @addHabitFinanceProOnly.
  ///
  /// In en, this message translates to:
  /// **'The Finance category (Save Money) is Pro-only. Upgrade to Pro to manage finance habits & see your savings summary.'**
  String get addHabitFinanceProOnly;

  /// No description provided for @addHabitFreeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the {limit} active habit limit for Free users. Upgrade to Pro to add unlimited habits.'**
  String addHabitFreeLimitMessage(int limit);

  /// No description provided for @addHabitNoRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations for this category yet.'**
  String get addHabitNoRecommendations;

  /// No description provided for @addHabitAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get addHabitAlreadyAdded;

  /// No description provided for @addHabitDuplicateName.
  ///
  /// In en, this message translates to:
  /// **'You already have a habit with this name.'**
  String get addHabitDuplicateName;

  /// No description provided for @addHabitAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addHabitAdd;

  /// No description provided for @addHabitAddCustomHabit.
  ///
  /// In en, this message translates to:
  /// **'+ Add Custom Habit'**
  String get addHabitAddCustomHabit;

  /// No description provided for @addHabitAdded.
  ///
  /// In en, this message translates to:
  /// **'Habit added'**
  String get addHabitAdded;

  /// No description provided for @addHabitFailedToAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add habit: {error}'**
  String addHabitFailedToAdd(String error);

  /// No description provided for @addHabitTitlePickGoalPhrase.
  ///
  /// In en, this message translates to:
  /// **'Pick Goal Phrase'**
  String get addHabitTitlePickGoalPhrase;

  /// No description provided for @addHabitTitleAddHabit.
  ///
  /// In en, this message translates to:
  /// **'Add Habit'**
  String get addHabitTitleAddHabit;

  /// No description provided for @addHabitTitleEditHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get addHabitTitleEditHabit;

  /// No description provided for @addHabitTitleHabitForm.
  ///
  /// In en, this message translates to:
  /// **'Habit Form'**
  String get addHabitTitleHabitForm;

  /// No description provided for @addHabitTitleNewGoal.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get addHabitTitleNewGoal;

  /// No description provided for @addHabitFieldHabitName.
  ///
  /// In en, this message translates to:
  /// **'Habit Name'**
  String get addHabitFieldHabitName;

  /// No description provided for @addHabitHintNameEn.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get addHabitHintNameEn;

  /// No description provided for @addHabitHintNameId.
  ///
  /// In en, this message translates to:
  /// **'Nama (Indonesia)'**
  String get addHabitHintNameId;

  /// No description provided for @addHabitLockedNameNotice.
  ///
  /// In en, this message translates to:
  /// **'Built into the app — the name can\'t be changed.'**
  String get addHabitLockedNameNotice;

  /// No description provided for @addHabitFieldIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get addHabitFieldIcon;

  /// No description provided for @addHabitChangeIcon.
  ///
  /// In en, this message translates to:
  /// **'Change icon'**
  String get addHabitChangeIcon;

  /// No description provided for @addHabitFieldGoalPhrase.
  ///
  /// In en, this message translates to:
  /// **'Goal Phrase'**
  String get addHabitFieldGoalPhrase;

  /// No description provided for @addHabitFieldGoalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Goal Period'**
  String get addHabitFieldGoalPeriod;

  /// No description provided for @addHabitFieldGoalValue.
  ///
  /// In en, this message translates to:
  /// **'Goal Value'**
  String get addHabitFieldGoalValue;

  /// No description provided for @addHabitFieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get addHabitFieldUnit;

  /// No description provided for @addHabitUnitHintCustom.
  ///
  /// In en, this message translates to:
  /// **'e.g. book pages'**
  String get addHabitUnitHintCustom;

  /// No description provided for @addHabitFieldTargetDirection.
  ///
  /// In en, this message translates to:
  /// **'Target Direction'**
  String get addHabitFieldTargetDirection;

  /// No description provided for @addHabitFieldTaskDays.
  ///
  /// In en, this message translates to:
  /// **'Task Days'**
  String get addHabitFieldTaskDays;

  /// No description provided for @addHabitEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get addHabitEveryDay;

  /// No description provided for @addHabitFieldTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get addHabitFieldTimeRange;

  /// No description provided for @addHabitReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get addHabitReminder;

  /// No description provided for @addHabitFieldStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get addHabitFieldStartDate;

  /// No description provided for @addHabitFieldEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get addHabitFieldEndDate;

  /// No description provided for @addHabitSetDate.
  ///
  /// In en, this message translates to:
  /// **'Set date'**
  String get addHabitSetDate;

  /// No description provided for @addHabitNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get addHabitNoLimit;

  /// No description provided for @addHabitNoTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'No time limit'**
  String get addHabitNoTimeLimit;

  /// No description provided for @addHabitSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get addHabitSaveChanges;

  /// No description provided for @addHabitSaveHabit.
  ///
  /// In en, this message translates to:
  /// **'Save Habit'**
  String get addHabitSaveHabit;

  /// No description provided for @addHabitNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Habit name (English & Indonesia) is required'**
  String get addHabitNameRequired;

  /// No description provided for @addHabitPickGoalPhraseFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a goal phrase first'**
  String get addHabitPickGoalPhraseFirst;

  /// No description provided for @addHabitPickAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Pick at least 1 active day'**
  String get addHabitPickAtLeastOneDay;

  /// No description provided for @addHabitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Habit updated'**
  String get addHabitUpdated;

  /// No description provided for @addHabitFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save habit: {error}'**
  String addHabitFailedToSave(String error);

  /// No description provided for @addHabitFieldGoalPhraseName.
  ///
  /// In en, this message translates to:
  /// **'Goal Phrase Name'**
  String get addHabitFieldGoalPhraseName;

  /// No description provided for @addHabitHintCatNameEn.
  ///
  /// In en, this message translates to:
  /// **'Name (English), e.g. Hobby'**
  String get addHabitHintCatNameEn;

  /// No description provided for @addHabitHintCatNameId.
  ///
  /// In en, this message translates to:
  /// **'Nama (Indonesia), mis. Hobi'**
  String get addHabitHintCatNameId;

  /// No description provided for @addHabitFieldColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get addHabitFieldColor;

  /// No description provided for @addHabitCreateGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get addHabitCreateGoal;

  /// No description provided for @addHabitCatNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Goal phrase name (English & Indonesia) is required'**
  String get addHabitCatNameRequired;

  /// No description provided for @addHabitFailedToCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Failed to create category: {error}'**
  String addHabitFailedToCreateCategory(String error);

  /// No description provided for @addHabitCommunityLockedNotice.
  ///
  /// In en, this message translates to:
  /// **'This habit is linked to a Community group, so its target and schedule stay locked to match everyone tracking it. Unlink it from the group\'s Habits tab first to change them. Reminder settings are still yours to change.'**
  String get addHabitCommunityLockedNotice;

  /// No description provided for @unitNoUnit.
  ///
  /// In en, this message translates to:
  /// **'No unit'**
  String get unitNoUnit;

  /// No description provided for @unitMinute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get unitMinute;

  /// No description provided for @unitHour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get unitHour;

  /// No description provided for @unitStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get unitStep;

  /// No description provided for @unitGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get unitGlass;

  /// No description provided for @unitPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get unitPage;

  /// No description provided for @unitTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get unitTime;

  /// No description provided for @unitKilometer.
  ///
  /// In en, this message translates to:
  /// **'Kilometer'**
  String get unitKilometer;

  /// No description provided for @unitRupiah.
  ///
  /// In en, this message translates to:
  /// **'Rupiah'**
  String get unitRupiah;

  /// No description provided for @unitCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom...'**
  String get unitCustom;

  /// No description provided for @communityProFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Community — Pro Feature'**
  String get communityProFeatureTitle;

  /// No description provided for @communityProFeatureDescription.
  ///
  /// In en, this message translates to:
  /// **'Create/join habit groups with friends, compete via leaderboards, and chat in real-time. Upgrade to Pro to unlock this feature.'**
  String get communityProFeatureDescription;

  /// No description provided for @communityProBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Create or join unlimited habit groups with friends and family'**
  String get communityProBenefit1;

  /// No description provided for @communityProBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Compete on real-time leaderboards to stay motivated together'**
  String get communityProBenefit2;

  /// No description provided for @communityProBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Group chat to cheer each other on and stay accountable'**
  String get communityProBenefit3;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTitle;

  /// No description provided for @communityCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'+ Create Group'**
  String get communityCreateGroup;

  /// No description provided for @communityJoinViaCode.
  ///
  /// In en, this message translates to:
  /// **'Join via Code'**
  String get communityJoinViaCode;

  /// No description provided for @communityMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String communityMembersCount(int count);

  /// No description provided for @communitySignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Continue'**
  String get communitySignInTitle;

  /// No description provided for @communitySignInBody.
  ///
  /// In en, this message translates to:
  /// **'Community requires an account so your progress can be shared to a group.'**
  String get communitySignInBody;

  /// No description provided for @communitySignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get communitySignInWithGoogle;

  /// No description provided for @communityFailedToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in: {error}'**
  String communityFailedToSignIn(String error);

  /// No description provided for @communityLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get communityLogOut;

  /// No description provided for @communityFailedToLoadGroups.
  ///
  /// In en, this message translates to:
  /// **'Failed to load groups: {error}'**
  String communityFailedToLoadGroups(String error);

  /// No description provided for @communityNoGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet. Create a new group or join with an invite code from a friend.'**
  String get communityNoGroupsYet;

  /// No description provided for @communityLogOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of Community?'**
  String get communityLogOutTitle;

  /// No description provided for @communityLogOutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to see or sync your groups. Your local habit data is not affected.'**
  String get communityLogOutBody;

  /// No description provided for @communityLogOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get communityLogOutConfirm;

  /// No description provided for @createGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroupTitle;

  /// No description provided for @createGroupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get createGroupNameLabel;

  /// No description provided for @createGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning Run Squad'**
  String get createGroupNameHint;

  /// No description provided for @createGroupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create group: {error}'**
  String createGroupFailed(String error);

  /// No description provided for @joinGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroupTitle;

  /// No description provided for @joinGroupInviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get joinGroupInviteCodeLabel;

  /// No description provided for @joinGroupInviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. A1B2C3D4'**
  String get joinGroupInviteCodeHint;

  /// No description provided for @joinGroupAskMember.
  ///
  /// In en, this message translates to:
  /// **'Ask an existing group member for the invite code.'**
  String get joinGroupAskMember;

  /// No description provided for @joinGroupInviteCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invite code not found'**
  String get joinGroupInviteCodeNotFound;

  /// No description provided for @joinGroupAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re already a member of this group'**
  String get joinGroupAlreadyMember;

  /// No description provided for @joinGroupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to join: {error}'**
  String joinGroupFailed(String error);

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @groupNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This group is no longer available.'**
  String get groupNotAvailable;

  /// No description provided for @groupFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load group: {error}'**
  String groupFailedToLoad(String error);

  /// No description provided for @groupInviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code \"{code}\" copied'**
  String groupInviteCodeCopied(String code);

  /// No description provided for @groupPromoteAdminFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Promote another admin first'**
  String get groupPromoteAdminFirstTitle;

  /// No description provided for @groupPromoteAdminFirstBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re the only admin in this group. Make another member an admin before you leave, or delete the group instead.'**
  String get groupPromoteAdminFirstBody;

  /// No description provided for @groupLeaveOnlyMemberBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re the only member — leaving means you\'ll need the invite code to rejoin later. Delete the group instead if you want to remove it for good.'**
  String get groupLeaveOnlyMemberBody;

  /// No description provided for @groupLeaveNeedInviteBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need a new invite code to rejoin \"{name}\" later.'**
  String groupLeaveNeedInviteBody(String name);

  /// No description provided for @groupLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave group?'**
  String get groupLeaveTitle;

  /// No description provided for @groupLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get groupLeaveConfirm;

  /// No description provided for @groupLeftMessage.
  ///
  /// In en, this message translates to:
  /// **'You left \"{name}\".'**
  String groupLeftMessage(String name);

  /// No description provided for @groupFailedToLeave.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave group: {error}'**
  String groupFailedToLeave(String error);

  /// No description provided for @groupDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group?'**
  String get groupDeleteTitle;

  /// No description provided for @groupDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes \"{name}\", its Group Habits, and its invite code for everyone in it. This can\'t be undone.'**
  String groupDeleteBody(String name);

  /// No description provided for @groupDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was deleted.'**
  String groupDeletedMessage(String name);

  /// No description provided for @groupFailedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete group: {error}'**
  String groupFailedToDelete(String error);

  /// No description provided for @groupCopyInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Copy invite code'**
  String get groupCopyInviteCode;

  /// No description provided for @groupLeaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get groupLeaveGroup;

  /// No description provided for @groupDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get groupDeleteGroup;

  /// No description provided for @groupTabHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get groupTabHabits;

  /// No description provided for @groupTabLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get groupTabLeaderboard;

  /// No description provided for @groupTabChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get groupTabChat;

  /// No description provided for @groupTabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupTabMembers;

  /// No description provided for @groupFailedToLoadGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String groupFailedToLoadGeneric(String error);

  /// No description provided for @groupNoHabitsYetBody.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any habits yet — add one from Home first, then come back here to bring it online with the group.'**
  String get groupNoHabitsYetBody;

  /// No description provided for @groupYourHabits.
  ///
  /// In en, this message translates to:
  /// **'Your Habits'**
  String get groupYourHabits;

  /// No description provided for @groupCommunityHabits.
  ///
  /// In en, this message translates to:
  /// **'Community Habits'**
  String get groupCommunityHabits;

  /// No description provided for @groupLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get groupLinked;

  /// No description provided for @groupAlreadyTrackedViaOther.
  ///
  /// In en, this message translates to:
  /// **'Already tracked in this group via another habit of yours'**
  String get groupAlreadyTrackedViaOther;

  /// No description provided for @groupMatchesExisting.
  ///
  /// In en, this message translates to:
  /// **'Matches an existing community habit'**
  String get groupMatchesExisting;

  /// No description provided for @groupLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get groupLinkAction;

  /// No description provided for @groupPublishAction.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get groupPublishAction;

  /// No description provided for @groupFailedToLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to link: {error}'**
  String groupFailedToLink(String error);

  /// No description provided for @groupRemoveFromCommunity.
  ///
  /// In en, this message translates to:
  /// **'Remove from community'**
  String get groupRemoveFromCommunity;

  /// No description provided for @groupReconnectBefore.
  ///
  /// In en, this message translates to:
  /// **'You tracked this before — reconnect to resume'**
  String get groupReconnectBefore;

  /// No description provided for @groupReconnectAction.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get groupReconnectAction;

  /// No description provided for @groupAddToMyHabits.
  ///
  /// In en, this message translates to:
  /// **'Add to My Habits'**
  String get groupAddToMyHabits;

  /// No description provided for @groupLinkedTo.
  ///
  /// In en, this message translates to:
  /// **'Linked to \"{name}\"'**
  String groupLinkedTo(String name);

  /// No description provided for @groupUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get groupUnlink;

  /// No description provided for @groupFailedToUnlink.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink: {error}'**
  String groupFailedToUnlink(String error);

  /// No description provided for @groupNoLeaderboardYetBody.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Go to the Habits tab and publish one of your own to start the first leaderboard.'**
  String get groupNoLeaderboardYetBody;

  /// No description provided for @leaderboardStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get leaderboardStreak;

  /// No description provided for @leaderboardProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get leaderboardProgress;

  /// No description provided for @leaderboardFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load leaderboard: {error}'**
  String leaderboardFailedToLoad(String error);

  /// No description provided for @leaderboardNoProgressYet.
  ///
  /// In en, this message translates to:
  /// **'No progress recorded yet.'**
  String get leaderboardNoProgressYet;

  /// No description provided for @leaderboardDaysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get leaderboardDaysUnit;

  /// No description provided for @leaderboardStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String leaderboardStreakLabel(int count);

  /// No description provided for @leaderboardTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} {unit} total'**
  String leaderboardTotalLabel(String count, String unit);

  /// No description provided for @leaderboardYouSuffix.
  ///
  /// In en, this message translates to:
  /// **' (You)'**
  String get leaderboardYouSuffix;

  /// No description provided for @leaderboardJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get leaderboardJustNow;

  /// No description provided for @leaderboardMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String leaderboardMinutesAgo(int count);

  /// No description provided for @leaderboardHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String leaderboardHoursAgo(int count);

  /// No description provided for @leaderboardDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String leaderboardDaysAgo(int count);

  /// No description provided for @leaderboardUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} • Updated {time}'**
  String leaderboardUpdatedLabel(String label, String time);

  /// No description provided for @groupNoGoalPhraseAvailable.
  ///
  /// In en, this message translates to:
  /// **'No goal phrase available yet'**
  String get groupNoGoalPhraseAvailable;

  /// No description provided for @groupAddToHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to your habits?'**
  String get groupAddToHabitsTitle;

  /// No description provided for @groupAddToHabitsBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" ({target} · {period}) will be added to your habit list, tracked exactly as published in this group.'**
  String groupAddToHabitsBody(String name, String target, String period);

  /// No description provided for @groupAddedRestored.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\" — restored {count} day(s) of history'**
  String groupAddedRestored(String name, int count);

  /// No description provided for @groupLinkedExistingHabit.
  ///
  /// In en, this message translates to:
  /// **'Linked your existing \"{name}\" habit'**
  String groupLinkedExistingHabit(String name);

  /// No description provided for @groupAddedPlain.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\" to your habits'**
  String groupAddedPlain(String name);

  /// No description provided for @groupAddedRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\", but restoring past history failed: {error}'**
  String groupAddedRestoreFailed(String name, String error);

  /// No description provided for @groupFailedToAddHabit.
  ///
  /// In en, this message translates to:
  /// **'Failed to add habit: {error}'**
  String groupFailedToAddHabit(String error);

  /// No description provided for @groupRemoveFromCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from community?'**
  String get groupRemoveFromCommunityTitle;

  /// No description provided for @groupRemoveFromCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and its leaderboard will be removed for everyone in the group. Everyone\'s own local habit and progress history stay untouched — this can\'t be undone.'**
  String groupRemoveFromCommunityBody(String name);

  /// No description provided for @groupFailedToRemove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove: {error}'**
  String groupFailedToRemove(String error);

  /// No description provided for @chatFailedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String chatFailedToSend(String error);

  /// No description provided for @chatFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chat: {error}'**
  String chatFailedToLoad(String error);

  /// No description provided for @chatNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Start the conversation!'**
  String get chatNoMessagesYet;

  /// No description provided for @chatWriteMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get chatWriteMessageHint;

  /// No description provided for @membersInviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get membersInviteCodeLabel;

  /// No description provided for @membersMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get membersMakeAdmin;

  /// No description provided for @membersRemoveAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get membersRemoveAdmin;

  /// No description provided for @membersRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get membersRemove;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'Why is this app fully offline?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'So your daily habit data stays private and can be used anytime without needing an internet connection. No account, no server, no tracking.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'How is my data stored and is it safe?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'All data (categories, habits, progress history, profile) is stored in a local database on your own device — never sent anywhere.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'What if I switch phones? Does my data move too?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Since there\'s no cloud sync, data doesn\'t transfer automatically. Use the Export Data feature in Settings (coming soon) to make a manual backup before switching devices, then Import Data on the new phone.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'Do I need to log in or sign up for an account?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'No. This app has no account system at all — open it and start using it right away.'**
  String get faqA4;

  /// No description provided for @usageTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Tips'**
  String get usageTipsTitle;

  /// No description provided for @usageTip1Title.
  ///
  /// In en, this message translates to:
  /// **'Use Reminders'**
  String get usageTip1Title;

  /// No description provided for @usageTip1Body.
  ///
  /// In en, this message translates to:
  /// **'When adding or editing a habit, turn on the Reminder toggle and set a time. The app will send a local notification at that time on the habit\'s active days.'**
  String get usageTip1Body;

  /// No description provided for @usageTip2Title.
  ///
  /// In en, this message translates to:
  /// **'Backfill Progress'**
  String get usageTip2Title;

  /// No description provided for @usageTip2Body.
  ///
  /// In en, this message translates to:
  /// **'From the Dashboard tab, tap a past date on the calendar to see that day\'s habit detail. You can still mark/change progress for previous days from there.'**
  String get usageTip2Body;

  /// No description provided for @usageTip3Title.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get usageTip3Title;

  /// No description provided for @usageTip3Body.
  ///
  /// In en, this message translates to:
  /// **'Open Settings > Personalize to pick one of 5 color palettes. The change applies instantly throughout the app.'**
  String get usageTip3Body;

  /// No description provided for @usageTip4Title.
  ///
  /// In en, this message translates to:
  /// **'Use Edit Mode'**
  String get usageTip4Title;

  /// No description provided for @usageTip4Body.
  ///
  /// In en, this message translates to:
  /// **'Tap the pencil button at the bottom right of Home to enter Edit Mode — from there you can reorder (drag), edit, or deactivate habits. Tap the check button or \"Done\" to exit.'**
  String get usageTip4Body;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get profileNameEmpty;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profilePhotoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Profile photo is not available in this version yet'**
  String get profilePhotoNotAvailable;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileNameHint;

  /// No description provided for @profileAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAgeLabel;

  /// No description provided for @profileAgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 25'**
  String get profileAgeHint;

  /// No description provided for @profileSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get profileSaving;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @personalizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize'**
  String get personalizeTitle;

  /// No description provided for @personalizeDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick the color theme you like best. This color is used for buttons, progress rings, and accents throughout the app.'**
  String get personalizeDescription;

  /// No description provided for @healthSyncStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync steps from Health app'**
  String get healthSyncStepsLabel;

  /// No description provided for @healthSyncCalendarLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync reminders to Calendar'**
  String get healthSyncCalendarLabel;

  /// No description provided for @healthSyncAlarmLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync reminders to phone Alarm'**
  String get healthSyncAlarmLabel;

  /// No description provided for @healthSyncDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'{feature} was denied or unavailable on this device.'**
  String healthSyncDeniedMessage(String feature);

  /// No description provided for @healthSyncFeatureHealth.
  ///
  /// In en, this message translates to:
  /// **'Health access'**
  String get healthSyncFeatureHealth;

  /// No description provided for @healthSyncFeatureCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar access'**
  String get healthSyncFeatureCalendar;

  /// No description provided for @iconPickerChooseIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose Icon'**
  String get iconPickerChooseIcon;

  /// No description provided for @iconPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search icons...'**
  String get iconPickerSearchHint;

  /// No description provided for @iconPickerNoIconsFound.
  ///
  /// In en, this message translates to:
  /// **'No icons found'**
  String get iconPickerNoIconsFound;

  /// No description provided for @proFeatureUpgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get proFeatureUpgradeButton;

  /// No description provided for @proFeatureSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String proFeatureSignInFailed(String error);

  /// No description provided for @proFeatureCouldNotLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Could not load subscription plans. Try again later.'**
  String get proFeatureCouldNotLoadPlans;

  /// No description provided for @proFeatureNoPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subscription plans available right now.'**
  String get proFeatureNoPlansAvailable;

  /// No description provided for @proFeatureChooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get proFeatureChooseYourPlan;

  /// No description provided for @proFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get proFeatureTitle;

  /// No description provided for @quickProgressOrEnterManually.
  ///
  /// In en, this message translates to:
  /// **'or enter manually'**
  String get quickProgressOrEnterManually;

  /// No description provided for @quickProgressTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {label}'**
  String quickProgressTarget(String label);

  /// No description provided for @quickProgressMarkAchieved.
  ///
  /// In en, this message translates to:
  /// **'Mark Achieved'**
  String get quickProgressMarkAchieved;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @timerLabel.
  ///
  /// In en, this message translates to:
  /// **'TIMER'**
  String get timerLabel;

  /// No description provided for @timerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPause;

  /// No description provided for @timerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get timerResume;

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerStart;

  /// No description provided for @financeTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get financeTitle;

  /// No description provided for @onboardingFinanceProFeature.
  ///
  /// In en, this message translates to:
  /// **'Finance tracking is a Pro feature'**
  String get onboardingFinanceProFeature;

  /// No description provided for @onboardingCancelHabit.
  ///
  /// In en, this message translates to:
  /// **'Cancel this habit'**
  String get onboardingCancelHabit;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get navFinance;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @addHabitCustomizeBeforeAdding.
  ///
  /// In en, this message translates to:
  /// **'Customize before adding'**
  String get addHabitCustomizeBeforeAdding;

  /// No description provided for @addHabitAddSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 Habit} other{Add {count} Habits}}'**
  String addHabitAddSelected(int count);

  /// No description provided for @addHabitAddedMultiple.
  ///
  /// In en, this message translates to:
  /// **'{count} habits added'**
  String addHabitAddedMultiple(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
