// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'PoinT Trajetória da Barra';

  @override
  String get home => 'Início';

  @override
  String get history => 'Histórico';

  @override
  String get settings => 'Configurações';

  @override
  String get quickStart => 'Início rápido';

  @override
  String get recentSessions => 'Sessões recentes';

  @override
  String get startTracking => 'Iniciar rastreamento';

  @override
  String get stopTracking => 'Parar rastreamento';

  @override
  String get newSet => 'Nova série';

  @override
  String get finishSet => 'Finalizar série';

  @override
  String get selectExercise => 'Selecionar exercício';

  @override
  String get squat => 'Agachamento';

  @override
  String get benchPress => 'Supino';

  @override
  String get deadlift => 'Levantamento terra';

  @override
  String get overheadPress => 'Desenvolvimento';

  @override
  String get custom => 'Personalizado';

  @override
  String get calibration => 'Calibração';

  @override
  String get calibrationDescription =>
      'Configure a câmera para medições precisas';

  @override
  String get cameraDistance => 'Distância da câmera';

  @override
  String metersAway(String meters) {
    return '$meters m de distância';
  }

  @override
  String get reps => 'Repetições';

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
  String get velocity => 'Velocidade';

  @override
  String get peakVelocity => 'Velocidade máxima';

  @override
  String get meanVelocity => 'Velocidade média';

  @override
  String get rom => 'Amplitude de movimento';

  @override
  String get phase => 'Fase';

  @override
  String get ascending => 'Subida';

  @override
  String get descending => 'Descida';

  @override
  String get atTop => 'No topo';

  @override
  String get atBottom => 'Embaixo';

  @override
  String get idle => 'Em espera';

  @override
  String get sessionReview => 'Revisão da sessão';

  @override
  String get sessionSummary => 'Resumo da sessão';

  @override
  String get saveSession => 'Salvar sessão';

  @override
  String get shareSession => 'Compartilhar';

  @override
  String get discardSession => 'Excluir';

  @override
  String get totalReps => 'Total de repetições';

  @override
  String get totalSets => 'Total de séries';

  @override
  String get avgVelocity => 'Velocidade média';

  @override
  String get sessionDuration => 'Duração do treino';

  @override
  String get noSessions => 'Nenhuma sessão registrada';

  @override
  String get recording => 'Gravando';

  @override
  String get startRecording => 'Iniciar gravação';

  @override
  String get stopRecording => 'Parar gravação';

  @override
  String get savedToGallery => 'Salvo na galeria';

  @override
  String get cameraPermission => 'Permissão de câmera necessária';

  @override
  String get storagePermission => 'Permissão de armazenamento necessária';

  @override
  String get grantPermission => 'Conceder permissão';

  @override
  String get onboardingTitle1 => 'Rastreie a trajetória da barra';

  @override
  String get onboardingDesc1 =>
      'A IA analisa o movimento da barra em tempo real';

  @override
  String get onboardingTitle2 => 'Treino baseado em velocidade';

  @override
  String get onboardingDesc2 =>
      'Encontre a intensidade ideal com a análise de zonas VBT';

  @override
  String get onboardingTitle3 => 'Grave seus treinos';

  @override
  String get onboardingDesc3 =>
      'Salve e compartilhe vídeos com a trajetória da barra sobreposta';

  @override
  String get getStarted => 'Começar';

  @override
  String get next => 'Próximo';

  @override
  String get skip => 'Pular';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get language => 'Idioma';

  @override
  String get about => 'Sobre';

  @override
  String get version => 'Versão';

  @override
  String get premium => 'Premium';

  @override
  String get premiumDescription => 'Desbloqueie todas as funcionalidades';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Erro';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get loading => 'Carregando...';

  @override
  String get noData => 'Sem dados';

  @override
  String get strengthZone => 'Força';

  @override
  String get strengthSpeedZone => 'Força-Velocidade';

  @override
  String get powerZone => 'Potência';

  @override
  String get speedStrengthZone => 'Velocidade-Força';

  @override
  String get speedZone => 'Velocidade';
}
