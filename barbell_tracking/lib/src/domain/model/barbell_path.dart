import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:barbell_tracking/src/domain/model/tracking_point.dart';

part 'barbell_path.freezed.dart';
part 'barbell_path.g.dart';

/// 바벨 궤적 데이터 - 한 Rep 동안의 추적 포인트 모음
@freezed
class BarbellPath with _$BarbellPath {
  const BarbellPath._();

  const factory BarbellPath({
    /// 추적 포인트 리스트
    required List<TrackingPoint> points,

    /// Rep 시작 시간
    required double startTime,

    /// Rep 종료 시간
    double? endTime,

    /// 운동 방향 (true: 상승, false: 하강)
    @Default(true) bool isAscending,
  }) = _BarbellPath;

  factory BarbellPath.fromJson(Map<String, dynamic> json) =>
      _$BarbellPathFromJson(json);

  /// 경로 지속 시간
  double get duration {
    if (points.isEmpty) return 0;
    return (endTime ?? points.last.timestamp) - startTime;
  }

  /// Y축 이동 거리 (normalized)
  double get verticalDisplacement {
    if (points.length < 2) return 0;
    return (points.first.positionY - points.last.positionY).abs();
  }

  /// 평균 속도
  double get meanVelocity {
    if (points.isEmpty) return 0;
    final velocities = points.map((p) => p.velocityY.abs()).toList();
    return velocities.reduce((a, b) => a + b) / velocities.length;
  }

  /// 최대 속도
  double get peakVelocity {
    if (points.isEmpty) return 0;
    return points.map((p) => p.velocityY.abs()).reduce((a, b) => a > b ? a : b);
  }

  /// 마지막 포인트
  TrackingPoint? get lastPoint => points.isEmpty ? null : points.last;

  /// 첫 번째 포인트
  TrackingPoint? get firstPoint => points.isEmpty ? null : points.first;
}
