// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barbell_detection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BarbellDetectionImpl _$$BarbellDetectionImplFromJson(
        Map<String, dynamic> json) =>
    _$BarbellDetectionImpl(
      frameIndex: (json['frameIndex'] as num).toInt(),
      timestamp: (json['timestamp'] as num).toDouble(),
      centerX: (json['centerX'] as num).toDouble(),
      centerY: (json['centerY'] as num).toDouble(),
      boxLeft: (json['boxLeft'] as num).toDouble(),
      boxTop: (json['boxTop'] as num).toDouble(),
      boxWidth: (json['boxWidth'] as num).toDouble(),
      boxHeight: (json['boxHeight'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$$BarbellDetectionImplToJson(
        _$BarbellDetectionImpl instance) =>
    <String, dynamic>{
      'frameIndex': instance.frameIndex,
      'timestamp': instance.timestamp,
      'centerX': instance.centerX,
      'centerY': instance.centerY,
      'boxLeft': instance.boxLeft,
      'boxTop': instance.boxTop,
      'boxWidth': instance.boxWidth,
      'boxHeight': instance.boxHeight,
      'confidence': instance.confidence,
    };
