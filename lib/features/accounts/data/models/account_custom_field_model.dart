import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_custom_field.dart';

part 'account_custom_field_model.g.dart';

@JsonSerializable()
class AccountCustomFieldModel {
  @JsonKey(name: 'customFieldId')
  final String customFieldId;
  @JsonKey(name: 'objectId')
  final String objectId;
  @JsonKey(name: 'objectType')
  final String objectType;
  final String name;
  final String value;
  @JsonKey(name: 'auditLogs')
  final List<CustomFieldAuditLogModel> auditLogs;

  const AccountCustomFieldModel({
    required this.customFieldId,
    required this.objectId,
    required this.objectType,
    required this.name,
    required this.value,
    required this.auditLogs,
  });

  factory AccountCustomFieldModel.fromJson(Map<String, dynamic> json) =>
      _$AccountCustomFieldModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountCustomFieldModelToJson(this);

  factory AccountCustomFieldModel.fromEntity(AccountCustomField entity) {
    return AccountCustomFieldModel(
      customFieldId: entity.customFieldId,
      objectId: entity.accountId, // Map accountId to objectId
      objectType: 'ACCOUNT', // Default to ACCOUNT for account custom fields
      name: entity.name,
      value: entity.value,
      auditLogs: entity.auditLogs
          .map((log) => CustomFieldAuditLogModel.fromEntity(log))
          .toList(),
    );
  }

  AccountCustomField toEntity() {
    return AccountCustomField(
      customFieldId: customFieldId,
      accountId: objectId, // Map objectId to accountId
      name: name,
      value: value,
      auditLogs: auditLogs.map((log) => log.toEntity()).toList(),
    );
  }
}

@JsonSerializable()
class CustomFieldAuditLogModel {
  @JsonKey(name: 'changeType')
  final String changeType;
  @JsonKey(name: 'changeDate')
  final DateTime changeDate;
  @JsonKey(name: 'changedBy')
  final String changedBy;
  @JsonKey(name: 'reasonCode')
  final String? reasonCode;
  final String? comments;
  @JsonKey(name: 'objectType')
  final String? objectType;
  @JsonKey(name: 'objectId')
  final String? objectId;
  @JsonKey(name: 'userToken')
  final String? userToken;

  const CustomFieldAuditLogModel({
    required this.changeType,
    required this.changeDate,
    required this.changedBy,
    this.reasonCode,
    this.comments,
    this.objectType,
    this.objectId,
    this.userToken,
  });

  factory CustomFieldAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$CustomFieldAuditLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomFieldAuditLogModelToJson(this);

  factory CustomFieldAuditLogModel.fromEntity(CustomFieldAuditLog entity) {
    return CustomFieldAuditLogModel(
      changeType: entity.changeType,
      changeDate: entity.changeDate,
      changedBy: entity.changedBy,
      reasonCode: entity.reasonCode,
      comments: entity.comments,
      objectType: entity.objectType,
      objectId: entity.objectId,
      userToken: entity.userToken,
    );
  }

  CustomFieldAuditLog toEntity() {
    return CustomFieldAuditLog(
      changeType: changeType,
      changeDate: changeDate,
      changedBy: changedBy,
      reasonCode: reasonCode,
      comments: comments,
      objectType: objectType,
      objectId: objectId,
      userToken: userToken,
    );
  }
}
