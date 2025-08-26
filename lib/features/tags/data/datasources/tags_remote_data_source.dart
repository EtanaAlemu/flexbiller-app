import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/tag_model.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class TagsRemoteDataSource {
  Future<List<TagModel>> getAllTags();
  Future<List<TagModel>> searchTags(
    String tagDefinitionName, {
    int offset = 0,
    int limit = 100,
    String audit = 'NONE',
  });
}

@Injectable(as: TagsRemoteDataSource)
class TagsRemoteDataSourceImpl implements TagsRemoteDataSource {
  final Dio _dio;

  TagsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TagModel>> getAllTags() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllTags);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => TagModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tags');
      }
    } catch (e) {
      throw Exception('Failed to load tags: $e');
    }
  }

  @override
  Future<List<TagModel>> searchTags(
    String tagDefinitionName, {
    int offset = 0,
    int limit = 100,
    String audit = 'NONE',
  }) async {
    try {
      final queryParams = {
        'offset': offset.toString(),
        'limit': limit.toString(),
        'audit': audit,
      };

      final response = await _dio.get(
        '${ApiEndpoints.searchTags}/$tagDefinitionName',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => TagModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search tags');
      }
    } catch (e) {
      throw Exception('Failed to search tags: $e');
    }
  }
}
