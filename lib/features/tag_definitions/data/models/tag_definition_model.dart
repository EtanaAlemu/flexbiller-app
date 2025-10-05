import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tag_definition.dart';

part 'tag_definition_model.g.dart';

@JsonSerializable()
class TagDefinitionModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'isControlTag')
  final bool isControlTag;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'applicableObjectTypes')
  final List<String> applicableObjectTypes;

  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>> auditLogs;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  const TagDefinitionModel({
    required this.id,
    required this.isControlTag,
    required this.name,
    required this.description,
    required this.applicableObjectTypes,
    required this.auditLogs,
    this.createdAt,
    this.updatedAt,
  });

  factory TagDefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$TagDefinitionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TagDefinitionModelToJson(this);

  TagDefinition toEntity() {
    return TagDefinition(
      id: id,
      isControlTag: isControlTag,
      name: name,
      description: description,
      applicableObjectTypes: applicableObjectTypes,
      auditLogs: auditLogs,
    );
  }

  factory TagDefinitionModel.fromEntity(TagDefinition entity) {
    return TagDefinitionModel(
      id: entity.id,
      isControlTag: entity.isControlTag,
      name: entity.name,
      description: entity.description,
      applicableObjectTypes: entity.applicableObjectTypes,
      auditLogs: entity.auditLogs,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
