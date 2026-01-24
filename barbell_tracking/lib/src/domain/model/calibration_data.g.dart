// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calibration_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalibrationDataImpl _$$CalibrationDataImplFromJson(
        Map<String, dynamic> json) =>
    _$CalibrationDataImpl(
      referenceLength: (json['referenceLength'] as num).toDouble(),
      referenceLengthPixels: (json['referenceLengthPixels'] as num).toDouble(),
      cameraDistance: (json['cameraDistance'] as num?)?.toDouble(),
      imageWidth: (json['imageWidth'] as num).toInt(),
      imageHeight: (json['imageHeight'] as num).toInt(),
    );

Map<String, dynamic> _$$CalibrationDataImplToJson(
        _$CalibrationDataImpl instance) =>
    <String, dynamic>{
      'referenceLength': instance.referenceLength,
      'referenceLengthPixels': instance.referenceLengthPixels,
      'cameraDistance': instance.cameraDistance,
      'imageWidth': instance.imageWidth,
      'imageHeight': instance.imageHeight,
    };
