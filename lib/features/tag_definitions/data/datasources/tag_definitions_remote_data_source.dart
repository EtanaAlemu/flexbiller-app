import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/tag_definition_model.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class TagDefinitionsRemoteDataSource {
  Future<List<TagDefinitionModel>> getTagDefinitions();
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
}
