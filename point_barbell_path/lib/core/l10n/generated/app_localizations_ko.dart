// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'PoinT 바벨패스';

  @override
  String get home => '홈';

  @override
  String get history => '기록';

  @override
  String get settings => '설정';

  @override
  String get quickStart => '빠른 시작';

  @override
  String get recentSessions => '최근 세션';

  @override
  String get startTracking => '트래킹 시작';

  @override
  String get stopTracking => '트래킹 중지';

  @override
  String get newSet => '새 세트';

  @override
  String get finishSet => '세트 완료';

  @override
  String get selectExercise => '운동 선택';

  @override
  String get squat => '스쿼트';

  @override
  String get benchPress => '벤치프레스';

  @override
  String get deadlift => '데드리프트';

  @override
  String get overheadPress => '오버헤드프레스';

  @override
  String get custom => '사용자 지정';

  @override
  String get calibration => '캘리브레이션';

  @override
  String get calibrationDescription => '정확한 측정을 위해 카메라를 설정합니다';

  @override
  String get cameraDistance => '카메라 거리';

  @override
  String metersAway(String meters) {
    return '${meters}m 거리';
  }

  @override
  String get reps => '반복';

  @override
  String get sets => '세트';

  @override
  String repCount(int count) {
    return '$count회';
  }

  @override
  String setCount(int count) {
    return '$count세트';
  }

  @override
  String get velocity => '속도';

  @override
  String get peakVelocity => '최대 속도';

  @override
  String get meanVelocity => '평균 속도';

  @override
  String get rom => '가동 범위';

  @override
  String get phase => '페이즈';

  @override
  String get ascending => '상승';

  @override
  String get descending => '하강';

  @override
  String get atTop => '상단';

  @override
  String get atBottom => '하단';

  @override
  String get idle => '대기';

  @override
  String get sessionReview => '세션 리뷰';

  @override
  String get sessionSummary => '세션 요약';

  @override
  String get saveSession => '세션 저장';

  @override
  String get shareSession => '공유';

  @override
  String get discardSession => '삭제';

  @override
  String get totalReps => '총 반복수';

  @override
  String get totalSets => '총 세트수';

  @override
  String get avgVelocity => '평균 속도';

  @override
  String get sessionDuration => '운동 시간';

  @override
  String get noSessions => '기록된 세션이 없습니다';

  @override
  String get recording => '녹화 중';

  @override
  String get startRecording => '녹화 시작';

  @override
  String get stopRecording => '녹화 중지';

  @override
  String get savedToGallery => '갤러리에 저장되었습니다';

  @override
  String get cameraPermission => '카메라 권한이 필요합니다';

  @override
  String get storagePermission => '저장소 권한이 필요합니다';

  @override
  String get grantPermission => '권한 허용';

  @override
  String get onboardingTitle1 => '바벨 경로를 추적하세요';

  @override
  String get onboardingDesc1 => 'AI가 실시간으로 바벨의 움직임을 분석합니다';

  @override
  String get onboardingTitle2 => '속도 기반 훈련';

  @override
  String get onboardingDesc2 => 'VBT 존 분석으로 최적의 훈련 강도를 찾으세요';

  @override
  String get onboardingTitle3 => '영상으로 기록하세요';

  @override
  String get onboardingDesc3 => '바벨 경로가 합성된 영상을 저장하고 공유하세요';

  @override
  String get getStarted => '시작하기';

  @override
  String get next => '다음';

  @override
  String get skip => '건너뛰기';

  @override
  String get darkMode => '다크 모드';

  @override
  String get language => '언어';

  @override
  String get about => '앱 정보';

  @override
  String get version => '버전';

  @override
  String get premium => '프리미엄';

  @override
  String get premiumDescription => '모든 기능을 잠금 해제하세요';

  @override
  String get delete => '삭제';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get ok => '확인';

  @override
  String get error => '오류';

  @override
  String get retry => '다시 시도';

  @override
  String get loading => '로딩 중...';

  @override
  String get noData => '데이터 없음';

  @override
  String get strengthZone => '근력';

  @override
  String get strengthSpeedZone => '근력-스피드';

  @override
  String get powerZone => '파워';

  @override
  String get speedStrengthZone => '스피드-근력';

  @override
  String get speedZone => '스피드';
}
