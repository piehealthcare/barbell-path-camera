// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barbell_path.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BarbellPathImpl _$$BarbellPathImplFromJson(Map<String, dynamic> json) =>
    _$BarbellPathImpl(
      points: (json['points'] as List<dynamic>)
          .map((e) => TrackingPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num?)?.toDouble(),
      isAscending: json['isAscending'] as bool? ?? true,
    );

Map<String, dynamic> _$$BarbellPathImplToJson(_$BarbellPathImpl instance) =>
    <String, dynamic>{
      'points': instance.points,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isAscending': instance.isAscending,
    };
