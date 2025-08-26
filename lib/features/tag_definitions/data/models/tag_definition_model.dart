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
}
