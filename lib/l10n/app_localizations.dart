import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sikoku'**
  String get appTitle;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @soundVolume.
  ///
  /// In en, this message translates to:
  /// **'Sound Volume'**
  String get soundVolume;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @remindDailyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Remind daily puzzle'**
  String get remindDailyPuzzle;

  /// No description provided for @remindWeeklyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Remind weekly puzzle'**
  String get remindWeeklyPuzzle;

  /// No description provided for @control.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get control;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get market;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @winsCongratsTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get winsCongratsTitle;

  /// No description provided for @winsCongratsBody.
  ///
  /// In en, this message translates to:
  /// **'You won the level.'**
  String get winsCongratsBody;

  /// No description provided for @errorsFound.
  ///
  /// In en, this message translates to:
  /// **'Total mistakes: {count}'**
  String errorsFound(int count);

  /// No description provided for @noErrors.
  ///
  /// In en, this message translates to:
  /// **'No mistakes. Great!'**
  String get noErrors;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get chooseAvatar;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalStars.
  ///
  /// In en, this message translates to:
  /// **'Total Stars'**
  String get totalStars;

  /// No description provided for @fastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get fastest;

  /// No description provided for @noMistakes.
  ///
  /// In en, this message translates to:
  /// **'No mistakes'**
  String get noMistakes;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @firstDailyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'First Daily Puzzle'**
  String get firstDailyPuzzle;

  /// No description provided for @sevenDaysInARow.
  ///
  /// In en, this message translates to:
  /// **'7 Days in a Row'**
  String get sevenDaysInARow;

  /// No description provided for @hundredPuzzles.
  ///
  /// In en, this message translates to:
  /// **'100 Puzzles'**
  String get hundredPuzzles;

  /// No description provided for @accountConnections.
  ///
  /// In en, this message translates to:
  /// **'Account Connections'**
  String get accountConnections;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @soundMusic.
  ///
  /// In en, this message translates to:
  /// **'Sound / Music'**
  String get soundMusic;

  /// No description provided for @adminModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Mode (Unlimited Hint/Undo/Check)'**
  String get adminModeTitle;

  /// No description provided for @adminModeDesc.
  ///
  /// In en, this message translates to:
  /// **'For testing. Normal limits apply when disabled.'**
  String get adminModeDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @controlDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get controlDialogTitle;

  /// No description provided for @watchAdToSeeMistakes.
  ///
  /// In en, this message translates to:
  /// **'Watch ad to see mistakes'**
  String get watchAdToSeeMistakes;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get highlight;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @dailyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily Reward'**
  String get dailyReward;

  /// No description provided for @watchAdForReward.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad for Reward'**
  String get watchAdForReward;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @packages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// No description provided for @individualItems.
  ///
  /// In en, this message translates to:
  /// **'Individual Items'**
  String get individualItems;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @rewardClaimed.
  ///
  /// In en, this message translates to:
  /// **'Reward Claimed'**
  String get rewardClaimed;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @selectUniverse.
  ///
  /// In en, this message translates to:
  /// **'Select Universe'**
  String get selectUniverse;

  /// No description provided for @dailyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Daily Puzzle'**
  String get dailyPuzzle;

  /// No description provided for @weeklyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Puzzle'**
  String get weeklyPuzzle;

  /// No description provided for @puzzleCompletedIn.
  ///
  /// In en, this message translates to:
  /// **'You completed the puzzle in {time}!'**
  String puzzleCompletedIn(String time);

  /// No description provided for @perfect3Stars.
  ///
  /// In en, this message translates to:
  /// **'Perfect! You earned 3 stars!'**
  String get perfect3Stars;

  /// No description provided for @great2Stars.
  ///
  /// In en, this message translates to:
  /// **'Great! You earned 2 stars!'**
  String get great2Stars;

  /// No description provided for @good1Star.
  ///
  /// In en, this message translates to:
  /// **'Good! You earned 1 star!'**
  String get good1Star;

  /// No description provided for @puzzleCompleted.
  ///
  /// In en, this message translates to:
  /// **'Puzzle completed!'**
  String get puzzleCompleted;

  /// No description provided for @rewardEarned.
  ///
  /// In en, this message translates to:
  /// **'Reward Earned: {reward}'**
  String rewardEarned(String reward);

  /// No description provided for @congratulationsReward.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You earned {reward} reward!'**
  String congratulationsReward(String reward);

  /// No description provided for @dailyRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reward'**
  String get dailyRewardTitle;

  /// No description provided for @weeklyRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Reward'**
  String get weeklyRewardTitle;

  /// No description provided for @alreadyCompletedDaily.
  ///
  /// In en, this message translates to:
  /// **'You have already completed this daily puzzle.\nYou have already claimed your reward!'**
  String get alreadyCompletedDaily;

  /// No description provided for @alreadyCompletedWeekly.
  ///
  /// In en, this message translates to:
  /// **'You have already completed this weekly puzzle.\nYou have already claimed your reward!'**
  String get alreadyCompletedWeekly;

  /// No description provided for @claimReward.
  ///
  /// In en, this message translates to:
  /// **'Claim Reward'**
  String get claimReward;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @levelsCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'49 levels completed successfully!'**
  String get levelsCompletedSuccessfully;

  /// No description provided for @vibrationTestCompleted.
  ///
  /// In en, this message translates to:
  /// **'Vibration test completed!'**
  String get vibrationTestCompleted;

  /// No description provided for @vibrationTest.
  ///
  /// In en, this message translates to:
  /// **'Vibration Test'**
  String get vibrationTest;

  /// No description provided for @insufficientHints.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Hints'**
  String get insufficientHints;

  /// No description provided for @vibrationTriggered.
  ///
  /// In en, this message translates to:
  /// **'Vibration triggered: {event}'**
  String vibrationTriggered(String event);

  /// No description provided for @levelCompleted.
  ///
  /// In en, this message translates to:
  /// **'level completed'**
  String get levelCompleted;

  /// No description provided for @dontForgetDaily.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to solve today\'s puzzle!'**
  String get dontForgetDaily;

  /// No description provided for @dontMissWeekly.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss the weekly puzzle!'**
  String get dontMissWeekly;

  /// No description provided for @sikkokuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Sikkoku Notifications'**
  String get sikkokuNotifications;

  /// No description provided for @sikkokuChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Sikkoku reminder notification channel'**
  String get sikkokuChannelDescription;

  /// No description provided for @spaceUniverse.
  ///
  /// In en, this message translates to:
  /// **'Space Universe'**
  String get spaceUniverse;

  /// No description provided for @spaceUniverseDescription.
  ///
  /// In en, this message translates to:
  /// **'Ready for an interstellar journey?'**
  String get spaceUniverseDescription;

  /// No description provided for @forestUniverse.
  ///
  /// In en, this message translates to:
  /// **'Forest Universe'**
  String get forestUniverse;

  /// No description provided for @forestUniverseDescription.
  ///
  /// In en, this message translates to:
  /// **'Time to explore the depths of green forests!'**
  String get forestUniverseDescription;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
