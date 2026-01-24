// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackingSessionImpl _$$TrackingSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$TrackingSessionImpl(
      id: json['id'] as String,
      status:
          $enumDecodeNullable(_$TrackingSessionStatusEnumMap, json['status']) ??
              TrackingSessionStatus.idle,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      weight: (json['weight'] as num?)?.toDouble() ?? 20.0,
      exerciseName: json['exerciseName'] as String?,
      completedPaths: (json['completedPaths'] as List<dynamic>?)
              ?.map((e) => BarbellPath.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentPath: json['currentPath'] == null
          ? null
          : BarbellPath.fromJson(json['currentPath'] as Map<String, dynamic>),
      repMetrics: (json['repMetrics'] as List<dynamic>?)
              ?.map((e) => RepMetrics.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentPoint: json['currentPoint'] == null
          ? null
          : TrackingPoint.fromJson(
              json['currentPoint'] as Map<String, dynamic>),
      pixelsPerMeter: (json['pixelsPerMeter'] as num?)?.toDouble(),
      frameIndex: (json['frameIndex'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$TrackingSessionImplToJson(
        _$TrackingSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$TrackingSessionStatusEnumMap[instance.status]!,
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'weight': instance.weight,
      'exerciseName': instance.exerciseName,
      'completedPaths': instance.completedPaths,
      'currentPath': instance.currentPath,
      'repMetrics': instance.repMetrics,
      'currentPoint': instance.currentPoint,
      'pixelsPerMeter': instance.pixelsPerMeter,
      'frameIndex': instance.frameIndex,
      'errorMessage': instance.errorMessage,
    };

const _$TrackingSessionStatusEnumMap = {
  TrackingSessionStatus.idle: 'idle',
  TrackingSessionStatus.calibrating: 'calibrating',
  TrackingSessionStatus.ready: 'ready',
  TrackingSessionStatus.tracking: 'tracking',
  TrackingSessionStatus.paused: 'paused',
  TrackingSessionStatus.completed: 'completed',
  TrackingSessionStatus.error: 'error',
};
