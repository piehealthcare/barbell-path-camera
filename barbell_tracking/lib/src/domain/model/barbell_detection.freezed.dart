// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'barbell_detection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BarbellDetection _$BarbellDetectionFromJson(Map<String, dynamic> json) {
  return _BarbellDetection.fromJson(json);
}

/// @nodoc
mixin _$BarbellDetection {
  /// 프레임 인덱스
  int get frameIndex => throw _privateConstructorUsedError;

  /// 타임스탬프 (초 단위)
  double get timestamp => throw _privateConstructorUsedError;

  /// 바벨 중심점 (normalized 0-1)
  double get centerX => throw _privateConstructorUsedError;
  double get centerY => throw _privateConstructorUsedError;

  /// 바운딩 박스 (normalized 0-1)
  double get boxLeft => throw _privateConstructorUsedError;
  double get boxTop => throw _privateConstructorUsedError;
  double get boxWidth => throw _privateConstructorUsedError;
  double get boxHeight => throw _privateConstructorUsedError;

  /// 감지 신뢰도 (0-1)
  double get confidence => throw _privateConstructorUsedError;

  /// Serializes this BarbellDetection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BarbellDetection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BarbellDetectionCopyWith<BarbellDetection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BarbellDetectionCopyWith<$Res> {
  factory $BarbellDetectionCopyWith(
          BarbellDetection value, $Res Function(BarbellDetection) then) =
      _$BarbellDetectionCopyWithImpl<$Res, BarbellDetection>;
  @useResult
  $Res call(
      {int frameIndex,
      double timestamp,
      double centerX,
      double centerY,
      double boxLeft,
      double boxTop,
      double boxWidth,
      double boxHeight,
      double confidence});
}

