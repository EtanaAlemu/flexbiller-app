import 'package:json_annotation/json_annotation.dart';

part 'create_tag_definition_request_model.g.dart';

@JsonSerializable()
class CreateTagDefinitionRequestModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'isControlTag')
  final bool isControlTag;

  @JsonKey(name: 'applicableObjectTypes')
  final List<String> applicableObjectTypes;

  const CreateTagDefinitionRequestModel({
    required this.name,
    required this.description,
    required this.isControlTag,
    required this.applicableObjectTypes,
  });

  factory CreateTagDefinitionRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateTagDefinitionRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTagDefinitionRequestModelToJson(this);
}
