// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrackingPoint _$TrackingPointFromJson(Map<String, dynamic> json) {
  return _TrackingPoint.fromJson(json);
}

/// @nodoc
mixin _$TrackingPoint {
  /// 타임스탬프 (초 단위)
  double get timestamp => throw _privateConstructorUsedError;

  /// 위치 (normalized 0-1)
  double get positionX => throw _privateConstructorUsedError;
  double get positionY => throw _privateConstructorUsedError;

  /// Y축 속도 (m/s) - 상하 운동
  double get velocityY => throw _privateConstructorUsedError;

  /// Y축 가속도 (m/s²)
  double get accelerationY => throw _privateConstructorUsedError;

  /// 순간 파워 (W) - 옵션
  double? get power => throw _privateConstructorUsedError;

  /// 감지 신뢰도
  double get confidence => throw _privateConstructorUsedError;

  /// Serializes this TrackingPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackingPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackingPointCopyWith<TrackingPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackingPointCopyWith<$Res> {
  factory $TrackingPointCopyWith(
          TrackingPoint value, $Res Function(TrackingPoint) then) =
      _$TrackingPointCopyWithImpl<$Res, TrackingPoint>;
  @useResult
  $Res call(
      {double timestamp,
      double positionX,
      double positionY,
      double velocityY,
      double accelerationY,
      double? power,
      double confidence});
}

/// @nodoc
class _$TrackingPointCopyWithImpl<$Res, $Val extends TrackingPoint>
    implements $TrackingPointCopyWith<$Res> {
  _$TrackingPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackingPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? positionX = null,
    Object? positionY = null,
    Object? velocityY = null,
    Object? accelerationY = null,
    Object? power = freezed,
    Object? confidence = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as double,
      positionX: null == positionX
          ? _value.positionX
          : positionX // ignore: cast_nullable_to_non_nullable
              as double,
      positionY: null == positionY
          ? _value.positionY
          : positionY // ignore: cast_nullable_to_non_nullable
              as double,
      velocityY: null == velocityY
          ? _value.velocityY
          : velocityY // ignore: cast_nullable_to_non_nullable
              as double,
      accelerationY: null == accelerationY
          ? _value.accelerationY
          : accelerationY // ignore: cast_nullable_to_non_nullable
              as double,
      power: freezed == power
          ? _value.power
          : power // ignore: cast_nullable_to_non_nullable
              as double?,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackingPointImplCopyWith<$Res>
    implements $TrackingPointCopyWith<$Res> {
  factory _$$TrackingPointImplCopyWith(
          _$TrackingPointImpl value, $Res Function(_$TrackingPointImpl) then) =
      __$$TrackingPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double timestamp,
      double positionX,
      double positionY,
      double velocityY,
      double accelerationY,
      double? power,
      double confidence});
}

/// @nodoc
class __$$TrackingPointImplCopyWithImpl<$Res>
    extends _$TrackingPointCopyWithImpl<$Res, _$TrackingPointImpl>
    implements _$$TrackingPointImplCopyWith<$Res> {
  __$$TrackingPointImplCopyWithImpl(
      _$TrackingPointImpl _value, $Res Function(_$TrackingPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackingPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? positionX = null,
    Object? positionY = null,
    Object? velocityY = null,
    Object? accelerationY = null,
    Object? power = freezed,
    Object? confidence = null,
  }) {
    return _then(_$TrackingPointImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as double,
      positionX: null == positionX
          ? _value.positionX
          : positionX // ignore: cast_nullable_to_non_nullable
              as double,
      positionY: null == positionY
          ? _value.positionY
          : positionY // ignore: cast_nullable_to_non_nullable
              as double,
      velocityY: null == velocityY
          ? _value.velocityY
          : velocityY // ignore: cast_nullable_to_non_nullable
              as double,
      accelerationY: null == accelerationY
          ? _value.accelerationY
          : accelerationY // ignore: cast_nullable_to_non_nullable
              as double,
      power: freezed == power
          ? _value.power
          : power // ignore: cast_nullable_to_non_nullable
              as double?,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackingPointImpl extends _TrackingPoint {
  const _$TrackingPointImpl(
      {required this.timestamp,
      required this.positionX,
      required this.positionY,
      required this.velocityY,
      required this.accelerationY,
      this.power,
      this.confidence = 1.0})
      : super._();

  factory _$TrackingPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackingPointImplFromJson(json);

  /// 타임스탬프 (초 단위)
  @override
  final double timestamp;

  /// 위치 (normalized 0-1)
  @override
  final double positionX;
  @override
  final double positionY;

  /// Y축 속도 (m/s) - 상하 운동
  @override
  final double velocityY;

  /// Y축 가속도 (m/s²)
  @override
  final double accelerationY;

  /// 순간 파워 (W) - 옵션
  @override
  final double? power;

  /// 감지 신뢰도
  @override
  @JsonKey()
  final double confidence;

  @override
  String toString() {
    return 'TrackingPoint(timestamp: $timestamp, positionX: $positionX, positionY: $positionY, velocityY: $velocityY, accelerationY: $accelerationY, power: $power, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackingPointImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.positionX, positionX) ||
                other.positionX == positionX) &&
            (identical(other.positionY, positionY) ||
                other.positionY == positionY) &&
            (identical(other.velocityY, velocityY) ||
                other.velocityY == velocityY) &&
            (identical(other.accelerationY, accelerationY) ||
                other.accelerationY == accelerationY) &&
            (identical(other.power, power) || other.power == power) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, positionX, positionY,
      velocityY, accelerationY, power, confidence);

  /// Create a copy of TrackingPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackingPointImplCopyWith<_$TrackingPointImpl> get copyWith =>
      __$$TrackingPointImplCopyWithImpl<_$TrackingPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackingPointImplToJson(
      this,
    );
  }
}

abstract class _TrackingPoint extends TrackingPoint {
  const factory _TrackingPoint(
      {required final double timestamp,
      required final double positionX,
      required final double positionY,
      required final double velocityY,
      required final double accelerationY,
      final double? power,
      final double confidence}) = _$TrackingPointImpl;
  const _TrackingPoint._() : super._();

  factory _TrackingPoint.fromJson(Map<String, dynamic> json) =
      _$TrackingPointImpl.fromJson;

  /// 타임스탬프 (초 단위)
  @override
  double get timestamp;

  /// 위치 (normalized 0-1)
  @override
  double get positionX;
  @override
  double get positionY;

  /// Y축 속도 (m/s) - 상하 운동
  @override
  double get velocityY;

  /// Y축 가속도 (m/s²)
  @override
  double get accelerationY;

  /// 순간 파워 (W) - 옵션
  @override
  double? get power;

  /// 감지 신뢰도
  @override
  double get confidence;

  /// Create a copy of TrackingPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackingPointImplCopyWith<_$TrackingPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
