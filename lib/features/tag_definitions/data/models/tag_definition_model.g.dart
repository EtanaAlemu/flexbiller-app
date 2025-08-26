// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_definition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagDefinitionModel _$TagDefinitionModelFromJson(Map<String, dynamic> json) =>
    TagDefinitionModel(
      id: json['id'] as String,
      isControlTag: json['isControlTag'] as bool,
      name: json['name'] as String,
      description: json['description'] as String,
      applicableObjectTypes: (json['applicableObjectTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      auditLogs: (json['auditLogs'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$TagDefinitionModelToJson(TagDefinitionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isControlTag': instance.isControlTag,
      'name': instance.name,
      'description': instance.description,
      'applicableObjectTypes': instance.applicableObjectTypes,
      'auditLogs': instance.auditLogs,
    };
