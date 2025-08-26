import 'package:json_annotation/json_annotation.dart';

part 'search_tags_request_model.g.dart';

@JsonSerializable()
class SearchTagsRequestModel {
  @JsonKey(name: 'tagDefinitionName')
  final String tagDefinitionName;

  @JsonKey(name: 'offset')
  final int offset;

  @JsonKey(name: 'limit')
  final int limit;

  @JsonKey(name: 'audit')
  final String audit;

  const SearchTagsRequestModel({
    required this.tagDefinitionName,
    this.offset = 0,
    this.limit = 100,
    this.audit = 'NONE',
  });

  factory SearchTagsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SearchTagsRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchTagsRequestModelToJson(this);

  Map<String, dynamic> toQueryParameters() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'audit': audit,
    };
  }
}
