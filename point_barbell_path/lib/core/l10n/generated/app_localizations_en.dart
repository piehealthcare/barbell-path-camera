// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PoinT Barbell Path';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get recentSessions => 'Recent Sessions';

  @override
  String get startTracking => 'Start Tracking';

  @override
  String get stopTracking => 'Stop Tracking';

  @override
  String get newSet => 'New Set';

  @override
  String get finishSet => 'Finish Set';

  @override
  String get selectExercise => 'Select Exercise';

  @override
  String get squat => 'Squat';

  @override
  String get benchPress => 'Bench Press';

  @override
  String get deadlift => 'Deadlift';

  @override
  String get overheadPress => 'Overhead Press';

  @override
  String get custom => 'Custom';

  @override
  String get calibration => 'Calibration';

  @override
  String get calibrationDescription =>
      'Set up your camera for accurate measurements';

  @override
  String get cameraDistance => 'Camera Distance';

  @override
  String metersAway(String meters) {
    return '${meters}m away';
  }

  @override
  String get reps => 'Reps';

  @override
  String get sets => 'Sets';

  @override
  String repCount(int count) {
    return '$count reps';
  }

  @override
  String setCount(int count) {
    return '$count sets';
  }

  @override
  String get velocity => 'Velocity';

  @override
  String get peakVelocity => 'Peak Velocity';

  @override
  String get meanVelocity => 'Mean Velocity';

  @override
  String get rom => 'ROM';

  @override
  String get phase => 'Phase';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get atTop => 'At Top';

  @override
  String get atBottom => 'At Bottom';

  @override
  String get idle => 'Idle';

  @override
  String get sessionReview => 'Session Review';

  @override
  String get sessionSummary => 'Session Summary';

  @override
  String get saveSession => 'Save Session';

  @override
  String get shareSession => 'Share';

  @override
  String get discardSession => 'Discard';

  @override
  String get totalReps => 'Total Reps';

  @override
  String get totalSets => 'Total Sets';

  @override
  String get avgVelocity => 'Avg Velocity';

  @override
  String get sessionDuration => 'Duration';

  @override
  String get noSessions => 'No sessions recorded yet';

  @override
  String get recording => 'Recording';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get savedToGallery => 'Saved to gallery';

  @override
  String get cameraPermission => 'Camera permission required';

  @override
  String get storagePermission => 'Storage permission required';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get onboardingTitle1 => 'Track Your Barbell Path';

  @override
  String get onboardingDesc1 =>
      'AI analyzes your barbell movement in real-time';

  @override
  String get onboardingTitle2 => 'Velocity Based Training';

  @override
  String get onboardingDesc2 =>
      'Find your optimal training intensity with VBT zone analysis';

  @override
  String get onboardingTitle3 => 'Record Your Lifts';

  @override
  String get onboardingDesc3 =>
      'Save and share videos with barbell path overlay';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get premium => 'Premium';

  @override
  String get premiumDescription => 'Unlock all features';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data';

  @override
  String get strengthZone => 'Strength';

  @override
  String get strengthSpeedZone => 'Strength-Speed';

  @override
  String get powerZone => 'Power';

  @override
  String get speedStrengthZone => 'Speed-Strength';

  @override
  String get speedZone => 'Speed';
}
