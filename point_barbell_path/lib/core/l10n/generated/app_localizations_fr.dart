// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'PoinT Trajectoire de Barre';

  @override
  String get home => 'Accueil';

  @override
  String get history => 'Historique';

  @override
  String get settings => 'Paramètres';

  @override
  String get quickStart => 'Démarrage rapide';

  @override
  String get recentSessions => 'Sessions récentes';

  @override
  String get startTracking => 'Démarrer le suivi';

  @override
  String get stopTracking => 'Arrêter le suivi';

  @override
  String get newSet => 'Nouvelle série';

  @override
  String get finishSet => 'Terminer la série';

  @override
  String get selectExercise => 'Choisir un exercice';

  @override
  String get squat => 'Squat';

  @override
  String get benchPress => 'Développé couché';

  @override
  String get deadlift => 'Soulevé de terre';

  @override
  String get overheadPress => 'Développé militaire';

  @override
  String get custom => 'Personnalisé';

  @override
  String get calibration => 'Calibration';

  @override
  String get calibrationDescription =>
      'Configurez la caméra pour des mesures précises';

  @override
  String get cameraDistance => 'Distance de la caméra';

  @override
  String metersAway(String meters) {
    return '$meters m de distance';
  }

  @override
  String get reps => 'Répétitions';

  @override
  String get sets => 'Séries';

  @override
  String repCount(int count) {
    return '$count reps';
  }

  @override
  String setCount(int count) {
    return '$count séries';
  }

  @override
  String get velocity => 'Vitesse';

  @override
  String get peakVelocity => 'Vitesse maximale';

  @override
  String get meanVelocity => 'Vitesse moyenne';

  @override
  String get rom => 'Amplitude de mouvement';

  @override
  String get phase => 'Phase';

  @override
  String get ascending => 'Montée';

  @override
  String get descending => 'Descente';

  @override
  String get atTop => 'En haut';

  @override
  String get atBottom => 'En bas';

  @override
  String get idle => 'En attente';

  @override
  String get sessionReview => 'Bilan de session';

  @override
  String get sessionSummary => 'Résumé de session';

  @override
  String get saveSession => 'Enregistrer la session';

  @override
  String get shareSession => 'Partager';

  @override
  String get discardSession => 'Supprimer';

  @override
  String get totalReps => 'Répétitions totales';

  @override
  String get totalSets => 'Séries totales';

  @override
  String get avgVelocity => 'Vitesse moyenne';

  @override
  String get sessionDuration => 'Durée de l\'entraînement';

  @override
  String get noSessions => 'Aucune session enregistrée';

  @override
  String get recording => 'Enregistrement en cours';

  @override
  String get startRecording => 'Démarrer l\'enregistrement';

  @override
  String get stopRecording => 'Arrêter l\'enregistrement';

  @override
  String get savedToGallery => 'Enregistré dans la galerie';

  @override
  String get cameraPermission => 'Autorisation de la caméra requise';

  @override
  String get storagePermission => 'Autorisation de stockage requise';

  @override
  String get grantPermission => 'Accorder l\'autorisation';

  @override
  String get onboardingTitle1 => 'Suivez la trajectoire de la barre';

  @override
  String get onboardingDesc1 =>
      'L\'IA analyse le mouvement de la barre en temps réel';

  @override
  String get onboardingTitle2 => 'Entraînement basé sur la vitesse';

  @override
  String get onboardingDesc2 =>
      'Trouvez l\'intensité optimale grâce à l\'analyse des zones VBT';

  @override
  String get onboardingTitle3 => 'Enregistrez vos séances en vidéo';

  @override
  String get onboardingDesc3 =>
      'Sauvegardez et partagez des vidéos avec la trajectoire de la barre superposée';

  @override
  String get getStarted => 'Commencer';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Passer';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get language => 'Langue';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get premium => 'Premium';

  @override
  String get premiumDescription => 'Débloquez toutes les fonctionnalités';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Erreur';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement...';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get strengthZone => 'Force';

  @override
  String get strengthSpeedZone => 'Force-Vitesse';

  @override
  String get powerZone => 'Puissance';

  @override
  String get speedStrengthZone => 'Vitesse-Force';

  @override
  String get speedZone => 'Vitesse';
}
