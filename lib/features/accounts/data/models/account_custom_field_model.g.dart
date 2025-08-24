// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_custom_field_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountCustomFieldModel _$AccountCustomFieldModelFromJson(
  Map<String, dynamic> json,
) => AccountCustomFieldModel(
  customFieldId: json['customFieldId'] as String,
  name: json['name'] as String,
  value: json['value'] as String,
  auditLogs: (json['auditLogs'] as List<dynamic>)
      .map((e) => CustomFieldAuditLogModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AccountCustomFieldModelToJson(
  AccountCustomFieldModel instance,
) => <String, dynamic>{
  'customFieldId': instance.customFieldId,
  'name': instance.name,
  'value': instance.value,
  'auditLogs': instance.auditLogs,
};

CustomFieldAuditLogModel _$CustomFieldAuditLogModelFromJson(
  Map<String, dynamic> json,
) => CustomFieldAuditLogModel(
  changeType: json['changeType'] as String,
  changeDate: DateTime.parse(json['changeDate'] as String),
  changedBy: json['changedBy'] as String,
  reasonCode: json['reasonCode'] as String?,
  comments: json['comments'] as String?,
  objectType: json['objectType'] as String?,
  objectId: json['objectId'] as String?,
  userToken: json['userToken'] as String?,
);

Map<String, dynamic> _$CustomFieldAuditLogModelToJson(
  CustomFieldAuditLogModel instance,
) => <String, dynamic>{
  'changeType': instance.changeType,
  'changeDate': instance.changeDate.toIso8601String(),
  'changedBy': instance.changedBy,
  'reasonCode': instance.reasonCode,
  'comments': instance.comments,
  'objectType': instance.objectType,
  'objectId': instance.objectId,
  'userToken': instance.userToken,
};
