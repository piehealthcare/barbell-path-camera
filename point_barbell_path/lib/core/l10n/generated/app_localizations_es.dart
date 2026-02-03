// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PoinT Trayectoria de Barra';

  @override
  String get home => 'Inicio';

  @override
  String get history => 'Historial';

  @override
  String get settings => 'Ajustes';

  @override
  String get quickStart => 'Inicio rápido';

  @override
  String get recentSessions => 'Sesiones recientes';

  @override
  String get startTracking => 'Iniciar seguimiento';

  @override
  String get stopTracking => 'Detener seguimiento';

  @override
  String get newSet => 'Nueva serie';

  @override
  String get finishSet => 'Finalizar serie';

  @override
  String get selectExercise => 'Seleccionar ejercicio';

  @override
  String get squat => 'Sentadilla';

  @override
  String get benchPress => 'Press de banca';

  @override
  String get deadlift => 'Peso muerto';

  @override
  String get overheadPress => 'Press militar';

  @override
  String get custom => 'Personalizado';

  @override
  String get calibration => 'Calibración';

  @override
  String get calibrationDescription =>
      'Configura la cámara para una medición precisa';

  @override
  String get cameraDistance => 'Distancia de la cámara';

  @override
  String metersAway(String meters) {
    return '$meters m de distancia';
  }

  @override
  String get reps => 'Repeticiones';

  @override
  String get sets => 'Series';

  @override
  String repCount(int count) {
    return '$count reps';
  }

  @override
  String setCount(int count) {
    return '$count series';
  }

  @override
  String get velocity => 'Velocidad';

  @override
  String get peakVelocity => 'Velocidad máxima';

  @override
  String get meanVelocity => 'Velocidad media';

  @override
  String get rom => 'Rango de movimiento';

  @override
  String get phase => 'Fase';

  @override
  String get ascending => 'Ascenso';

  @override
  String get descending => 'Descenso';

  @override
  String get atTop => 'Arriba';

  @override
  String get atBottom => 'Abajo';

  @override
  String get idle => 'En espera';

  @override
  String get sessionReview => 'Revisión de sesión';

  @override
  String get sessionSummary => 'Resumen de sesión';

  @override
  String get saveSession => 'Guardar sesión';

  @override
  String get shareSession => 'Compartir';

  @override
  String get discardSession => 'Eliminar';

  @override
  String get totalReps => 'Repeticiones totales';

  @override
  String get totalSets => 'Series totales';

  @override
  String get avgVelocity => 'Velocidad media';

  @override
  String get sessionDuration => 'Duración del entrenamiento';

  @override
  String get noSessions => 'No hay sesiones registradas';

  @override
  String get recording => 'Grabando';

  @override
  String get startRecording => 'Iniciar grabación';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get savedToGallery => 'Guardado en la galería';

  @override
  String get cameraPermission => 'Se requiere permiso de cámara';

  @override
  String get storagePermission => 'Se requiere permiso de almacenamiento';

  @override
  String get grantPermission => 'Conceder permiso';

  @override
  String get onboardingTitle1 => 'Rastrea la trayectoria de la barra';

  @override
  String get onboardingDesc1 =>
      'La IA analiza el movimiento de la barra en tiempo real';

  @override
  String get onboardingTitle2 => 'Entrenamiento basado en velocidad';

  @override
  String get onboardingDesc2 =>
      'Encuentra la intensidad óptima con el análisis de zonas VBT';

  @override
  String get onboardingTitle3 => 'Graba tus entrenamientos';

  @override
  String get onboardingDesc3 =>
      'Guarda y comparte vídeos con la trayectoria de la barra superpuesta';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get next => 'Siguiente';

  @override
  String get skip => 'Omitir';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get premium => 'Premium';

  @override
  String get premiumDescription => 'Desbloquea todas las funciones';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get ok => 'Aceptar';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get loading => 'Cargando...';

  @override
  String get noData => 'Sin datos';

  @override
  String get strengthZone => 'Fuerza';

  @override
  String get strengthSpeedZone => 'Fuerza-Velocidad';

  @override
  String get powerZone => 'Potencia';

  @override
  String get speedStrengthZone => 'Velocidad-Fuerza';

  @override
  String get speedZone => 'Velocidad';
}
