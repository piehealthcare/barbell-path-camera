// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rep_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RepMetricsImpl _$$RepMetricsImplFromJson(Map<String, dynamic> json) =>
    _$RepMetricsImpl(
      repNumber: (json['repNumber'] as num).toInt(),
      meanVelocity: (json['meanVelocity'] as num).toDouble(),
      peakVelocity: (json['peakVelocity'] as num).toDouble(),
      rangeOfMotion: (json['rangeOfMotion'] as num).toDouble(),
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
      velocityLoss: (json['velocityLoss'] as num?)?.toDouble(),
      meanPower: (json['meanPower'] as num?)?.toDouble(),
      peakPower: (json['peakPower'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$RepMetricsImplToJson(_$RepMetricsImpl instance) =>
    <String, dynamic>{
      'repNumber': instance.repNumber,
      'meanVelocity': instance.meanVelocity,
      'peakVelocity': instance.peakVelocity,
      'rangeOfMotion': instance.rangeOfMotion,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'velocityLoss': instance.velocityLoss,
      'meanPower': instance.meanPower,
      'peakPower': instance.peakPower,
    };
