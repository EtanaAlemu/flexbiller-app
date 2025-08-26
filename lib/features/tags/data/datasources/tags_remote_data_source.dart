import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/tag_model.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class TagsRemoteDataSource {
  Future<List<TagModel>> getAllTags();
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
}
