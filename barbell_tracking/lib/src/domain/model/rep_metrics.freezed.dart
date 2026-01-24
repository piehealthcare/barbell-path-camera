// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rep_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RepMetrics _$RepMetricsFromJson(Map<String, dynamic> json) {
  return _RepMetrics.fromJson(json);
}

/// @nodoc
mixin _$RepMetrics {
  /// Rep 번호 (1부터 시작)
  int get repNumber => throw _privateConstructorUsedError;

  /// 평균 속도 (m/s)
  double get meanVelocity => throw _privateConstructorUsedError;

  /// 최대 속도 (m/s)
  double get peakVelocity => throw _privateConstructorUsedError;

  /// 운동 범위 (m)
  double get rangeOfMotion => throw _privateConstructorUsedError;

  /// 시작 시간 (초)
  double get startTime => throw _privateConstructorUsedError;

  /// 종료 시간 (초)
  double get endTime => throw _privateConstructorUsedError;

  /// 속도 감소율 (%) - 첫 번째 rep 대비
  double? get velocityLoss => throw _privateConstructorUsedError;

  /// 평균 파워 (W) - 옵션
  double? get meanPower => throw _privateConstructorUsedError;

  /// 최대 파워 (W) - 옵션
  double? get peakPower => throw _privateConstructorUsedError;

  /// Serializes this RepMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RepMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RepMetricsCopyWith<RepMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepMetricsCopyWith<$Res> {
  factory $RepMetricsCopyWith(
          RepMetrics value, $Res Function(RepMetrics) then) =
      _$RepMetricsCopyWithImpl<$Res, RepMetrics>;
  @useResult
  $Res call(
      {int repNumber,
      double meanVelocity,
      double peakVelocity,
      double rangeOfMotion,
      double startTime,
      double endTime,
      double? velocityLoss,
      double? meanPower,
      double? peakPower});
}

