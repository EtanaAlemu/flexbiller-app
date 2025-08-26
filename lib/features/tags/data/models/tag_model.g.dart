// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagModel _$TagModelFromJson(Map<String, dynamic> json) => TagModel(
  tagId: json['tagId'] as String,
  objectType: json['objectType'] as String,
  objectId: json['objectId'] as String,
  tagDefinitionId: json['tagDefinitionId'] as String,
  tagDefinitionName: json['tagDefinitionName'] as String,
  auditLogs: (json['auditLogs'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$TagModelToJson(TagModel instance) => <String, dynamic>{
  'tagId': instance.tagId,
  'objectType': instance.objectType,
  'objectId': instance.objectId,
  'tagDefinitionId': instance.tagDefinitionId,
  'tagDefinitionName': instance.tagDefinitionName,
  'auditLogs': instance.auditLogs,
};
