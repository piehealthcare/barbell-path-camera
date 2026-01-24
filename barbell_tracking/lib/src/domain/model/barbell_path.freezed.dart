// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'barbell_path.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BarbellPath _$BarbellPathFromJson(Map<String, dynamic> json) {
  return _BarbellPath.fromJson(json);
}

/// @nodoc
mixin _$BarbellPath {
  /// 추적 포인트 리스트
  List<TrackingPoint> get points => throw _privateConstructorUsedError;

  /// Rep 시작 시간
  double get startTime => throw _privateConstructorUsedError;

  /// Rep 종료 시간
  double? get endTime => throw _privateConstructorUsedError;

  /// 운동 방향 (true: 상승, false: 하강)
  bool get isAscending => throw _privateConstructorUsedError;

  /// Serializes this BarbellPath to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BarbellPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BarbellPathCopyWith<BarbellPath> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BarbellPathCopyWith<$Res> {
  factory $BarbellPathCopyWith(
          BarbellPath value, $Res Function(BarbellPath) then) =
      _$BarbellPathCopyWithImpl<$Res, BarbellPath>;
  @useResult
  $Res call(
      {List<TrackingPoint> points,
      double startTime,
      double? endTime,
      bool isAscending});
}

/// @nodoc
class _$BarbellPathCopyWithImpl<$Res, $Val extends BarbellPath>
    implements $BarbellPathCopyWith<$Res> {
  _$BarbellPathCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BarbellPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? points = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? isAscending = null,
  }) {
    return _then(_value.copyWith(
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as List<TrackingPoint>,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as double,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as double?,
      isAscending: null == isAscending
          ? _value.isAscending
          : isAscending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BarbellPathImplCopyWith<$Res>
    implements $BarbellPathCopyWith<$Res> {
  factory _$$BarbellPathImplCopyWith(
          _$BarbellPathImpl value, $Res Function(_$BarbellPathImpl) then) =
      __$$BarbellPathImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<TrackingPoint> points,
      double startTime,
      double? endTime,
      bool isAscending});
}

/// @nodoc
class __$$BarbellPathImplCopyWithImpl<$Res>
    extends _$BarbellPathCopyWithImpl<$Res, _$BarbellPathImpl>
    implements _$$BarbellPathImplCopyWith<$Res> {
  __$$BarbellPathImplCopyWithImpl(
      _$BarbellPathImpl _value, $Res Function(_$BarbellPathImpl) _then)
      : super(_value, _then);

  /// Create a copy of BarbellPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? points = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? isAscending = null,
  }) {
    return _then(_$BarbellPathImpl(
      points: null == points
          ? _value._points
          : points // ignore: cast_nullable_to_non_nullable
              as List<TrackingPoint>,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as double,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as double?,
      isAscending: null == isAscending
          ? _value.isAscending
          : isAscending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BarbellPathImpl extends _BarbellPath {
  const _$BarbellPathImpl(
      {required final List<TrackingPoint> points,
      required this.startTime,
      this.endTime,
      this.isAscending = true})
      : _points = points,
        super._();

  factory _$BarbellPathImpl.fromJson(Map<String, dynamic> json) =>
      _$$BarbellPathImplFromJson(json);

  /// 추적 포인트 리스트
  final List<TrackingPoint> _points;

  /// 추적 포인트 리스트
  @override
  List<TrackingPoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  /// Rep 시작 시간
  @override
  final double startTime;

  /// Rep 종료 시간
  @override
  final double? endTime;

  /// 운동 방향 (true: 상승, false: 하강)
  @override
  @JsonKey()
  final bool isAscending;

  @override
  String toString() {
    return 'BarbellPath(points: $points, startTime: $startTime, endTime: $endTime, isAscending: $isAscending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarbellPathImpl &&
            const DeepCollectionEquality().equals(other._points, _points) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isAscending, isAscending) ||
                other.isAscending == isAscending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_points),
      startTime,
      endTime,
      isAscending);

  /// Create a copy of BarbellPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BarbellPathImplCopyWith<_$BarbellPathImpl> get copyWith =>
      __$$BarbellPathImplCopyWithImpl<_$BarbellPathImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BarbellPathImplToJson(
      this,
    );
  }
}

abstract class _BarbellPath extends BarbellPath {
  const factory _BarbellPath(
      {required final List<TrackingPoint> points,
      required final double startTime,
      final double? endTime,
      final bool isAscending}) = _$BarbellPathImpl;
  const _BarbellPath._() : super._();

  factory _BarbellPath.fromJson(Map<String, dynamic> json) =
      _$BarbellPathImpl.fromJson;

  /// 추적 포인트 리스트
  @override
  List<TrackingPoint> get points;

  /// Rep 시작 시간
  @override
  double get startTime;

  /// Rep 종료 시간
  @override
  double? get endTime;

  /// 운동 방향 (true: 상승, false: 하강)
  @override
  bool get isAscending;

  /// Create a copy of BarbellPath
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BarbellPathImplCopyWith<_$BarbellPathImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
