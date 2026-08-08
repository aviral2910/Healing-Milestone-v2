// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicalEntity _$MedicalEntityFromJson(Map<String, dynamic> json) =>
    _MedicalEntity(
      entityId: json['entityId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$MedicalEntityToJson(_MedicalEntity instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'name': instance.name,
      'type': instance.type,
    };
