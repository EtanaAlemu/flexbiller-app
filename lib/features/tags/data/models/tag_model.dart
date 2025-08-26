import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/tag.dart';

part 'tag_model.g.dart';

@JsonSerializable()
class TagModel {
  @JsonKey(name: 'tagId')
  final String tagId;

  @JsonKey(name: 'objectType')
  final String objectType;

  @JsonKey(name: 'objectId')
  final String objectId;

  @JsonKey(name: 'tagDefinitionId')
  final String tagDefinitionId;

  @JsonKey(name: 'tagDefinitionName')
  final String tagDefinitionName;

  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>> auditLogs;

  const TagModel({
    required this.tagId,
    required this.objectType,
    required this.objectId,
    required this.tagDefinitionId,
    required this.tagDefinitionName,
    required this.auditLogs,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);

  Map<String, dynamic> toJson() => _$TagModelToJson(this);

  Tag toEntity() {
    return Tag(
      tagId: tagId,
      objectType: objectType,
      objectId: objectId,
      tagDefinitionId: tagDefinitionId,
      tagDefinitionName: tagDefinitionName,
      auditLogs: auditLogs,
    );
  }
}
