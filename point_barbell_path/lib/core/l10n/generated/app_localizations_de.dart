// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PoinT Hantelweg';

  @override
  String get home => 'Startseite';

  @override
  String get history => 'Verlauf';

  @override
  String get settings => 'Einstellungen';

  @override
  String get quickStart => 'Schnellstart';

  @override
  String get recentSessions => 'Letzte Einheiten';

  @override
  String get startTracking => 'Tracking starten';

  @override
  String get stopTracking => 'Tracking stoppen';

  @override
  String get newSet => 'Neuer Satz';

  @override
  String get finishSet => 'Satz beenden';

  @override
  String get selectExercise => 'Übung wählen';

  @override
  String get squat => 'Kniebeuge';

  @override
  String get benchPress => 'Bankdrücken';

  @override
  String get deadlift => 'Kreuzheben';

  @override
  String get overheadPress => 'Schulterdrücken';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get calibration => 'Kalibrierung';

  @override
  String get calibrationDescription =>
      'Richten Sie die Kamera für präzise Messungen ein';

  @override
  String get cameraDistance => 'Kameraabstand';

  @override
  String metersAway(String meters) {
    return '$meters m entfernt';
  }

  @override
  String get reps => 'Wiederholungen';

  @override
  String get sets => 'Sätze';

  @override
  String repCount(int count) {
    return '$count Wdh.';
  }

  @override
  String setCount(int count) {
    return '$count Sätze';
  }

  @override
  String get velocity => 'Geschwindigkeit';

  @override
  String get peakVelocity => 'Maximalgeschwindigkeit';

  @override
  String get meanVelocity => 'Durchschnittsgeschwindigkeit';

  @override
  String get rom => 'Bewegungsumfang';

  @override
  String get phase => 'Phase';

  @override
  String get ascending => 'Aufwärts';

  @override
  String get descending => 'Abwärts';

  @override
  String get atTop => 'Oben';

  @override
  String get atBottom => 'Unten';

  @override
  String get idle => 'Bereit';

  @override
  String get sessionReview => 'Einheitsübersicht';

  @override
  String get sessionSummary => 'Zusammenfassung';

  @override
  String get saveSession => 'Einheit speichern';

  @override
  String get shareSession => 'Teilen';

  @override
  String get discardSession => 'Löschen';

  @override
  String get totalReps => 'Gesamtwiederholungen';

  @override
  String get totalSets => 'Gesamtsätze';

  @override
  String get avgVelocity => 'Durchschnittsgeschwindigkeit';

  @override
  String get sessionDuration => 'Trainingsdauer';

  @override
  String get noSessions => 'Keine Einheiten vorhanden';

  @override
  String get recording => 'Aufnahme läuft';

  @override
  String get startRecording => 'Aufnahme starten';

  @override
  String get stopRecording => 'Aufnahme stoppen';

  @override
  String get savedToGallery => 'In der Galerie gespeichert';

  @override
  String get cameraPermission => 'Kameraberechtigung erforderlich';

  @override
  String get storagePermission => 'Speicherberechtigung erforderlich';

  @override
  String get grantPermission => 'Berechtigung erteilen';

  @override
  String get onboardingTitle1 => 'Verfolge den Hantelweg';

  @override
  String get onboardingDesc1 => 'KI analysiert die Hantelbewegung in Echtzeit';

  @override
  String get onboardingTitle2 => 'Geschwindigkeitsbasiertes Training';

  @override
  String get onboardingDesc2 =>
      'Finde die optimale Trainingsintensität mit der VBT-Zonenanalyse';

  @override
  String get onboardingTitle3 => 'Zeichne dein Training auf';

  @override
  String get onboardingDesc3 =>
      'Speichere und teile Videos mit eingeblendetem Hantelweg';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get next => 'Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get language => 'Sprache';

  @override
  String get about => 'Über die App';

  @override
  String get version => 'Version';

  @override
  String get premium => 'Premium';

  @override
  String get premiumDescription => 'Alle Funktionen freischalten';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Fehler';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get loading => 'Laden...';

  @override
  String get noData => 'Keine Daten';

  @override
  String get strengthZone => 'Kraft';

  @override
  String get strengthSpeedZone => 'Kraft-Schnelligkeit';

  @override
  String get powerZone => 'Schnellkraft';

  @override
  String get speedStrengthZone => 'Schnelligkeit-Kraft';

  @override
  String get speedZone => 'Schnelligkeit';
}
