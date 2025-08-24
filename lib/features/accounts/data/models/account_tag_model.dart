import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_tag.dart';

part 'account_tag_model.g.dart';

@JsonSerializable()
class AccountTagModel extends AccountTag {
  const AccountTagModel({
    required super.id,
    required super.name,
    super.description,
    super.color,
    super.icon,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    super.isActive,
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
class AccountTagAssignmentModel extends AccountTagAssignment {
  const AccountTagAssignmentModel({
    required super.id,
    required super.accountId,
    required super.tagId,
    required super.tagName,
    super.tagColor,
    super.tagIcon,
    required super.assignedAt,
    required super.assignedBy,
  });

  factory AccountTagAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTagAssignmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTagAssignmentModelToJson(this);

  factory AccountTagAssignmentModel.fromEntity(AccountTagAssignment entity) {
    return AccountTagAssignmentModel(
      id: entity.id,
      accountId: entity.accountId,
      tagId: entity.tagId,
      tagName: entity.tagName,
      tagColor: entity.tagColor,
      tagIcon: entity.tagIcon,
      assignedAt: entity.assignedAt,
      assignedBy: entity.assignedBy,
    );
  }

  AccountTagAssignment toEntity() {
    return AccountTagAssignment(
      id: id,
      accountId: accountId,
      tagId: tagId,
      tagName: tagName,
      tagColor: tagColor,
      tagIcon: tagIcon,
      assignedAt: assignedAt,
      assignedBy: assignedBy,
    );
  }
}