/// @nodoc
class _$BarbellDetectionCopyWithImpl<$Res, $Val extends BarbellDetection>
    implements $BarbellDetectionCopyWith<$Res> {
  _$BarbellDetectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BarbellDetection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frameIndex = null,
    Object? timestamp = null,
    Object? centerX = null,
    Object? centerY = null,
    Object? boxLeft = null,
    Object? boxTop = null,
    Object? boxWidth = null,
    Object? boxHeight = null,
    Object? confidence = null,
  }) {
    return _then(_value.copyWith(
      frameIndex: null == frameIndex
          ? _value.frameIndex
          : frameIndex // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as double,
      centerX: null == centerX
          ? _value.centerX
          : centerX // ignore: cast_nullable_to_non_nullable
              as double,
      centerY: null == centerY
          ? _value.centerY
          : centerY // ignore: cast_nullable_to_non_nullable
              as double,
      boxLeft: null == boxLeft
          ? _value.boxLeft
          : boxLeft // ignore: cast_nullable_to_non_nullable
              as double,
      boxTop: null == boxTop
          ? _value.boxTop
          : boxTop // ignore: cast_nullable_to_non_nullable
              as double,
      boxWidth: null == boxWidth
          ? _value.boxWidth
          : boxWidth // ignore: cast_nullable_to_non_nullable
              as double,
      boxHeight: null == boxHeight
          ? _value.boxHeight
          : boxHeight // ignore: cast_nullable_to_non_nullable
              as double,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BarbellDetectionImplCopyWith<$Res>
    implements $BarbellDetectionCopyWith<$Res> {
  factory _$$BarbellDetectionImplCopyWith(_$BarbellDetectionImpl value,
          $Res Function(_$BarbellDetectionImpl) then) =
      __$$BarbellDetectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int frameIndex,
      double timestamp,
      double centerX,
      double centerY,
      double boxLeft,
      double boxTop,
      double boxWidth,
      double boxHeight,
      double confidence});
}

/// @nodoc
class __$$BarbellDetectionImplCopyWithImpl<$Res>
    extends _$BarbellDetectionCopyWithImpl<$Res, _$BarbellDetectionImpl>
    implements _$$BarbellDetectionImplCopyWith<$Res> {
  __$$BarbellDetectionImplCopyWithImpl(_$BarbellDetectionImpl _value,
      $Res Function(_$BarbellDetectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of BarbellDetection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frameIndex = null,
    Object? timestamp = null,
    Object? centerX = null,
    Object? centerY = null,
    Object? boxLeft = null,
    Object? boxTop = null,
    Object? boxWidth = null,
    Object? boxHeight = null,
    Object? confidence = null,
  }) {
    return _then(_$BarbellDetectionImpl(
      frameIndex: null == frameIndex
          ? _value.frameIndex
          : frameIndex // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as double,
      centerX: null == centerX
          ? _value.centerX
          : centerX // ignore: cast_nullable_to_non_nullable
              as double,
      centerY: null == centerY
          ? _value.centerY
          : centerY // ignore: cast_nullable_to_non_nullable
              as double,
      boxLeft: null == boxLeft
          ? _value.boxLeft
          : boxLeft // ignore: cast_nullable_to_non_nullable
              as double,
      boxTop: null == boxTop
          ? _value.boxTop
          : boxTop // ignore: cast_nullable_to_non_nullable
              as double,
      boxWidth: null == boxWidth
          ? _value.boxWidth
          : boxWidth // ignore: cast_nullable_to_non_nullable
              as double,
      boxHeight: null == boxHeight
          ? _value.boxHeight
          : boxHeight // ignore: cast_nullable_to_non_nullable
              as double,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BarbellDetectionImpl extends _BarbellDetection {
  const _$BarbellDetectionImpl(
      {required this.frameIndex,
      required this.timestamp,
      required this.centerX,
      required this.centerY,
      required this.boxLeft,
      required this.boxTop,
      required this.boxWidth,
      required this.boxHeight,
      required this.confidence})
      : super._();

  factory _$BarbellDetectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BarbellDetectionImplFromJson(json);

  /// 프레임 인덱스
  @override
  final int frameIndex;

  /// 타임스탬프 (초 단위)
  @override
  final double timestamp;

  /// 바벨 중심점 (normalized 0-1)
  @override
  final double centerX;
  @override
  final double centerY;

  /// 바운딩 박스 (normalized 0-1)
  @override
  final double boxLeft;
  @override
  final double boxTop;
  @override
  final double boxWidth;
  @override
  final double boxHeight;

  /// 감지 신뢰도 (0-1)
  @override
  final double confidence;

  @override
  String toString() {
    return 'BarbellDetection(frameIndex: $frameIndex, timestamp: $timestamp, centerX: $centerX, centerY: $centerY, boxLeft: $boxLeft, boxTop: $boxTop, boxWidth: $boxWidth, boxHeight: $boxHeight, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarbellDetectionImpl &&
            (identical(other.frameIndex, frameIndex) ||
                other.frameIndex == frameIndex) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.centerX, centerX) || other.centerX == centerX) &&
            (identical(other.centerY, centerY) || other.centerY == centerY) &&
            (identical(other.boxLeft, boxLeft) || other.boxLeft == boxLeft) &&
            (identical(other.boxTop, boxTop) || other.boxTop == boxTop) &&
            (identical(other.boxWidth, boxWidth) ||
                other.boxWidth == boxWidth) &&
            (identical(other.boxHeight, boxHeight) ||
                other.boxHeight == boxHeight) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, frameIndex, timestamp, centerX,
      centerY, boxLeft, boxTop, boxWidth, boxHeight, confidence);

  /// Create a copy of BarbellDetection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BarbellDetectionImplCopyWith<_$BarbellDetectionImpl> get copyWith =>
      __$$BarbellDetectionImplCopyWithImpl<_$BarbellDetectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BarbellDetectionImplToJson(
      this,
    );
  }
}

abstract class _BarbellDetection extends BarbellDetection {
  const factory _BarbellDetection(
      {required final int frameIndex,
      required final double timestamp,
      required final double centerX,
      required final double centerY,
      required final double boxLeft,
      required final double boxTop,
      required final double boxWidth,
      required final double boxHeight,
      required final double confidence}) = _$BarbellDetectionImpl;
  const _BarbellDetection._() : super._();

  factory _BarbellDetection.fromJson(Map<String, dynamic> json) =
      _$BarbellDetectionImpl.fromJson;

  /// 프레임 인덱스
  @override
  int get frameIndex;

  /// 타임스탬프 (초 단위)
  @override
  double get timestamp;

  /// 바벨 중심점 (normalized 0-1)
  @override
  double get centerX;
  @override
  double get centerY;

  /// 바운딩 박스 (normalized 0-1)
  @override
  double get boxLeft;
  @override
  double get boxTop;
  @override
  double get boxWidth;
  @override
  double get boxHeight;

  /// 감지 신뢰도 (0-1)
  @override
  double get confidence;

  /// Create a copy of BarbellDetection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BarbellDetectionImplCopyWith<_$BarbellDetectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