/// @nodoc
class _$RepMetricsCopyWithImpl<$Res, $Val extends RepMetrics>
    implements $RepMetricsCopyWith<$Res> {
  _$RepMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RepMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repNumber = null,
    Object? meanVelocity = null,
    Object? peakVelocity = null,
    Object? rangeOfMotion = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? velocityLoss = freezed,
    Object? meanPower = freezed,
    Object? peakPower = freezed,
  }) {
    return _then(_value.copyWith(
      repNumber: null == repNumber
          ? _value.repNumber
          : repNumber // ignore: cast_nullable_to_non_nullable
              as int,
      meanVelocity: null == meanVelocity
          ? _value.meanVelocity
          : meanVelocity // ignore: cast_nullable_to_non_nullable
              as double,
      peakVelocity: null == peakVelocity
          ? _value.peakVelocity
          : peakVelocity // ignore: cast_nullable_to_non_nullable
              as double,
      rangeOfMotion: null == rangeOfMotion
          ? _value.rangeOfMotion
          : rangeOfMotion // ignore: cast_nullable_to_non_nullable
              as double,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as double,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as double,
      velocityLoss: freezed == velocityLoss
          ? _value.velocityLoss
          : velocityLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      meanPower: freezed == meanPower
          ? _value.meanPower
          : meanPower // ignore: cast_nullable_to_non_nullable
              as double?,
      peakPower: freezed == peakPower
          ? _value.peakPower
          : peakPower // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RepMetricsImplCopyWith<$Res>
    implements $RepMetricsCopyWith<$Res> {
  factory _$$RepMetricsImplCopyWith(
          _$RepMetricsImpl value, $Res Function(_$RepMetricsImpl) then) =
      __$$RepMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int repNumber,
      double meanVelocity,
      double peakVelocity,
      double rangeOfMotion,
      double startTime,
      double endTime,
      double? velocityLoss,
      double? meanPower,
      double? peakPower});
}

/// @nodoc
class __$$RepMetricsImplCopyWithImpl<$Res>
    extends _$RepMetricsCopyWithImpl<$Res, _$RepMetricsImpl>
    implements _$$RepMetricsImplCopyWith<$Res> {
  __$$RepMetricsImplCopyWithImpl(
      _$RepMetricsImpl _value, $Res Function(_$RepMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RepMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repNumber = null,
    Object? meanVelocity = null,
    Object? peakVelocity = null,
    Object? rangeOfMotion = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? velocityLoss = freezed,
    Object? meanPower = freezed,
    Object? peakPower = freezed,
  }) {
    return _then(_$RepMetricsImpl(
      repNumber: null == repNumber
          ? _value.repNumber
          : repNumber // ignore: cast_nullable_to_non_nullable
              as int,
      meanVelocity: null == meanVelocity
          ? _value.meanVelocity
          : meanVelocity // ignore: cast_nullable_to_non_nullable
              as double,
      peakVelocity: null == peakVelocity
          ? _value.peakVelocity
          : peakVelocity // ignore: cast_nullable_to_non_nullable
              as double,
      rangeOfMotion: null == rangeOfMotion
          ? _value.rangeOfMotion
          : rangeOfMotion // ignore: cast_nullable_to_non_nullable
              as double,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as double,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as double,
      velocityLoss: freezed == velocityLoss
          ? _value.velocityLoss
          : velocityLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      meanPower: freezed == meanPower
          ? _value.meanPower
          : meanPower // ignore: cast_nullable_to_non_nullable
              as double?,
      peakPower: freezed == peakPower
          ? _value.peakPower
          : peakPower // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RepMetricsImpl extends _RepMetrics {
  const _$RepMetricsImpl(
      {required this.repNumber,
      required this.meanVelocity,
      required this.peakVelocity,
      required this.rangeOfMotion,
      required this.startTime,
      required this.endTime,
      this.velocityLoss,
      this.meanPower,
      this.peakPower})
      : super._();

  factory _$RepMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RepMetricsImplFromJson(json);

  /// Rep 번호 (1부터 시작)
  @override
  final int repNumber;

  /// 평균 속도 (m/s)
  @override
  final double meanVelocity;

  /// 최대 속도 (m/s)
  @override
  final double peakVelocity;

  /// 운동 범위 (m)
  @override
  final double rangeOfMotion;

  /// 시작 시간 (초)
  @override
  final double startTime;

  /// 종료 시간 (초)
  @override
  final double endTime;

  /// 속도 감소율 (%) - 첫 번째 rep 대비
  @override
  final double? velocityLoss;

  /// 평균 파워 (W) - 옵션
  @override
  final double? meanPower;

  /// 최대 파워 (W) - 옵션
  @override
  final double? peakPower;

  @override
  String toString() {
    return 'RepMetrics(repNumber: $repNumber, meanVelocity: $meanVelocity, peakVelocity: $peakVelocity, rangeOfMotion: $rangeOfMotion, startTime: $startTime, endTime: $endTime, velocityLoss: $velocityLoss, meanPower: $meanPower, peakPower: $peakPower)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepMetricsImpl &&
            (identical(other.repNumber, repNumber) ||
                other.repNumber == repNumber) &&
            (identical(other.meanVelocity, meanVelocity) ||
                other.meanVelocity == meanVelocity) &&
            (identical(other.peakVelocity, peakVelocity) ||
                other.peakVelocity == peakVelocity) &&
            (identical(other.rangeOfMotion, rangeOfMotion) ||
                other.rangeOfMotion == rangeOfMotion) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.velocityLoss, velocityLoss) ||
                other.velocityLoss == velocityLoss) &&
            (identical(other.meanPower, meanPower) ||
                other.meanPower == meanPower) &&
            (identical(other.peakPower, peakPower) ||
                other.peakPower == peakPower));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      repNumber,
      meanVelocity,
      peakVelocity,
      rangeOfMotion,
      startTime,
      endTime,
      velocityLoss,
      meanPower,
      peakPower);

  /// Create a copy of RepMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RepMetricsImplCopyWith<_$RepMetricsImpl> get copyWith =>
      __$$RepMetricsImplCopyWithImpl<_$RepMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RepMetricsImplToJson(
      this,
    );
  }
}

abstract class _RepMetrics extends RepMetrics {
  const factory _RepMetrics(
      {required final int repNumber,
      required final double meanVelocity,
      required final double peakVelocity,
      required final double rangeOfMotion,
      required final double startTime,
      required final double endTime,
      final double? velocityLoss,
      final double? meanPower,
      final double? peakPower}) = _$RepMetricsImpl;
  const _RepMetrics._() : super._();

  factory _RepMetrics.fromJson(Map<String, dynamic> json) =
      _$RepMetricsImpl.fromJson;

  /// Rep 번호 (1부터 시작)
  @override
  int get repNumber;

  /// 평균 속도 (m/s)
  @override
  double get meanVelocity;

  /// 최대 속도 (m/s)
  @override
  double get peakVelocity;

  /// 운동 범위 (m)
  @override
  double get rangeOfMotion;

  /// 시작 시간 (초)
  @override
  double get startTime;

  /// 종료 시간 (초)
  @override
  double get endTime;

  /// 속도 감소율 (%) - 첫 번째 rep 대비
  @override
  double? get velocityLoss;

  /// 평균 파워 (W) - 옵션
  @override
  double? get meanPower;

  /// 최대 파워 (W) - 옵션
  @override
  double? get peakPower;

  /// Create a copy of RepMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RepMetricsImplCopyWith<_$RepMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
