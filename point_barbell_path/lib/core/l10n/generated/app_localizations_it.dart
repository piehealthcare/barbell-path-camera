// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'PoinT Traiettoria del Bilanciere';

  @override
  String get home => 'Home';

  @override
  String get history => 'Cronologia';

  @override
  String get settings => 'Impostazioni';

  @override
  String get quickStart => 'Avvio rapido';

  @override
  String get recentSessions => 'Sessioni recenti';

  @override
  String get startTracking => 'Avvia tracciamento';

  @override
  String get stopTracking => 'Ferma tracciamento';

  @override
  String get newSet => 'Nuova serie';

  @override
  String get finishSet => 'Termina serie';

  @override
  String get selectExercise => 'Seleziona esercizio';

  @override
  String get squat => 'Squat';

  @override
  String get benchPress => 'Panca piana';

  @override
  String get deadlift => 'Stacco da terra';

  @override
  String get overheadPress => 'Lento avanti';

  @override
  String get custom => 'Personalizzato';

  @override
  String get calibration => 'Calibrazione';

  @override
  String get calibrationDescription =>
      'Configura la fotocamera per misurazioni precise';

  @override
  String get cameraDistance => 'Distanza della fotocamera';

  @override
  String metersAway(String meters) {
    return '$meters m di distanza';
  }

  @override
  String get reps => 'Ripetizioni';

  @override
  String get sets => 'Serie';

  @override
  String repCount(int count) {
    return '$count rip.';
  }

  @override
  String setCount(int count) {
    return '$count serie';
  }

  @override
  String get velocity => 'Velocità';

  @override
  String get peakVelocity => 'Velocità massima';

  @override
  String get meanVelocity => 'Velocità media';

  @override
  String get rom => 'Range di movimento';

  @override
  String get phase => 'Fase';

  @override
  String get ascending => 'Salita';

  @override
  String get descending => 'Discesa';

  @override
  String get atTop => 'In alto';

  @override
  String get atBottom => 'In basso';

  @override
  String get idle => 'In attesa';

  @override
  String get sessionReview => 'Riepilogo sessione';

  @override
  String get sessionSummary => 'Sommario sessione';

  @override
  String get saveSession => 'Salva sessione';

  @override
  String get shareSession => 'Condividi';

  @override
  String get discardSession => 'Elimina';

  @override
  String get totalReps => 'Ripetizioni totali';

  @override
  String get totalSets => 'Serie totali';

  @override
  String get avgVelocity => 'Velocità media';

  @override
  String get sessionDuration => 'Durata dell\'allenamento';

  @override
  String get noSessions => 'Nessuna sessione registrata';

  @override
  String get recording => 'Registrazione in corso';

  @override
  String get startRecording => 'Avvia registrazione';

  @override
  String get stopRecording => 'Ferma registrazione';

  @override
  String get savedToGallery => 'Salvato nella galleria';

  @override
  String get cameraPermission => 'Autorizzazione fotocamera richiesta';

  @override
  String get storagePermission => 'Autorizzazione archiviazione richiesta';

  @override
  String get grantPermission => 'Concedi autorizzazione';

  @override
  String get onboardingTitle1 => 'Traccia la traiettoria del bilanciere';

  @override
  String get onboardingDesc1 =>
      'L\'IA analizza il movimento del bilanciere in tempo reale';

  @override
  String get onboardingTitle2 => 'Allenamento basato sulla velocità';

  @override
  String get onboardingDesc2 =>
      'Trova l\'intensità ottimale con l\'analisi delle zone VBT';

  @override
  String get onboardingTitle3 => 'Registra i tuoi allenamenti';

  @override
  String get onboardingDesc3 =>
      'Salva e condividi video con la traiettoria del bilanciere sovrapposta';

  @override
  String get getStarted => 'Inizia';

  @override
  String get next => 'Avanti';

  @override
  String get skip => 'Salta';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get language => 'Lingua';

  @override
  String get about => 'Informazioni';

  @override
  String get version => 'Versione';

  @override
  String get premium => 'Premium';

  @override
  String get premiumDescription => 'Sblocca tutte le funzionalità';

  @override
  String get delete => 'Elimina';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Errore';

  @override
  String get retry => 'Riprova';

  @override
  String get loading => 'Caricamento...';

  @override
  String get noData => 'Nessun dato';

  @override
  String get strengthZone => 'Forza';

  @override
  String get strengthSpeedZone => 'Forza-Velocità';

  @override
  String get powerZone => 'Potenza';

  @override
  String get speedStrengthZone => 'Velocità-Forza';

  @override
  String get speedZone => 'Velocità';
}
