// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'PoinT 杠铃轨迹';

  @override
  String get home => '首页';

  @override
  String get history => '历史';

  @override
  String get settings => '设置';

  @override
  String get quickStart => '快速开始';

  @override
  String get recentSessions => '最近的训练';

  @override
  String get startTracking => '开始追踪';

  @override
  String get stopTracking => '停止追踪';

  @override
  String get newSet => '新组';

  @override
  String get finishSet => '完成该组';

  @override
  String get selectExercise => '选择动作';

  @override
  String get squat => '深蹲';

  @override
  String get benchPress => '卧推';

  @override
  String get deadlift => '硬拉';

  @override
  String get overheadPress => '过头推举';

  @override
  String get custom => '自定义';

  @override
  String get calibration => '校准';

  @override
  String get calibrationDescription => '设置相机以进行精确测量';

  @override
  String get cameraDistance => '相机距离';

  @override
  String metersAway(String meters) {
    return '距离$meters米';
  }

  @override
  String get reps => '次数';

  @override
  String get sets => '组数';

  @override
  String repCount(int count) {
    return '$count次';
  }

  @override
  String setCount(int count) {
    return '$count组';
  }

  @override
  String get velocity => '速度';

  @override
  String get peakVelocity => '峰值速度';

  @override
  String get meanVelocity => '平均速度';

  @override
  String get rom => '运动范围';

  @override
  String get phase => '阶段';

  @override
  String get ascending => '上升';

  @override
  String get descending => '下降';

  @override
  String get atTop => '顶部';

  @override
  String get atBottom => '底部';

  @override
  String get idle => '待机';

  @override
  String get sessionReview => '训练回顾';

  @override
  String get sessionSummary => '训练总结';

  @override
  String get saveSession => '保存训练';

  @override
  String get shareSession => '分享';

  @override
  String get discardSession => '删除';

  @override
  String get totalReps => '总次数';

  @override
  String get totalSets => '总组数';

  @override
  String get avgVelocity => '平均速度';

  @override
  String get sessionDuration => '训练时长';

  @override
  String get noSessions => '暂无训练记录';

  @override
  String get recording => '录制中';

  @override
  String get startRecording => '开始录制';

  @override
  String get stopRecording => '停止录制';

  @override
  String get savedToGallery => '已保存到相册';

  @override
  String get cameraPermission => '需要相机权限';

  @override
  String get storagePermission => '需要存储权限';

  @override
  String get grantPermission => '授予权限';

  @override
  String get onboardingTitle1 => '追踪杠铃轨迹';

  @override
  String get onboardingDesc1 => 'AI实时分析杠铃运动轨迹';

  @override
  String get onboardingTitle2 => '基于速度的训练';

  @override
  String get onboardingDesc2 => '通过VBT区间分析找到最佳训练强度';

  @override
  String get onboardingTitle3 => '视频记录训练';

  @override
  String get onboardingDesc3 => '保存和分享叠加了杠铃轨迹的训练视频';

  @override
  String get getStarted => '开始使用';

  @override
  String get next => '下一步';

  @override
  String get skip => '跳过';

  @override
  String get darkMode => '深色模式';

  @override
  String get language => '语言';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get premium => '高级版';

  @override
  String get premiumDescription => '解锁全部功能';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get ok => '确定';

  @override
  String get error => '错误';

  @override
  String get retry => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get noData => '暂无数据';

  @override
  String get strengthZone => '力量';

  @override
  String get strengthSpeedZone => '力量-速度';

  @override
  String get powerZone => '爆发力';

  @override
  String get speedStrengthZone => '速度-力量';

  @override
  String get speedZone => '速度';
}
