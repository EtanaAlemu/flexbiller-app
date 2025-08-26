import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/tag_definition_model.dart';
import '../models/create_tag_definition_request_model.dart';
import '../models/tag_definition_audit_log_model.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class TagDefinitionsRemoteDataSource {
  Future<List<TagDefinitionModel>> getTagDefinitions();
  Future<TagDefinitionModel> createTagDefinition(
    CreateTagDefinitionRequestModel request,
  );
  Future<TagDefinitionModel> getTagDefinitionById(String id);
  Future<List<TagDefinitionAuditLogModel>> getTagDefinitionAuditLogsWithHistory(String id);
  Future<void> deleteTagDefinition(String id);
}

@Injectable(as: TagDefinitionsRemoteDataSource)
class TagDefinitionsRemoteDataSourceImpl
    implements TagDefinitionsRemoteDataSource {
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
  Future<TagDefinitionModel> createTagDefinition(
    CreateTagDefinitionRequestModel request,
  ) async {
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

  @override
  Future<TagDefinitionModel> getTagDefinitionById(String id) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getTagDefinitionById}/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return TagDefinitionModel.fromJson(data);
      } else {
        throw Exception('Failed to load tag definition');
      }
    } catch (e) {
      throw Exception('Failed to load tag definition: $e');
    }
  }

  @override
  Future<List<TagDefinitionAuditLogModel>> getTagDefinitionAuditLogsWithHistory(String id) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getTagDefinitionAuditLogsWithHistory}/$id/auditLogsWithHistory',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => TagDefinitionAuditLogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tag definition audit logs');
      }
    } catch (e) {
      throw Exception('Failed to load tag definition audit logs: $e');
    }
  }

  @override
  Future<void> deleteTagDefinition(String id) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.deleteTagDefinition}/$id',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete tag definition');
      }
    } catch (e) {
      throw Exception('Failed to delete tag definition: $e');
    }
  }
}
