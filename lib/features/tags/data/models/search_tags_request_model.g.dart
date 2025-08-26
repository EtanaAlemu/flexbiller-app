// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_tags_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchTagsRequestModel _$SearchTagsRequestModelFromJson(
  Map<String, dynamic> json,
) => SearchTagsRequestModel(
  tagDefinitionName: json['tagDefinitionName'] as String,
  offset: (json['offset'] as num?)?.toInt() ?? 0,
  limit: (json['limit'] as num?)?.toInt() ?? 100,
  audit: json['audit'] as String? ?? 'NONE',
);

Map<String, dynamic> _$SearchTagsRequestModelToJson(
  SearchTagsRequestModel instance,
) => <String, dynamic>{
  'tagDefinitionName': instance.tagDefinitionName,
  'offset': instance.offset,
  'limit': instance.limit,
  'audit': instance.audit,
};
