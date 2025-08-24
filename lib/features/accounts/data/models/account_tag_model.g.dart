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
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  tagId: json['tagId'] as String,
  tagName: json['tagName'] as String,
  tagColor: json['tagColor'] as String?,
  tagIcon: json['tagIcon'] as String?,
  assignedAt: DateTime.parse(json['assignedAt'] as String),
  assignedBy: json['assignedBy'] as String,
);

Map<String, dynamic> _$AccountTagAssignmentModelToJson(
  AccountTagAssignmentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'tagId': instance.tagId,
  'tagName': instance.tagName,
  'tagColor': instance.tagColor,
  'tagIcon': instance.tagIcon,
  'assignedAt': instance.assignedAt.toIso8601String(),
  'assignedBy': instance.assignedBy,
};
