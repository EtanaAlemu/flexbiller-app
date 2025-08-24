// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountTagModel _$AccountTagModelFromJson(Map<String, dynamic> json) =>
    AccountTagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$AccountTagModelToJson(AccountTagModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'color': instance.color,
      'icon': instance.icon,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'isActive': instance.isActive,
    };

AccountTagAssignmentModel _$AccountTagAssignmentModelFromJson(
  Map<String, dynamic> json,
) => AccountTagAssignmentModel(
  tagId: json['tagId'] as String,
  objectType: json['objectType'] as String,
  objectId: json['objectId'] as String,
  tagDefinitionId: json['tagDefinitionId'] as String,
  tagDefinitionName: json['tagDefinitionName'] as String,
  auditLogs: json['auditLogs'] as List<dynamic>,
);

Map<String, dynamic> _$AccountTagAssignmentModelToJson(
  AccountTagAssignmentModel instance,
) => <String, dynamic>{
  'tagId': instance.tagId,
  'objectType': instance.objectType,
  'objectId': instance.objectId,
  'tagDefinitionId': instance.tagDefinitionId,
  'tagDefinitionName': instance.tagDefinitionName,
  'auditLogs': instance.auditLogs,
};

AccountTagWithDefinitionModel _$AccountTagWithDefinitionModelFromJson(
  Map<String, dynamic> json,
) => AccountTagWithDefinitionModel(
  tagId: json['tagId'] as String,
  objectType: json['objectType'] as String,
  objectId: json['objectId'] as String,
  tagDefinitionId: json['tagDefinitionId'] as String,
  tagDefinitionName: json['tagDefinitionName'] as String,
  auditLogs: json['auditLogs'] as List<dynamic>,
  tagDefinition: TagDefinitionModel.fromJson(
    json['tagDefinition'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AccountTagWithDefinitionModelToJson(
  AccountTagWithDefinitionModel instance,
) => <String, dynamic>{
  'tagId': instance.tagId,
  'objectType': instance.objectType,
  'objectId': instance.objectId,
  'tagDefinitionId': instance.tagDefinitionId,
  'tagDefinitionName': instance.tagDefinitionName,
  'auditLogs': instance.auditLogs,
  'tagDefinition': instance.tagDefinition,
};

TagDefinitionModel _$TagDefinitionModelFromJson(Map<String, dynamic> json) =>
    TagDefinitionModel(
      id: json['id'] as String,
      isControlTag: json['isControlTag'] as bool,
      name: json['name'] as String,
      description: json['description'] as String,
      applicableObjectTypes: (json['applicableObjectTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      auditLogs: json['auditLogs'] as List<dynamic>,
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
