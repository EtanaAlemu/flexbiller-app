// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_audit_logs_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionAuditLogsResponseModel _$SubscriptionAuditLogsResponseModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionAuditLogsResponseModel(
  success: json['success'] as bool,
  code: (json['code'] as num).toInt(),
  data: (json['data'] as List<dynamic>)
      .map((e) => SubscriptionAuditLogModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String,
);

Map<String, dynamic> _$SubscriptionAuditLogsResponseModelToJson(
  SubscriptionAuditLogsResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'code': instance.code,
  'data': instance.data,
  'message': instance.message,
};

SubscriptionAuditLogModel _$SubscriptionAuditLogModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionAuditLogModel(
  changeType: json['changeType'] as String?,
  changeDate: json['changeDate'] as String?,
  objectType: json['objectType'] as String?,
  objectId: json['objectId'] as String?,
  changedBy: json['changedBy'] as String?,
  reasonCode: json['reasonCode'] as String?,
  comments: json['comments'] as String?,
  userToken: json['userToken'] as String?,
  history: json['history'] == null
      ? null
      : SubscriptionAuditHistoryModel.fromJson(
          json['history'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SubscriptionAuditLogModelToJson(
  SubscriptionAuditLogModel instance,
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

SubscriptionAuditHistoryModel _$SubscriptionAuditHistoryModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionAuditHistoryModel(
  id: json['id'] as String?,
  createdDate: json['createdDate'] as String?,
  updatedDate: json['updatedDate'] as String?,
  recordId: (json['recordId'] as num?)?.toInt(),
  accountRecordId: (json['accountRecordId'] as num?)?.toInt(),
  tenantRecordId: (json['tenantRecordId'] as num?)?.toInt(),
  bundleId: json['bundleId'] as String?,
  externalKey: json['externalKey'] as String?,
  category: json['category'] as String?,
  startDate: json['startDate'] as String?,
  bundleStartDate: json['bundleStartDate'] as String?,
  chargedThroughDate: json['chargedThroughDate'] as String?,
  migrated: json['migrated'] as bool?,
  tableName: json['tableName'] as String?,
  historyTableName: json['historyTableName'] as String?,
);

Map<String, dynamic> _$SubscriptionAuditHistoryModelToJson(
  SubscriptionAuditHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdDate': instance.createdDate,
  'updatedDate': instance.updatedDate,
  'recordId': instance.recordId,
  'accountRecordId': instance.accountRecordId,
  'tenantRecordId': instance.tenantRecordId,
  'bundleId': instance.bundleId,
  'externalKey': instance.externalKey,
  'category': instance.category,
  'startDate': instance.startDate,
  'bundleStartDate': instance.bundleStartDate,
  'chargedThroughDate': instance.chargedThroughDate,
  'migrated': instance.migrated,
  'tableName': instance.tableName,
  'historyTableName': instance.historyTableName,
};
