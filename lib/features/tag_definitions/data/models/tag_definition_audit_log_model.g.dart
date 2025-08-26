// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_definition_audit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagDefinitionAuditLogModel _$TagDefinitionAuditLogModelFromJson(
  Map<String, dynamic> json,
) => TagDefinitionAuditLogModel(
  changeType: json['changeType'] as String,
  changeDate: json['changeDate'] as String,
  objectType: json['objectType'] as String,
  objectId: json['objectId'] as String,
  changedBy: json['changedBy'] as String,
  reasonCode: json['reasonCode'] as String?,
  comments: json['comments'] as String?,
  userToken: json['userToken'] as String,
  history: TagDefinitionHistoryModel.fromJson(
    json['history'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$TagDefinitionAuditLogModelToJson(
  TagDefinitionAuditLogModel instance,
) => <String, dynamic>{
  'changeType': instance.changeType,
  'changeDate': instance.changeDate,
  'objectType': instance.objectType,
  'objectId': instance.objectId,
  'changedBy': instance.changedBy,
  'reasonCode': instance.reasonCode,
  'comments': instance.comments,
  'userToken': instance.userToken,
  'history': instance.history,
};

TagDefinitionHistoryModel _$TagDefinitionHistoryModelFromJson(
  Map<String, dynamic> json,
) => TagDefinitionHistoryModel(
  id: json['id'] as String?,
  createdDate: json['createdDate'] as String,
  updatedDate: json['updatedDate'] as String,
  recordId: (json['recordId'] as num).toInt(),
  accountRecordId: (json['accountRecordId'] as num).toInt(),
  tenantRecordId: (json['tenantRecordId'] as num).toInt(),
  name: json['name'] as String,
  applicableObjectTypes: json['applicableObjectTypes'] as String,
  description: json['description'] as String,
  isActive: json['isActive'] as bool,
  tableName: json['tableName'] as String,
  historyTableName: json['historyTableName'] as String,
);

Map<String, dynamic> _$TagDefinitionHistoryModelToJson(
  TagDefinitionHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdDate': instance.createdDate,
  'updatedDate': instance.updatedDate,
  'recordId': instance.recordId,
  'accountRecordId': instance.accountRecordId,
  'tenantRecordId': instance.tenantRecordId,
  'name': instance.name,
  'applicableObjectTypes': instance.applicableObjectTypes,
  'description': instance.description,
  'isActive': instance.isActive,
  'tableName': instance.tableName,
  'historyTableName': instance.historyTableName,
};
