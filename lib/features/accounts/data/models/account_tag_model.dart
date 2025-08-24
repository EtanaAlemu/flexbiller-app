import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_tag.dart';

part 'account_tag_model.g.dart';

@JsonSerializable()
class AccountTagModel {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  const AccountTagModel({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isActive = true,
  });

  factory AccountTagModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTagModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTagModelToJson(this);

  factory AccountTagModel.fromEntity(AccountTag entity) {
    return AccountTagModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      color: entity.color,
      icon: entity.icon,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      isActive: entity.isActive,
    );
  }

  AccountTag toEntity() {
    return AccountTag(
      id: id,
      name: name,
      description: description,
      color: color,
      icon: icon,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      isActive: isActive,
    );
  }
}

@JsonSerializable()
class AccountTagAssignmentModel {
  final String tagId;
  final String objectType;
  final String objectId;
  final String tagDefinitionId;
  final String tagDefinitionName;
  final List<dynamic> auditLogs;

  const AccountTagAssignmentModel({
    required this.tagId,
    required this.objectType,
    required this.objectId,
    required this.tagDefinitionId,
    required this.tagDefinitionName,
    required this.auditLogs,
  });

  factory AccountTagAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTagAssignmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTagAssignmentModelToJson(this);

  factory AccountTagAssignmentModel.fromEntity(AccountTagAssignment entity) {
    // Legacy conversion - the new structure is different
    return AccountTagAssignmentModel(
      tagId: entity.id,
      objectType: 'ACCOUNT',
      objectId: entity.accountId,
      tagDefinitionId: entity.tagId,
      tagDefinitionName: entity.tagName,
      auditLogs: const [],
    );
  }

  AccountTagAssignment toEntity() {
    // Convert the new API structure to the legacy entity structure
    return AccountTagAssignment(
      id: tagId,
      accountId: objectId,
      tagId: tagDefinitionId,
      tagName: tagDefinitionName,
      tagColor: null, // Not provided by API
      tagIcon: null,  // Not provided by API
      assignedAt: DateTime.now(), // Not provided by API
      assignedBy: 'System', // Not provided by API
    );
  }
}
