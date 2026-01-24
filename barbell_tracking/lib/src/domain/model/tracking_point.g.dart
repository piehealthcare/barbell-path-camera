// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackingPointImpl _$$TrackingPointImplFromJson(Map<String, dynamic> json) =>
    _$TrackingPointImpl(
      timestamp: (json['timestamp'] as num).toDouble(),
      positionX: (json['positionX'] as num).toDouble(),
      positionY: (json['positionY'] as num).toDouble(),
      velocityY: (json['velocityY'] as num).toDouble(),
      accelerationY: (json['accelerationY'] as num).toDouble(),
      power: (json['power'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$TrackingPointImplToJson(_$TrackingPointImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'positionX': instance.positionX,
      'positionY': instance.positionY,
      'velocityY': instance.velocityY,
      'accelerationY': instance.accelerationY,
      'power': instance.power,
      'confidence': instance.confidence,
    };
