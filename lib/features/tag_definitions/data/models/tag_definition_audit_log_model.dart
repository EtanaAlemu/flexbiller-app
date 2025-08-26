import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tag_definition_audit_log.dart';

part 'tag_definition_audit_log_model.g.dart';

@JsonSerializable()
class TagDefinitionAuditLogModel {
  @JsonKey(name: 'changeType')
  final String changeType;

  @JsonKey(name: 'changeDate')
  final String changeDate;

  @JsonKey(name: 'objectType')
  final String objectType;

  @JsonKey(name: 'objectId')
  final String objectId;

  @JsonKey(name: 'changedBy')
  final String changedBy;

  @JsonKey(name: 'reasonCode')
  final String? reasonCode;

  @JsonKey(name: 'comments')
  final String? comments;

  @JsonKey(name: 'userToken')
  final String userToken;

  @JsonKey(name: 'history')
  final TagDefinitionHistoryModel history;

  const TagDefinitionAuditLogModel({
    required this.changeType,
    required this.changeDate,
    required this.objectType,
    required this.objectId,
    required this.changedBy,
    this.reasonCode,
    this.comments,
    required this.userToken,
    required this.history,
  });

  factory TagDefinitionAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$TagDefinitionAuditLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$TagDefinitionAuditLogModelToJson(this);

  TagDefinitionAuditLog toEntity() {
    return TagDefinitionAuditLog(
      changeType: changeType,
      changeDate: DateTime.parse(changeDate),
      objectType: objectType,
      objectId: objectId,
      changedBy: changedBy,
      reasonCode: reasonCode,
      comments: comments,
      userToken: userToken,
      history: history.toEntity(),
    );
  }
}

@JsonSerializable()
class TagDefinitionHistoryModel {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'createdDate')
  final String createdDate;

  @JsonKey(name: 'updatedDate')
  final String updatedDate;

  @JsonKey(name: 'recordId')
  final int recordId;

  @JsonKey(name: 'accountRecordId')
  final int accountRecordId;

  @JsonKey(name: 'tenantRecordId')
  final int tenantRecordId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'applicableObjectTypes')
  final String applicableObjectTypes;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'isActive')
  final bool isActive;

  @JsonKey(name: 'tableName')
  final String tableName;

  @JsonKey(name: 'historyTableName')
  final String historyTableName;

  const TagDefinitionHistoryModel({
    this.id,
    required this.createdDate,
    required this.updatedDate,
    required this.recordId,
    required this.accountRecordId,
    required this.tenantRecordId,
    required this.name,
    required this.applicableObjectTypes,
    required this.description,
    required this.isActive,
    required this.tableName,
    required this.historyTableName,
  });

  factory TagDefinitionHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$TagDefinitionHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TagDefinitionHistoryModelToJson(this);

  TagDefinitionHistory toEntity() {
    return TagDefinitionHistory(
      id: id,
      createdDate: DateTime.parse(createdDate),
      updatedDate: DateTime.parse(updatedDate),
      recordId: recordId,
      accountRecordId: accountRecordId,
      tenantRecordId: tenantRecordId,
      name: name,
      applicableObjectTypes: applicableObjectTypes,
      description: description,
      isActive: isActive,
      tableName: tableName,
      historyTableName: historyTableName,
    );
  }
}
