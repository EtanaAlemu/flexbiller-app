// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_audit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountAuditLogModel _$AccountAuditLogModelFromJson(
  Map<String, dynamic> json,
) => AccountAuditLogModel(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  action: json['action'] as String,
  entityType: json['entityType'] as String,
  entityId: json['entityId'] as String,
  oldValue: json['oldValue'] as String,
  newValue: json['newValue'] as String,
  description: json['description'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  ipAddress: json['ipAddress'] as String?,
  userAgent: json['userAgent'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AccountAuditLogModelToJson(
  AccountAuditLogModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'userId': instance.userId,
  'userName': instance.userName,
  'action': instance.action,
  'entityType': instance.entityType,
  'entityId': instance.entityId,
  'oldValue': instance.oldValue,
  'newValue': instance.newValue,
  'description': instance.description,
  'timestamp': instance.timestamp.toIso8601String(),
  'ipAddress': instance.ipAddress,
  'userAgent': instance.userAgent,
  'metadata': instance.metadata,
};
