// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calibration_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalibrationData _$CalibrationDataFromJson(Map<String, dynamic> json) {
  return _CalibrationData.fromJson(json);
}

/// @nodoc
mixin _$CalibrationData {
  /// 참조 길이 (미터) - 예: 바벨 길이 또는 플레이트 직경
  double get referenceLength => throw _privateConstructorUsedError;

  /// 참조 길이의 픽셀 수
  double get referenceLengthPixels => throw _privateConstructorUsedError;

  /// 카메라와 바벨 사이 거리 (미터) - 옵션
  double? get cameraDistance => throw _privateConstructorUsedError;

  /// 카메라 해상도 너비
  int get imageWidth => throw _privateConstructorUsedError;

  /// 카메라 해상도 높이
  int get imageHeight => throw _privateConstructorUsedError;

  /// Serializes this CalibrationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalibrationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalibrationDataCopyWith<CalibrationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalibrationDataCopyWith<$Res> {
  factory $CalibrationDataCopyWith(
          CalibrationData value, $Res Function(CalibrationData) then) =
      _$CalibrationDataCopyWithImpl<$Res, CalibrationData>;
  @useResult
  $Res call(
      {double referenceLength,
      double referenceLengthPixels,
      double? cameraDistance,
      int imageWidth,
      int imageHeight});
}

/// @nodoc
class _$CalibrationDataCopyWithImpl<$Res, $Val extends CalibrationData>
    implements $CalibrationDataCopyWith<$Res> {
  _$CalibrationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalibrationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? referenceLength = null,
    Object? referenceLengthPixels = null,
    Object? cameraDistance = freezed,
    Object? imageWidth = null,
    Object? imageHeight = null,
  }) {
    return _then(_value.copyWith(
      referenceLength: null == referenceLength
          ? _value.referenceLength
          : referenceLength // ignore: cast_nullable_to_non_nullable
              as double,
      referenceLengthPixels: null == referenceLengthPixels
          ? _value.referenceLengthPixels
          : referenceLengthPixels // ignore: cast_nullable_to_non_nullable
              as double,
      cameraDistance: freezed == cameraDistance
          ? _value.cameraDistance
          : cameraDistance // ignore: cast_nullable_to_non_nullable
              as double?,
      imageWidth: null == imageWidth
          ? _value.imageWidth
          : imageWidth // ignore: cast_nullable_to_non_nullable
              as int,
      imageHeight: null == imageHeight
          ? _value.imageHeight
          : imageHeight // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalibrationDataImplCopyWith<$Res>
    implements $CalibrationDataCopyWith<$Res> {
  factory _$$CalibrationDataImplCopyWith(_$CalibrationDataImpl value,
          $Res Function(_$CalibrationDataImpl) then) =
      __$$CalibrationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double referenceLength,
      double referenceLengthPixels,
      double? cameraDistance,
      int imageWidth,
      int imageHeight});
}

/// @nodoc
class __$$CalibrationDataImplCopyWithImpl<$Res>
    extends _$CalibrationDataCopyWithImpl<$Res, _$CalibrationDataImpl>
    implements _$$CalibrationDataImplCopyWith<$Res> {
  __$$CalibrationDataImplCopyWithImpl(
      _$CalibrationDataImpl _value, $Res Function(_$CalibrationDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalibrationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? referenceLength = null,
    Object? referenceLengthPixels = null,
    Object? cameraDistance = freezed,
    Object? imageWidth = null,
    Object? imageHeight = null,
  }) {
    return _then(_$CalibrationDataImpl(
      referenceLength: null == referenceLength
          ? _value.referenceLength
          : referenceLength // ignore: cast_nullable_to_non_nullable
              as double,
      referenceLengthPixels: null == referenceLengthPixels
          ? _value.referenceLengthPixels
          : referenceLengthPixels // ignore: cast_nullable_to_non_nullable
              as double,
      cameraDistance: freezed == cameraDistance
          ? _value.cameraDistance
          : cameraDistance // ignore: cast_nullable_to_non_nullable
              as double?,
      imageWidth: null == imageWidth
          ? _value.imageWidth
          : imageWidth // ignore: cast_nullable_to_non_nullable
              as int,
      imageHeight: null == imageHeight
          ? _value.imageHeight
          : imageHeight // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalibrationDataImpl extends _CalibrationData {
  const _$CalibrationDataImpl(
      {required this.referenceLength,
      required this.referenceLengthPixels,
      this.cameraDistance,
      required this.imageWidth,
      required this.imageHeight})
      : super._();

  factory _$CalibrationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalibrationDataImplFromJson(json);

  /// 참조 길이 (미터) - 예: 바벨 길이 또는 플레이트 직경
  @override
  final double referenceLength;

  /// 참조 길이의 픽셀 수
  @override
  final double referenceLengthPixels;

  /// 카메라와 바벨 사이 거리 (미터) - 옵션
  @override
  final double? cameraDistance;

  /// 카메라 해상도 너비
  @override
  final int imageWidth;

  /// 카메라 해상도 높이
  @override
  final int imageHeight;

  @override
  String toString() {
    return 'CalibrationData(referenceLength: $referenceLength, referenceLengthPixels: $referenceLengthPixels, cameraDistance: $cameraDistance, imageWidth: $imageWidth, imageHeight: $imageHeight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalibrationDataImpl &&
            (identical(other.referenceLength, referenceLength) ||
                other.referenceLength == referenceLength) &&
            (identical(other.referenceLengthPixels, referenceLengthPixels) ||
                other.referenceLengthPixels == referenceLengthPixels) &&
            (identical(other.cameraDistance, cameraDistance) ||
                other.cameraDistance == cameraDistance) &&
            (identical(other.imageWidth, imageWidth) ||
                other.imageWidth == imageWidth) &&
            (identical(other.imageHeight, imageHeight) ||
                other.imageHeight == imageHeight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, referenceLength,
      referenceLengthPixels, cameraDistance, imageWidth, imageHeight);

  /// Create a copy of CalibrationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalibrationDataImplCopyWith<_$CalibrationDataImpl> get copyWith =>
      __$$CalibrationDataImplCopyWithImpl<_$CalibrationDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalibrationDataImplToJson(
      this,
    );
  }
}

abstract class _CalibrationData extends CalibrationData {
  const factory _CalibrationData(
      {required final double referenceLength,
      required final double referenceLengthPixels,
      final double? cameraDistance,
      required final int imageWidth,
      required final int imageHeight}) = _$CalibrationDataImpl;
  const _CalibrationData._() : super._();

  factory _CalibrationData.fromJson(Map<String, dynamic> json) =
      _$CalibrationDataImpl.fromJson;

  /// 참조 길이 (미터) - 예: 바벨 길이 또는 플레이트 직경
  @override
  double get referenceLength;

  /// 참조 길이의 픽셀 수
  @override
  double get referenceLengthPixels;

  /// 카메라와 바벨 사이 거리 (미터) - 옵션
  @override
  double? get cameraDistance;

  /// 카메라 해상도 너비
  @override
  int get imageWidth;

  /// 카메라 해상도 높이
  @override
  int get imageHeight;

  /// Create a copy of CalibrationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalibrationDataImplCopyWith<_$CalibrationDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
