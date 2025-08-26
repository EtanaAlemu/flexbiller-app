import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/tag_definition_model.dart';
import '../models/create_tag_definition_request_model.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class TagDefinitionsRemoteDataSource {
  Future<List<TagDefinitionModel>> getTagDefinitions();
  Future<TagDefinitionModel> createTagDefinition(CreateTagDefinitionRequestModel request);
}

@Injectable(as: TagDefinitionsRemoteDataSource)
class TagDefinitionsRemoteDataSourceImpl implements TagDefinitionsRemoteDataSource {
  final Dio _dio;

  TagDefinitionsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TagDefinitionModel>> getTagDefinitions() async {
    try {
      final response = await _dio.get(ApiEndpoints.getTagDefinitions);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => TagDefinitionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tag definitions');
      }
    } catch (e) {
      throw Exception('Failed to load tag definitions: $e');
    }
  }

  @override
  Future<TagDefinitionModel> createTagDefinition(CreateTagDefinitionRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createTagDefinition,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return TagDefinitionModel.fromJson(data);
      } else {
        throw Exception('Failed to create tag definition');
      }
    } catch (e) {
      throw Exception('Failed to create tag definition: $e');
    }
  }
}
