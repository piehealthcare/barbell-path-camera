import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:barbell_tracking/src/domain/model/barbell_path.dart';
import 'package:barbell_tracking/src/domain/model/rep_metrics.dart';
import 'package:barbell_tracking/src/domain/model/tracking_point.dart';

part 'tracking_session.freezed.dart';
part 'tracking_session.g.dart';

/// 트래킹 세션 상태
enum TrackingSessionStatus {
  /// 초기화 대기
  idle,

  /// 캘리브레이션 중
  calibrating,

  /// 추적 준비 완료
  ready,

  /// 추적 중
  tracking,

  /// 일시 정지
  paused,

  /// 완료
  completed,

  /// 오류
  error,
}

/// 트래킹 세션 - 전체 운동 세션 데이터
@freezed
class TrackingSession with _$TrackingSession {
  const TrackingSession._();

  const factory TrackingSession({
    /// 세션 고유 ID
    required String id,

    /// 세션 상태
    @Default(TrackingSessionStatus.idle) TrackingSessionStatus status,

    /// 세션 시작 시간
    DateTime? startedAt,

    /// 세션 종료 시간
    DateTime? endedAt,

    /// 운동 무게 (kg)
    @Default(20.0) double weight,

    /// 운동 이름
    String? exerciseName,

    /// 완료된 Rep 경로들
    @Default([]) List<BarbellPath> completedPaths,

    /// 현재 진행 중인 경로
    BarbellPath? currentPath,

    /// Rep별 지표 목록
    @Default([]) List<RepMetrics> repMetrics,

    /// 현재 추적 포인트 (실시간 표시용)
    TrackingPoint? currentPoint,

    /// 캘리브레이션: 픽셀당 미터 비율
    double? pixelsPerMeter,

    /// 프레임 인덱스
    @Default(0) int frameIndex,

    /// 에러 메시지
    String? errorMessage,
  }) = _TrackingSession;

  factory TrackingSession.fromJson(Map<String, dynamic> json) =>
      _$TrackingSessionFromJson(json);

  /// 현재 Rep 번호
  int get currentRepNumber => completedPaths.length + 1;

  /// 총 Rep 수
  int get totalReps => completedPaths.length;

  /// 세션 진행 중 여부
  bool get isActive =>
      status == TrackingSessionStatus.tracking ||
      status == TrackingSessionStatus.calibrating;

  /// 평균 속도 (전체 세션)
  double get sessionMeanVelocity {
    if (repMetrics.isEmpty) return 0;
    final sum = repMetrics.map((r) => r.meanVelocity).reduce((a, b) => a + b);
    return sum / repMetrics.length;
  }

  /// 속도 감소율 (마지막 rep vs 첫 번째 rep)
  double? get velocityLossPercent {
    if (repMetrics.length < 2) return null;
    final firstVel = repMetrics.first.meanVelocity;
    final lastVel = repMetrics.last.meanVelocity;
    if (firstVel == 0) return null;
    return ((firstVel - lastVel) / firstVel) * 100;
  }

  /// 세션 지속 시간
  Duration? get sessionDuration {
    if (startedAt == null) return null;
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt!);
  }

  /// 모든 추적 포인트 (시각화용)
  List<TrackingPoint> get allPoints {
    final points = <TrackingPoint>[];
    for (final path in completedPaths) {
      points.addAll(path.points);
    }
    if (currentPath != null) {
      points.addAll(currentPath!.points);
    }
    return points;
  }
}
