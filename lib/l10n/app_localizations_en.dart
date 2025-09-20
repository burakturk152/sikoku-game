// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sikoku';

  @override
  String get player => 'Player';

  @override
  String get settings => 'Settings';

  @override
  String get vibration => 'Vibration';

  @override
  String get music => 'Music';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundVolume => 'Sound Volume';

  @override
  String get notifications => 'Notifications';

  @override
  String get remindDailyPuzzle => 'Remind daily puzzle';

  @override
  String get remindWeeklyPuzzle => 'Remind weekly puzzle';

  @override
  String get control => 'Check';

  @override
  String get hint => 'Hint';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get delete => 'Delete';

  @override
  String get market => 'Shop';

  @override
  String get profile => 'Profile';

  @override
  String get winsCongratsTitle => 'Congratulations!';

  @override
  String get winsCongratsBody => 'You won the level.';

  @override
  String errorsFound(int count) {
    return 'Total mistakes: $count';
  }

  @override
  String get noErrors => 'No mistakes. Great!';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalStars => 'Total Stars';

  @override
  String get fastest => 'Fastest';

  @override
  String get noMistakes => 'No mistakes';

  @override
  String get achievements => 'Achievements';

  @override
  String get firstDailyPuzzle => 'First Daily Puzzle';

  @override
  String get sevenDaysInARow => '7 Days in a Row';

  @override
  String get hundredPuzzles => '100 Puzzles';

  @override
  String get accountConnections => 'Account Connections';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get facebook => 'Facebook';

  @override
  String get soundMusic => 'Sound / Music';

  @override
  String get adminModeTitle => 'Admin Mode (Unlimited Hint/Undo/Check)';

  @override
  String get adminModeDesc => 'For testing. Normal limits apply when disabled.';

  @override
  String get language => 'Language';

  @override
  String get apply => 'Apply';

  @override
  String get resetProgress => 'Reset Progress';

  @override
  String get controlDialogTitle => 'Check';

  @override
  String get watchAdToSeeMistakes => 'Watch ad to see mistakes';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get highlight => 'Highlight';

  @override
  String get check => 'Check';

  @override
  String get dailyReward => 'Daily Reward';

  @override
  String get watchAdForReward => 'Watch Ad for Reward';

  @override
  String get inventory => 'Inventory';

  @override
  String get packages => 'Packages';

  @override
  String get individualItems => 'Individual Items';

  @override
  String get buy => 'Buy';

  @override
  String get purchased => 'Purchased';

  @override
  String get rewardClaimed => 'Reward Claimed';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get package => 'Package';

  @override
  String get items => 'items';

  @override
  String get selectUniverse => 'Select Universe';

  @override
  String get dailyPuzzle => 'Daily Puzzle';

  @override
  String get weeklyPuzzle => 'Weekly Puzzle';

  @override
  String puzzleCompletedIn(String time) {
    return 'You completed the puzzle in $time!';
  }

  @override
  String get perfect3Stars => 'Perfect! You earned 3 stars!';

  @override
  String get great2Stars => 'Great! You earned 2 stars!';

  @override
  String get good1Star => 'Good! You earned 1 star!';

  @override
  String get puzzleCompleted => 'Puzzle completed!';

  @override
  String rewardEarned(String reward) {
    return 'Reward Earned: $reward';
  }

  @override
  String congratulationsReward(String reward) {
    return 'Congratulations! You earned $reward reward!';
  }

  @override
  String get dailyRewardTitle => 'Daily Reward';

  @override
  String get weeklyRewardTitle => 'Weekly Reward';

  @override
  String get alreadyCompletedDaily => 'You have already completed this daily puzzle.\nYou have already claimed your reward!';

  @override
  String get alreadyCompletedWeekly => 'You have already completed this weekly puzzle.\nYou have already claimed your reward!';

  @override
  String get claimReward => 'Claim Reward';

  @override
  String get continueButton => 'Continue';

  @override
  String get levelsCompletedSuccessfully => '49 levels completed successfully!';

  @override
  String get vibrationTestCompleted => 'Vibration test completed!';

  @override
  String get vibrationTest => 'Vibration Test';

  @override
  String get insufficientHints => 'Insufficient Hints';

  @override
  String vibrationTriggered(String event) {
    return 'Vibration triggered: $event';
  }

  @override
  String get levelCompleted => 'level completed';

  @override
  String get dontForgetDaily => 'Don\'t forget to solve today\'s puzzle!';

  @override
  String get dontMissWeekly => 'Don\'t miss the weekly puzzle!';

  @override
  String get sikkokuNotifications => 'Sikkoku Notifications';

  @override
  String get sikkokuChannelDescription => 'Sikkoku reminder notification channel';

  @override
  String get spaceUniverse => 'Space Universe';

  @override
  String get spaceUniverseDescription => 'Ready for an interstellar journey?';

  @override
  String get forestUniverse => 'Forest Universe';

  @override
  String get forestUniverseDescription => 'Time to explore the depths of green forests!';
}
