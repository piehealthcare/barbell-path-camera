// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrackingSession _$TrackingSessionFromJson(Map<String, dynamic> json) {
  return _TrackingSession.fromJson(json);
}

/// @nodoc
mixin _$TrackingSession {
  /// 세션 고유 ID
  String get id => throw _privateConstructorUsedError;

  /// 세션 상태
  TrackingSessionStatus get status => throw _privateConstructorUsedError;

  /// 세션 시작 시간
  DateTime? get startedAt => throw _privateConstructorUsedError;

  /// 세션 종료 시간
  DateTime? get endedAt => throw _privateConstructorUsedError;

  /// 운동 무게 (kg)
  double get weight => throw _privateConstructorUsedError;

  /// 운동 이름
  String? get exerciseName => throw _privateConstructorUsedError;

  /// 완료된 Rep 경로들
  List<BarbellPath> get completedPaths => throw _privateConstructorUsedError;

  /// 현재 진행 중인 경로
  BarbellPath? get currentPath => throw _privateConstructorUsedError;

  /// Rep별 지표 목록
  List<RepMetrics> get repMetrics => throw _privateConstructorUsedError;

  /// 현재 추적 포인트 (실시간 표시용)
  TrackingPoint? get currentPoint => throw _privateConstructorUsedError;

  /// 캘리브레이션: 픽셀당 미터 비율
  double? get pixelsPerMeter => throw _privateConstructorUsedError;

  /// 프레임 인덱스
  int get frameIndex => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this TrackingSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrackingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackingSessionCopyWith<TrackingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackingSessionCopyWith<$Res> {
  factory $TrackingSessionCopyWith(
          TrackingSession value, $Res Function(TrackingSession) then) =
      _$TrackingSessionCopyWithImpl<$Res, TrackingSession>;
  @useResult
  $Res call(
      {String id,
      TrackingSessionStatus status,
      DateTime? startedAt,
      DateTime? endedAt,
      double weight,
      String? exerciseName,
      List<BarbellPath> completedPaths,
      BarbellPath? currentPath,
      List<RepMetrics> repMetrics,
      TrackingPoint? currentPoint,
      double? pixelsPerMeter,
      int frameIndex,
      String? errorMessage});

  $BarbellPathCopyWith<$Res>? get currentPath;
  $TrackingPointCopyWith<$Res>? get currentPoint;
}

/// @nodoc
class _$TrackingSessionCopyWithImpl<$Res, $Val extends TrackingSession>
    implements $TrackingSessionCopyWith<$Res> {
  _$TrackingSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? weight = null,
    Object? exerciseName = freezed,
    Object? completedPaths = null,
    Object? currentPath = freezed,
    Object? repMetrics = null,
    Object? currentPoint = freezed,
    Object? pixelsPerMeter = freezed,
    Object? frameIndex = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TrackingSessionStatus,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      exerciseName: freezed == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String?,
      completedPaths: null == completedPaths
          ? _value.completedPaths
          : completedPaths // ignore: cast_nullable_to_non_nullable
              as List<BarbellPath>,
      currentPath: freezed == currentPath
          ? _value.currentPath
          : currentPath // ignore: cast_nullable_to_non_nullable
              as BarbellPath?,
      repMetrics: null == repMetrics
          ? _value.repMetrics
          : repMetrics // ignore: cast_nullable_to_non_nullable
              as List<RepMetrics>,
      currentPoint: freezed == currentPoint
          ? _value.currentPoint
          : currentPoint // ignore: cast_nullable_to_non_nullable
              as TrackingPoint?,
      pixelsPerMeter: freezed == pixelsPerMeter
          ? _value.pixelsPerMeter
          : pixelsPerMeter // ignore: cast_nullable_to_non_nullable
              as double?,
      frameIndex: null == frameIndex
          ? _value.frameIndex
          : frameIndex // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of TrackingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BarbellPathCopyWith<$Res>? get currentPath {
    if (_value.currentPath == null) {
      return null;
    }

    return $BarbellPathCopyWith<$Res>(_value.currentPath!, (value) {
      return _then(_value.copyWith(currentPath: value) as $Val);
    });
  }

  /// Create a copy of TrackingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackingPointCopyWith<$Res>? get currentPoint {
    if (_value.currentPoint == null) {
      return null;
    }

    return $TrackingPointCopyWith<$Res>(_value.currentPoint!, (value) {
      return _then(_value.copyWith(currentPoint: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrackingSessionImplCopyWith<$Res>
    implements $TrackingSessionCopyWith<$Res> {
  factory _$$TrackingSessionImplCopyWith(_$TrackingSessionImpl value,
          $Res Function(_$TrackingSessionImpl) then) =
      __$$TrackingSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TrackingSessionStatus status,
      DateTime? startedAt,
      DateTime? endedAt,
      double weight,
      String? exerciseName,
      List<BarbellPath> completedPaths,
      BarbellPath? currentPath,
      List<RepMetrics> repMetrics,
      TrackingPoint? currentPoint,
      double? pixelsPerMeter,
      int frameIndex,
      String? errorMessage});

  @override
  $BarbellPathCopyWith<$Res>? get currentPath;
  @override
  $TrackingPointCopyWith<$Res>? get currentPoint;
}

/// @nodoc
class __$$TrackingSessionImplCopyWithImpl<$Res>
    extends _$TrackingSessionCopyWithImpl<$Res, _$TrackingSessionImpl>
    implements _$$TrackingSessionImplCopyWith<$Res> {
  __$$TrackingSessionImplCopyWithImpl(
      _$TrackingSessionImpl _value, $Res Function(_$TrackingSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? weight = null,
    Object? exerciseName = freezed,
    Object? completedPaths = null,
    Object? currentPath = freezed,
    Object? repMetrics = null,
    Object? currentPoint = freezed,
    Object? pixelsPerMeter = freezed,
    Object? frameIndex = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$TrackingSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TrackingSessionStatus,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      exerciseName: freezed == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String?,
      completedPaths: null == completedPaths
          ? _value._completedPaths
          : completedPaths // ignore: cast_nullable_to_non_nullable
              as List<BarbellPath>,
      currentPath: freezed == currentPath
          ? _value.currentPath
          : currentPath // ignore: cast_nullable_to_non_nullable
              as BarbellPath?,
      repMetrics: null == repMetrics
          ? _value._repMetrics
          : repMetrics // ignore: cast_nullable_to_non_nullable
              as List<RepMetrics>,
      currentPoint: freezed == currentPoint
          ? _value.currentPoint
          : currentPoint // ignore: cast_nullable_to_non_nullable
              as TrackingPoint?,
      pixelsPerMeter: freezed == pixelsPerMeter
          ? _value.pixelsPerMeter
          : pixelsPerMeter // ignore: cast_nullable_to_non_nullable
              as double?,
      frameIndex: null == frameIndex
          ? _value.frameIndex
          : frameIndex // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrackingSessionImpl extends _TrackingSession {
  const _$TrackingSessionImpl(
      {required this.id,
      this.status = TrackingSessionStatus.idle,
      this.startedAt,
      this.endedAt,
      this.weight = 20.0,
      this.exerciseName,
      final List<BarbellPath> completedPaths = const [],
      this.currentPath,
      final List<RepMetrics> repMetrics = const [],
      this.currentPoint,
      this.pixelsPerMeter,
      this.frameIndex = 0,
      this.errorMessage})
      : _completedPaths = completedPaths,
        _repMetrics = repMetrics,
        super._();

  factory _$TrackingSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrackingSessionImplFromJson(json);

  /// 세션 고유 ID
  @override
  final String id;

  /// 세션 상태
  @override
  @JsonKey()
  final TrackingSessionStatus status;

  /// 세션 시작 시간
  @override
  final DateTime? startedAt;

  /// 세션 종료 시간
  @override
  final DateTime? endedAt;

  /// 운동 무게 (kg)
  @override
  @JsonKey()
  final double weight;

  /// 운동 이름
  @override
  final String? exerciseName;

  /// 완료된 Rep 경로들
  final List<BarbellPath> _completedPaths;

  /// 완료된 Rep 경로들
  @override
  @JsonKey()
  List<BarbellPath> get completedPaths {
    if (_completedPaths is EqualUnmodifiableListView) return _completedPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedPaths);
  }

  /// 현재 진행 중인 경로
  @override
  final BarbellPath? currentPath;

  /// Rep별 지표 목록
  final List<RepMetrics> _repMetrics;

  /// Rep별 지표 목록
  @override
  @JsonKey()
  List<RepMetrics> get repMetrics {
    if (_repMetrics is EqualUnmodifiableListView) return _repMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repMetrics);
  }

  /// 현재 추적 포인트 (실시간 표시용)
  @override
  final TrackingPoint? currentPoint;

  /// 캘리브레이션: 픽셀당 미터 비율
  @override
  final double? pixelsPerMeter;

  /// 프레임 인덱스
  @override
  @JsonKey()
  final int frameIndex;

  /// 에러 메시지
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'TrackingSession(id: $id, status: $status, startedAt: $startedAt, endedAt: $endedAt, weight: $weight, exerciseName: $exerciseName, completedPaths: $completedPaths, currentPath: $currentPath, repMetrics: $repMetrics, currentPoint: $currentPoint, pixelsPerMeter: $pixelsPerMeter, frameIndex: $frameIndex, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackingSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            const DeepCollectionEquality()
                .equals(other._completedPaths, _completedPaths) &&
            (identical(other.currentPath, currentPath) ||
                other.currentPath == currentPath) &&
            const DeepCollectionEquality()
                .equals(other._repMetrics, _repMetrics) &&
            (identical(other.currentPoint, currentPoint) ||
                other.currentPoint == currentPoint) &&
            (identical(other.pixelsPerMeter, pixelsPerMeter) ||
                other.pixelsPerMeter == pixelsPerMeter) &&
            (identical(other.frameIndex, frameIndex) ||
                other.frameIndex == frameIndex) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      status,
      startedAt,
      endedAt,
      weight,
      exerciseName,
      const DeepCollectionEquality().hash(_completedPaths),
      currentPath,
      const DeepCollectionEquality().hash(_repMetrics),
      currentPoint,
      pixelsPerMeter,
      frameIndex,
      errorMessage);

  /// Create a copy of TrackingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackingSessionImplCopyWith<_$TrackingSessionImpl> get copyWith =>
      __$$TrackingSessionImplCopyWithImpl<_$TrackingSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrackingSessionImplToJson(
      this,
    );
  }
}

abstract class _TrackingSession extends TrackingSession {
  const factory _TrackingSession(
      {required final String id,
      final TrackingSessionStatus status,
      final DateTime? startedAt,
      final DateTime? endedAt,
      final double weight,
      final String? exerciseName,
      final List<BarbellPath> completedPaths,
      final BarbellPath? currentPath,
      final List<RepMetrics> repMetrics,
      final TrackingPoint? currentPoint,
      final double? pixelsPerMeter,
      final int frameIndex,
      final String? errorMessage}) = _$TrackingSessionImpl;
  const _TrackingSession._() : super._();

  factory _TrackingSession.fromJson(Map<String, dynamic> json) =
      _$TrackingSessionImpl.fromJson;

  /// 세션 고유 ID
  @override
  String get id;

  /// 세션 상태
  @override
  TrackingSessionStatus get status;

  /// 세션 시작 시간
  @override
  DateTime? get startedAt;

  /// 세션 종료 시간
  @override
  DateTime? get endedAt;

  /// 운동 무게 (kg)
  @override
  double get weight;

  /// 운동 이름
  @override
  String? get exerciseName;

  /// 완료된 Rep 경로들
  @override
  List<BarbellPath> get completedPaths;

  /// 현재 진행 중인 경로
  @override
  BarbellPath? get currentPath;

  /// Rep별 지표 목록
  @override
  List<RepMetrics> get repMetrics;

  /// 현재 추적 포인트 (실시간 표시용)
  @override
  TrackingPoint? get currentPoint;

  /// 캘리브레이션: 픽셀당 미터 비율
  @override
  double? get pixelsPerMeter;

  /// 프레임 인덱스
  @override
  int get frameIndex;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// Create a copy of TrackingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackingSessionImplCopyWith<_$TrackingSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
