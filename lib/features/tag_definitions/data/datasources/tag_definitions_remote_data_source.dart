import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/tag_definition_model.dart';
import '../models/create_tag_definition_request_model.dart';
import '../models/tag_definition_audit_log_model.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';

abstract class TagDefinitionsRemoteDataSource {
  Future<List<TagDefinitionModel>> getTagDefinitions();
  Future<TagDefinitionModel> createTagDefinition(
    CreateTagDefinitionRequestModel request,
  );
  Future<TagDefinitionModel> getTagDefinitionById(String id);
  Future<List<TagDefinitionAuditLogModel>> getTagDefinitionAuditLogsWithHistory(
    String id,
  );
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

        // The server response doesn't include id, auditLogs, etc.
        // We need to create a model with the available data and defaults
        final tagDefinitionData = {
          'id': DateTime.now().millisecondsSinceEpoch
              .toString(), // Generate temporary ID
          'name': data['name'],
          'description': data['description'],
          'isControlTag': data['isControlTag'],
          'applicableObjectTypes': data['applicableObjectTypes'],
          'auditLogs':
              <Map<String, dynamic>>[], // Empty audit logs for new creation
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        return TagDefinitionModel.fromJson(tagDefinitionData);
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
  Future<List<TagDefinitionAuditLogModel>> getTagDefinitionAuditLogsWithHistory(
    String id,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getTagDefinitionAuditLogsWithHistory}/$id/auditLogsWithHistory',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => TagDefinitionAuditLogModel.fromJson(json))
            .toList();
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
        // Extract error message from server response
        String errorMessage = 'Failed to delete tag definition';
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'] as String;
          } else if (data.containsKey('error')) {
            errorMessage = data['error'] as String;
          }
        }
        throw ServerException(errorMessage, response.statusCode);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle server error responses
        final response = e.response!;
        String errorMessage = 'Failed to delete tag definition';

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'] as String;
          } else if (data.containsKey('error')) {
            errorMessage = data['error'] as String;
          }
        }

        throw ServerException(errorMessage, response.statusCode);
      } else {
        // Handle network errors
        throw NetworkException(e.message ?? 'Network error occurred');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw Exception('Failed to delete tag definition: $e');
    }
  }
}
