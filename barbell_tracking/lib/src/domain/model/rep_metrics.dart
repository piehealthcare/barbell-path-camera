import 'package:freezed_annotation/freezed_annotation.dart';

part 'rep_metrics.freezed.dart';
part 'rep_metrics.g.dart';

/// Rep별 VBT 지표
@freezed
class RepMetrics with _$RepMetrics {
  const RepMetrics._();

  const factory RepMetrics({
    /// Rep 번호 (1부터 시작)
    required int repNumber,

    /// 평균 속도 (m/s)
    required double meanVelocity,

    /// 최대 속도 (m/s)
    required double peakVelocity,

    /// 운동 범위 (m)
    required double rangeOfMotion,

    /// 시작 시간 (초)
    required double startTime,

    /// 종료 시간 (초)
    required double endTime,

    /// 속도 감소율 (%) - 첫 번째 rep 대비
    double? velocityLoss,

    /// 평균 파워 (W) - 옵션
    double? meanPower,

    /// 최대 파워 (W) - 옵션
    double? peakPower,
  }) = _RepMetrics;

  factory RepMetrics.fromJson(Map<String, dynamic> json) =>
      _$RepMetricsFromJson(json);

  /// Rep 수행 시간 (초)
  double get duration => endTime - startTime;

  /// Velocity Zone 색상 판별용
  VelocityZone get velocityZone {
    if (meanVelocity >= 1.0) return VelocityZone.speed;
    if (meanVelocity >= 0.75) return VelocityZone.speedStrength;
    if (meanVelocity >= 0.5) return VelocityZone.strength;
    if (meanVelocity >= 0.35) return VelocityZone.accelerativeStrength;
    return VelocityZone.maxStrength;
  }
}

/// VBT 속도 존
enum VelocityZone {
  /// > 1.0 m/s - 스피드 훈련
  speed,

  /// 0.75 - 1.0 m/s - 스피드-근력
  speedStrength,

  /// 0.5 - 0.75 m/s - 근력
  strength,

  /// 0.35 - 0.5 m/s - 가속 근력
  accelerativeStrength,

  /// < 0.35 m/s - 최대 근력
  maxStrength,
}
