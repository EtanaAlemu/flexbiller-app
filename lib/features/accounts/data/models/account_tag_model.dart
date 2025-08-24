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
  final String id;
  final String accountId;
  final String tagId;
  final String tagName;
  final String? tagColor;
  final String? tagIcon;
  final DateTime assignedAt;
  final String assignedBy;

  const AccountTagAssignmentModel({
    required this.id,
    required this.accountId,
    required this.tagId,
    required this.tagName,
    this.tagColor,
    this.tagIcon,
    required this.assignedAt,
    required this.assignedBy,
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
