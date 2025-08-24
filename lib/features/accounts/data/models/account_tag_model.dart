import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_tag.dart';
import '../../domain/entities/account_timeline.dart';

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
      tagIcon: null, // Not provided by API
      assignedAt: DateTime.now(), // Not provided by API
      assignedBy: 'System', // Not provided by API
    );
  }
}

// New model for enhanced tag structure with tagDefinition
@JsonSerializable()
class AccountTagWithDefinitionModel {
  final String tagId;
  final String objectType;
  final String objectId;
  final String tagDefinitionId;
  final String tagDefinitionName;
  final List<dynamic> auditLogs;
  final TagDefinitionModel tagDefinition;

  const AccountTagWithDefinitionModel({
    required this.tagId,
    required this.objectType,
    required this.objectId,
    required this.tagDefinitionId,
    required this.tagDefinitionName,
    required this.auditLogs,
    required this.tagDefinition,
  });

  factory AccountTagWithDefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTagWithDefinitionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTagWithDefinitionModelToJson(this);

  // Convert to the standard AccountTagModel for backward compatibility
  AccountTagModel toAccountTagModel() {
    return AccountTagModel(
      id: tagDefinition.id,
      name: tagDefinition.name,
      description: tagDefinition.description,
      color: null, // Not provided by API
      icon: null, // Not provided by API
      createdAt: DateTime.now(), // Not provided by API
      updatedAt: DateTime.now(), // Not provided by API
      createdBy: 'System', // Not provided by API
      isActive: true, // Not provided by API
    );
  }

  // Convert to AccountTagAssignmentModel for backward compatibility
  AccountTagAssignmentModel toAccountTagAssignmentModel() {
    return AccountTagAssignmentModel(
      tagId: tagId,
      objectType: objectType,
      objectId: objectId,
      tagDefinitionId: tagDefinitionId,
      tagDefinitionName: tagDefinitionName,
      auditLogs: auditLogs,
    );
  }
}

@JsonSerializable()
class TagDefinitionModel {
  final String id;
  final bool isControlTag;
  final String name;
  final String description;
  final List<String> applicableObjectTypes;
  final List<dynamic> auditLogs;

  const TagDefinitionModel({
    required this.id,
    required this.isControlTag,
    required this.name,
    required this.description,
    required this.applicableObjectTypes,
    required this.auditLogs,
  });

  factory TagDefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$TagDefinitionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TagDefinitionModelToJson(this);
}

// Model for tag assignment response (when adding tags to account)
@JsonSerializable()
class AccountTagAssignmentResponseModel {
  final String accountId;
  final List<String> tagDefIds;
  final String addedAt;

  const AccountTagAssignmentResponseModel({
    required this.accountId,
    required this.tagDefIds,
    required this.addedAt,
  });

  factory AccountTagAssignmentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTagAssignmentResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTagAssignmentResponseModelToJson(this);

  // Convert to AccountTagAssignmentModel for backward compatibility
  List<AccountTagAssignmentModel> toAccountTagAssignmentModels() {
    return tagDefIds.map((tagDefId) => AccountTagAssignmentModel(
      tagId: '', // Not provided in response
      objectType: 'ACCOUNT',
      objectId: accountId,
      tagDefinitionId: tagDefId,
      tagDefinitionName: '', // Not provided in response
      auditLogs: [],
    )).toList();
  }
}
