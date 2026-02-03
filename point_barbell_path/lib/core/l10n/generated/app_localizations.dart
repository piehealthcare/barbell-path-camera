import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'PoinT 바벨패스'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home;

  /// No description provided for @history.
  ///
  /// In ko, this message translates to:
  /// **'기록'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @quickStart.
  ///
  /// In ko, this message translates to:
  /// **'빠른 시작'**
  String get quickStart;

  /// No description provided for @recentSessions.
  ///
  /// In ko, this message translates to:
  /// **'최근 세션'**
  String get recentSessions;

  /// No description provided for @startTracking.
  ///
  /// In ko, this message translates to:
  /// **'트래킹 시작'**
  String get startTracking;

  /// No description provided for @stopTracking.
  ///
  /// In ko, this message translates to:
  /// **'트래킹 중지'**
  String get stopTracking;

  /// No description provided for @newSet.
  ///
  /// In ko, this message translates to:
  /// **'새 세트'**
  String get newSet;

  /// No description provided for @finishSet.
  ///
  /// In ko, this message translates to:
  /// **'세트 완료'**
  String get finishSet;

  /// No description provided for @selectExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 선택'**
  String get selectExercise;

  /// No description provided for @squat.
  ///
  /// In ko, this message translates to:
  /// **'스쿼트'**
  String get squat;

  /// No description provided for @benchPress.
  ///
  /// In ko, this message translates to:
  /// **'벤치프레스'**
  String get benchPress;

  /// No description provided for @deadlift.
  ///
  /// In ko, this message translates to:
  /// **'데드리프트'**
  String get deadlift;

  /// No description provided for @overheadPress.
  ///
  /// In ko, this message translates to:
  /// **'오버헤드프레스'**
  String get overheadPress;

  /// No description provided for @custom.
  ///
  /// In ko, this message translates to:
  /// **'사용자 지정'**
  String get custom;

  /// No description provided for @calibration.
  ///
  /// In ko, this message translates to:
  /// **'캘리브레이션'**
  String get calibration;

  /// No description provided for @calibrationDescription.
  ///
  /// In ko, this message translates to:
  /// **'정확한 측정을 위해 카메라를 설정합니다'**
  String get calibrationDescription;

  /// No description provided for @cameraDistance.
  ///
  /// In ko, this message translates to:
  /// **'카메라 거리'**
  String get cameraDistance;

  /// No description provided for @metersAway.
  ///
  /// In ko, this message translates to:
  /// **'{meters}m 거리'**
  String metersAway(String meters);

  /// No description provided for @reps.
  ///
  /// In ko, this message translates to:
  /// **'반복'**
  String get reps;

  /// No description provided for @sets.
  ///
  /// In ko, this message translates to:
  /// **'세트'**
  String get sets;

  /// No description provided for @repCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String repCount(int count);

  /// No description provided for @setCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}세트'**
  String setCount(int count);

  /// No description provided for @velocity.
  ///
  /// In ko, this message translates to:
  /// **'속도'**
  String get velocity;

  /// No description provided for @peakVelocity.
  ///
  /// In ko, this message translates to:
  /// **'최대 속도'**
  String get peakVelocity;

  /// No description provided for @meanVelocity.
  ///
  /// In ko, this message translates to:
  /// **'평균 속도'**
  String get meanVelocity;

  /// No description provided for @rom.
  ///
  /// In ko, this message translates to:
  /// **'가동 범위'**
  String get rom;

  /// No description provided for @phase.
  ///
  /// In ko, this message translates to:
  /// **'페이즈'**
  String get phase;

  /// No description provided for @ascending.
  ///
  /// In ko, this message translates to:
  /// **'상승'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In ko, this message translates to:
  /// **'하강'**
  String get descending;

  /// No description provided for @atTop.
  ///
  /// In ko, this message translates to:
  /// **'상단'**
  String get atTop;

  /// No description provided for @atBottom.
  ///
  /// In ko, this message translates to:
  /// **'하단'**
  String get atBottom;

  /// No description provided for @idle.
  ///
  /// In ko, this message translates to:
  /// **'대기'**
  String get idle;

  /// No description provided for @sessionReview.
  ///
  /// In ko, this message translates to:
  /// **'세션 리뷰'**
  String get sessionReview;

  /// No description provided for @sessionSummary.
  ///
  /// In ko, this message translates to:
  /// **'세션 요약'**
  String get sessionSummary;

  /// No description provided for @saveSession.
  ///
  /// In ko, this message translates to:
  /// **'세션 저장'**
  String get saveSession;

  /// No description provided for @shareSession.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get shareSession;

  /// No description provided for @discardSession.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get discardSession;

  /// No description provided for @totalReps.
  ///
  /// In ko, this message translates to:
  /// **'총 반복수'**
  String get totalReps;

  /// No description provided for @totalSets.
  ///
  /// In ko, this message translates to:
  /// **'총 세트수'**
  String get totalSets;

  /// No description provided for @avgVelocity.
  ///
  /// In ko, this message translates to:
  /// **'평균 속도'**
  String get avgVelocity;

  /// No description provided for @sessionDuration.
  ///
  /// In ko, this message translates to:
  /// **'운동 시간'**
  String get sessionDuration;

  /// No description provided for @noSessions.
  ///
  /// In ko, this message translates to:
  /// **'기록된 세션이 없습니다'**
  String get noSessions;

  /// No description provided for @recording.
  ///
  /// In ko, this message translates to:
  /// **'녹화 중'**
  String get recording;

  /// No description provided for @startRecording.
  ///
  /// In ko, this message translates to:
  /// **'녹화 시작'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In ko, this message translates to:
  /// **'녹화 중지'**
  String get stopRecording;

  /// No description provided for @savedToGallery.
  ///
  /// In ko, this message translates to:
  /// **'갤러리에 저장되었습니다'**
  String get savedToGallery;

  /// No description provided for @cameraPermission.
  ///
  /// In ko, this message translates to:
  /// **'카메라 권한이 필요합니다'**
  String get cameraPermission;

  /// No description provided for @storagePermission.
  ///
  /// In ko, this message translates to:
  /// **'저장소 권한이 필요합니다'**
  String get storagePermission;

  /// No description provided for @grantPermission.
  ///
  /// In ko, this message translates to:
  /// **'권한 허용'**
  String get grantPermission;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ko, this message translates to:
  /// **'바벨 경로를 추적하세요'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ko, this message translates to:
  /// **'AI가 실시간으로 바벨의 움직임을 분석합니다'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ko, this message translates to:
  /// **'속도 기반 훈련'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ko, this message translates to:
  /// **'VBT 존 분석으로 최적의 훈련 강도를 찾으세요'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ko, this message translates to:
  /// **'영상으로 기록하세요'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ko, this message translates to:
  /// **'바벨 경로가 합성된 영상을 저장하고 공유하세요'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get skip;

  /// No description provided for @darkMode.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @about.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get about;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @premium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄'**
  String get premium;

  /// No description provided for @premiumDescription.
  ///
  /// In ko, this message translates to:
  /// **'모든 기능을 잠금 해제하세요'**
  String get premiumDescription;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'오류'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ko, this message translates to:
  /// **'로딩 중...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ko, this message translates to:
  /// **'데이터 없음'**
  String get noData;

  /// No description provided for @strengthZone.
  ///
  /// In ko, this message translates to:
  /// **'근력'**
  String get strengthZone;

  /// No description provided for @strengthSpeedZone.
  ///
  /// In ko, this message translates to:
  /// **'근력-스피드'**
  String get strengthSpeedZone;

  /// No description provided for @powerZone.
  ///
  /// In ko, this message translates to:
  /// **'파워'**
  String get powerZone;

  /// No description provided for @speedStrengthZone.
  ///
  /// In ko, this message translates to:
  /// **'스피드-근력'**
  String get speedStrengthZone;

  /// No description provided for @speedZone.
  ///
  /// In ko, this message translates to:
  /// **'스피드'**
  String get speedZone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
