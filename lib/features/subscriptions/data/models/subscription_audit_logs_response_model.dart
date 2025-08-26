import 'package:json_annotation/json_annotation.dart';

part 'subscription_audit_logs_response_model.g.dart';

@JsonSerializable()
class SubscriptionAuditLogsResponseModel {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'code')
  final int code;

  @JsonKey(name: 'data')
  final List<SubscriptionAuditLogModel> data;

  @JsonKey(name: 'message')
  final String message;

  const SubscriptionAuditLogsResponseModel({
    required this.success,
    required this.code,
    required this.data,
    required this.message,
  });

  factory SubscriptionAuditLogsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionAuditLogsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionAuditLogsResponseModelToJson(this);
}

@JsonSerializable()
class SubscriptionAuditLogModel {
  @JsonKey(name: 'changeType')
  final String? changeType;

  @JsonKey(name: 'changeDate')
  final String? changeDate;

  @JsonKey(name: 'objectType')
  final String? objectType;

  @JsonKey(name: 'objectId')
  final String? objectId;

  @JsonKey(name: 'changedBy')
  final String? changedBy;

  @JsonKey(name: 'reasonCode')
  final String? reasonCode;

  @JsonKey(name: 'comments')
  final String? comments;

  @JsonKey(name: 'userToken')
  final String? userToken;

  @JsonKey(name: 'history')
  final SubscriptionAuditHistoryModel? history;

  const SubscriptionAuditLogModel({
    this.changeType,
    this.changeDate,
    this.objectType,
    this.objectId,
    this.changedBy,
    this.reasonCode,
    this.comments,
    this.userToken,
    this.history,
  });

  factory SubscriptionAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionAuditLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionAuditLogModelToJson(this);
}

@JsonSerializable()
class SubscriptionAuditHistoryModel {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'createdDate')
  final String? createdDate;

  @JsonKey(name: 'updatedDate')
  final String? updatedDate;

  @JsonKey(name: 'recordId')
  final int? recordId;

  @JsonKey(name: 'accountRecordId')
  final int? accountRecordId;

  @JsonKey(name: 'tenantRecordId')
  final int? tenantRecordId;

  @JsonKey(name: 'bundleId')
  final String? bundleId;

  @JsonKey(name: 'externalKey')
  final String? externalKey;

  @JsonKey(name: 'category')
  final String? category;

  @JsonKey(name: 'startDate')
  final String? startDate;

  @JsonKey(name: 'bundleStartDate')
  final String? bundleStartDate;

  @JsonKey(name: 'chargedThroughDate')
  final String? chargedThroughDate;

  @JsonKey(name: 'migrated')
  final bool? migrated;

  @JsonKey(name: 'tableName')
  final String? tableName;

  @JsonKey(name: 'historyTableName')
  final String? historyTableName;

  const SubscriptionAuditHistoryModel({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.recordId,
    this.accountRecordId,
    this.tenantRecordId,
    this.bundleId,
    this.externalKey,
    this.category,
    this.startDate,
    this.bundleStartDate,
    this.chargedThroughDate,
    this.migrated,
    this.tableName,
    this.historyTableName,
  });

  factory SubscriptionAuditHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionAuditHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionAuditHistoryModelToJson(this);
}
