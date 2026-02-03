// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'PoinT バーベルパス';

  @override
  String get home => 'ホーム';

  @override
  String get history => '履歴';

  @override
  String get settings => '設定';

  @override
  String get quickStart => 'クイックスタート';

  @override
  String get recentSessions => '最近のセッション';

  @override
  String get startTracking => 'トラッキング開始';

  @override
  String get stopTracking => 'トラッキング停止';

  @override
  String get newSet => '新しいセット';

  @override
  String get finishSet => 'セット完了';

  @override
  String get selectExercise => '種目を選択';

  @override
  String get squat => 'スクワット';

  @override
  String get benchPress => 'ベンチプレス';

  @override
  String get deadlift => 'デッドリフト';

  @override
  String get overheadPress => 'オーバーヘッドプレス';

  @override
  String get custom => 'カスタム';

  @override
  String get calibration => 'キャリブレーション';

  @override
  String get calibrationDescription => '正確な測定のためにカメラを設定します';

  @override
  String get cameraDistance => 'カメラ距離';

  @override
  String metersAway(String meters) {
    return '${meters}m 離れた位置';
  }

  @override
  String get reps => 'レップ';

  @override
  String get sets => 'セット';

  @override
  String repCount(int count) {
    return '$count回';
  }

  @override
  String setCount(int count) {
    return '$countセット';
  }

  @override
  String get velocity => '速度';

  @override
  String get peakVelocity => '最大速度';

  @override
  String get meanVelocity => '平均速度';

  @override
  String get rom => '可動域';

  @override
  String get phase => 'フェーズ';

  @override
  String get ascending => '上昇';

  @override
  String get descending => '下降';

  @override
  String get atTop => 'トップ';

  @override
  String get atBottom => 'ボトム';

  @override
  String get idle => '待機';

  @override
  String get sessionReview => 'セッションレビュー';

  @override
  String get sessionSummary => 'セッションサマリー';

  @override
  String get saveSession => 'セッションを保存';

  @override
  String get shareSession => '共有';

  @override
  String get discardSession => '削除';

  @override
  String get totalReps => '合計レップ数';

  @override
  String get totalSets => '合計セット数';

  @override
  String get avgVelocity => '平均速度';

  @override
  String get sessionDuration => 'トレーニング時間';

  @override
  String get noSessions => '記録されたセッションはありません';

  @override
  String get recording => '録画中';

  @override
  String get startRecording => '録画開始';

  @override
  String get stopRecording => '録画停止';

  @override
  String get savedToGallery => 'ギャラリーに保存しました';

  @override
  String get cameraPermission => 'カメラの権限が必要です';

  @override
  String get storagePermission => 'ストレージの権限が必要です';

  @override
  String get grantPermission => '権限を許可';

  @override
  String get onboardingTitle1 => 'バーベルの軌道を追跡しよう';

  @override
  String get onboardingDesc1 => 'AIがリアルタイムでバーベルの動きを分析します';

  @override
  String get onboardingTitle2 => '速度ベーストレーニング';

  @override
  String get onboardingDesc2 => 'VBTゾーン分析で最適なトレーニング強度を見つけましょう';

  @override
  String get onboardingTitle3 => '動画で記録しよう';

  @override
  String get onboardingDesc3 => 'バーベルの軌道が合成された動画を保存・共有できます';

  @override
  String get getStarted => '始める';

  @override
  String get next => '次へ';

  @override
  String get skip => 'スキップ';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get language => '言語';

  @override
  String get about => 'アプリについて';

  @override
  String get version => 'バージョン';

  @override
  String get premium => 'プレミアム';

  @override
  String get premiumDescription => 'すべての機能をアンロックしましょう';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get ok => 'OK';

  @override
  String get error => 'エラー';

  @override
  String get retry => '再試行';

  @override
  String get loading => '読み込み中...';

  @override
  String get noData => 'データなし';

  @override
  String get strengthZone => 'ストレングス';

  @override
  String get strengthSpeedZone => 'ストレングス-スピード';

  @override
  String get powerZone => 'パワー';

  @override
  String get speedStrengthZone => 'スピード-ストレングス';

  @override
  String get speedZone => 'スピード';
}
