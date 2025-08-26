// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_tag_definition_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTagDefinitionRequestModel _$CreateTagDefinitionRequestModelFromJson(
  Map<String, dynamic> json,
) => CreateTagDefinitionRequestModel(
  name: json['name'] as String,
  description: json['description'] as String,
  isControlTag: json['isControlTag'] as bool,
  applicableObjectTypes: (json['applicableObjectTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CreateTagDefinitionRequestModelToJson(
  CreateTagDefinitionRequestModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'isControlTag': instance.isControlTag,
  'applicableObjectTypes': instance.applicableObjectTypes,
};
