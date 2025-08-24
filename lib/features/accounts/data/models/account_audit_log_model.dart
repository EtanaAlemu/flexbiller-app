import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_audit_log.dart';

part 'account_audit_log_model.g.dart';

@JsonSerializable()
class AccountAuditLogModel {
  final String id;
  @JsonKey(name: 'accountId')
  final String accountId;
  @JsonKey(name: 'userId')
  final String userId;
  @JsonKey(name: 'userName')
  final String userName;
  final String action;
  @JsonKey(name: 'entityType')
  final String entityType;
  @JsonKey(name: 'entityId')
  final String entityId;
  @JsonKey(name: 'oldValue')
  final String oldValue;
  @JsonKey(name: 'newValue')
  final String newValue;
  final String description;
  final DateTime timestamp;
  @JsonKey(name: 'ipAddress')
  final String? ipAddress;
  @JsonKey(name: 'userAgent')
  final String? userAgent;
  final Map<String, dynamic>? metadata;

  const AccountAuditLogModel({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.oldValue,
    required this.newValue,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.metadata,
  });

  factory AccountAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$AccountAuditLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountAuditLogModelToJson(this);

  factory AccountAuditLogModel.fromEntity(AccountAuditLog entity) {
    return AccountAuditLogModel(
      id: entity.id,
      accountId: entity.accountId,
      userId: entity.userId,
      userName: entity.userName,
      action: entity.action,
      entityType: entity.entityType,
      entityId: entity.entityId,
      oldValue: entity.oldValue,
      newValue: entity.newValue,
      description: entity.description,
      timestamp: entity.timestamp,
      ipAddress: entity.ipAddress,
      userAgent: entity.userAgent,
      metadata: entity.metadata,
    );
  }

  AccountAuditLog toEntity() {
    return AccountAuditLog(
      id: id,
      accountId: accountId,
      userId: userId,
      userName: userName,
      action: action,
      entityType: entityType,
      entityId: entityId,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
      timestamp: timestamp,
      ipAddress: ipAddress,
      userAgent: userAgent,
      metadata: metadata,
    );
  }
}
