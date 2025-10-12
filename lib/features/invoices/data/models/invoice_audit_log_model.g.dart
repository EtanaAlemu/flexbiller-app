// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_audit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceAuditLogModel _$InvoiceAuditLogModelFromJson(
  Map<String, dynamic> json,
) => InvoiceAuditLogModel(
  changeType: json['changeType'] as String,
  changeDate: json['changeDate'] as String,
  objectType: json['objectType'] as String,
  objectId: json['objectId'] as String,
  changedBy: json['changedBy'] as String,
  reasonCode: json['reasonCode'] as String?,
  comments: json['comments'] as String?,
  userToken: json['userToken'] as String,
  history: json['history'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$InvoiceAuditLogModelToJson(
  InvoiceAuditLogModel instance,
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
