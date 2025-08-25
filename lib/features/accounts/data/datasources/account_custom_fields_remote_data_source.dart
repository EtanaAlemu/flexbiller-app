import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_custom_field_model.dart';

abstract class AccountCustomFieldsRemoteDataSource {
  Future<List<AccountCustomFieldModel>> getAccountCustomFields(
    String accountId,
  );
  Future<AccountCustomFieldModel> getCustomField(
    String accountId,
    String customFieldId,
  );
  Future<AccountCustomFieldModel> createCustomField(
    String accountId,
    String name,
    String value,
  );
  Future<List<AccountCustomFieldModel>> createMultipleCustomFields(
    String accountId,
    List<Map<String, String>> customFields,
  );
  Future<AccountCustomFieldModel> updateCustomField(
    String accountId,
    String customFieldId,
    String name,
    String value,
  );
  Future<List<AccountCustomFieldModel>> updateMultipleCustomFields(
    String accountId,
    List<Map<String, dynamic>> customFields,
  );
  Future<void> deleteCustomField(String accountId, String customFieldId);
  Future<void> deleteMultipleCustomFields(
    String accountId,
    List<String> customFieldIds,
  );
}

@Injectable(as: AccountCustomFieldsRemoteDataSource)
class AccountCustomFieldsRemoteDataSourceImpl
    implements AccountCustomFieldsRemoteDataSource {
  final Dio _dio;

  AccountCustomFieldsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountCustomFieldModel>> getAccountCustomFields(
    String accountId,
  ) async {
    try {
      final response = await _dio.get('/accounts/$accountId/customFields');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> customFieldsData =
              responseData['data'] as List<dynamic>;
          return customFieldsData
              .map(
                (field) => AccountCustomFieldModel.fromJson(
                  field as Map<String, dynamic>,
                ),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account custom fields',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account custom fields: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account custom fields');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account custom fields',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account custom fields not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching custom fields',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch account custom fields: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AccountCustomFieldModel> getCustomField(
    String accountId,
    String customFieldId,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/customFields/$customFieldId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountCustomFieldModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch custom field',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch custom field: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to custom field');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access custom field',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Custom field not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching custom field',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch custom field: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AccountCustomFieldModel> createCustomField(
    String accountId,
    String name,
    String value,
  ) async {
    try {
      final response = await _dio.post(
        '/accounts/$accountId/customFields',
        data: [
          {'name': name, 'value': value},
        ],
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        // Parse the creation response
        final creationResponse =
            AccountCustomFieldCreationResponseModel.fromJson(responseData);

        // Convert to AccountCustomFieldModel for backward compatibility
        final customFieldModels = creationResponse.toAccountCustomFieldModels();

        // Return the first created field (since we only created one)
        if (customFieldModels.isNotEmpty) {
          return customFieldModels.first;
        } else {
          // Fallback to creating a model with the provided data
          return AccountCustomFieldModel(
            customFieldId: DateTime.now().millisecondsSinceEpoch
                .toString(), // Temporary ID
            objectId: accountId,
            objectType: 'ACCOUNT',
            name: name,
            value: value,
            auditLogs: [
              CustomFieldAuditLogModel(
                changeType: 'INSERT',
                changeDate: DateTime.now(),
                changedBy: 'Current User', // This would come from user context
                reasonCode: null,
                comments: null,
                objectType: null,
                userToken: null,
              ),
            ],
          );
        }
      } else {
        throw ServerException(
          'Failed to create custom field: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create custom field');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create custom field',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid custom field data');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 errors with specific error messages
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          final message = responseData['message'] as String;
          final details = responseData['details'];
          
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account not found: $originalError');
            } else if (originalError.contains("CONNECTION_ERROR")) {
              throw ServerException('Server communication error: $originalError');
            }
          }
          
          throw ServerException('Server error: $message');
        } else {
          throw ServerException('Internal server error occurred');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while creating custom field',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to create custom field: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<AccountCustomFieldModel>> createMultipleCustomFields(
    String accountId,
    List<Map<String, String>> customFields,
  ) async {
    try {
      final response = await _dio.post(
        '/accounts/$accountId/customFields/bulk',
        data: customFields,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> createdFieldsData =
              responseData['data'] as List<dynamic>;
          return createdFieldsData
              .map(
                (field) => AccountCustomFieldModel.fromJson(
                  field as Map<String, dynamic>,
                ),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ??
                'Failed to create multiple custom fields',
          );
        }
      } else {
        throw ServerException(
          'Failed to create multiple custom fields: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create multiple custom fields');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create multiple custom fields',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(
          'Invalid custom field data for bulk creation',
        );
      } else if (e.response?.statusCode == 500) {
        // Handle 500 errors with specific error messages
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          final message = responseData['message'] as String;
          final details = responseData['details'];
          
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account not found: $originalError');
            } else if (originalError.contains("CONNECTION_ERROR")) {
              throw ServerException('Server communication error: $originalError');
            }
          }
          
          throw ServerException('Server error: $message');
        } else {
          throw ServerException('Internal server error occurred');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while creating multiple custom fields',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to create multiple custom fields: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AccountCustomFieldModel> updateCustomField(
    String accountId,
    String customFieldId,
    String name,
    String value,
  ) async {
    try {
      final response = await _dio.put(
        '/accounts/$accountId/customFields',
        data: [
          {'customFieldId': customFieldId, 'name': name, 'value': value},
        ],
      );

      if (response.statusCode == 200) {
        // Since the API returns 200 for successful update but doesn't return the updated field data,
        // we'll create a model with the provided data and the existing customFieldId
        // In a real scenario, the API might return the updated field data
        return AccountCustomFieldModel(
          customFieldId: customFieldId,
          objectId: accountId,
          objectType: 'ACCOUNT',
          name: name,
          value: value,
          auditLogs: [
            CustomFieldAuditLogModel(
              changeType: 'UPDATE',
              changeDate: DateTime.now(),
              changedBy: 'Current User', // This would come from user context
              reasonCode: null,
              comments: null,
              objectType: null,
              userToken: null,
            ),
          ],
        );
      } else {
        throw ServerException(
          'Failed to update custom field: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to update custom field');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to update custom field',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Custom field not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid custom field data');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 errors with specific error messages
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          final message = responseData['message'] as String;
          final details = responseData['details'];
          
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account or custom field not found: $originalError');
            } else if (originalError.contains("CONNECTION_ERROR")) {
              throw ServerException('Server communication error: $originalError');
            }
          }
          
          throw ServerException('Server error: $message');
        } else {
          throw ServerException('Internal server error occurred');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while updating custom field',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to update custom field: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<AccountCustomFieldModel>> updateMultipleCustomFields(
    String accountId,
    List<Map<String, dynamic>> customFields,
  ) async {
    try {
      final response = await _dio.put(
        '/accounts/$accountId/customFields/bulk',
        data: customFields,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> updatedFieldsData =
              responseData['data'] as List<dynamic>;
          return updatedFieldsData
              .map(
                (field) => AccountCustomFieldModel.fromJson(
                  field as Map<String, dynamic>,
                ),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ??
                'Failed to update multiple custom fields',
          );
        }
      } else {
        throw ServerException(
          'Failed to update multiple custom fields: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to update multiple custom fields');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to update multiple custom fields',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid custom field data for bulk update');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 errors with specific error messages
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          final message = responseData['message'] as String;
          final details = responseData['details'];
          
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account or custom field not found: $originalError');
            } else if (originalError.contains("CONNECTION_ERROR")) {
              throw ServerException('Server communication error: $originalError');
            }
          }
          
          throw ServerException('Server error: $message');
        } else {
          throw ServerException('Internal server error occurred');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while updating multiple custom fields',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to update multiple custom fields: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCustomField(String accountId, String customFieldId) async {
    try {
      final response = await _dio.delete(
        '/accounts/$accountId/customFields',
        queryParameters: {'customField': customFieldId},
      );

      if (response.statusCode == 204) {
        // Successfully deleted - no content returned
        return;
      } else {
        throw ServerException(
          'Failed to delete custom field: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete custom field');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete custom field',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Custom field not found');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 errors with specific error messages
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          final message = responseData['message'] as String;
          final details = responseData['details'];
          
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account or custom field not found: $originalError');
            } else if (originalError.contains("CONNECTION_ERROR")) {
              throw ServerException('Server communication error: $originalError');
            }
          }
          
          throw ServerException('Server error: $message');
        } else {
          throw ServerException('Internal server error occurred');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while deleting custom field',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to delete custom field: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMultipleCustomFields(
    String accountId,
    List<String> customFieldIds,
  ) async {
    try {
      final response = await _dio.delete(
        '/accounts/$accountId/customFields/bulk',
        queryParameters: {'customFieldIds': customFieldIds.join(',')},
      );

      if (response.statusCode == 204) {
        // Successfully deleted - no content returned
        return;
      } else {
        throw ServerException(
          'Failed to delete multiple custom fields: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete multiple custom fields');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete multiple custom fields',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid custom field IDs for bulk deletion');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 errors with specific error messages
        final responseData = e.response?.data;
        if (responseData != null && responseData['message'] != null) {
          final message = responseData['message'] as String;
          final details = responseData['details'];
          
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account or custom field not found: $originalError');
            } else if (originalError.contains("CONNECTION_ERROR")) {
              throw ServerException('Server communication error: $originalError');
            }
          }
          
          throw ServerException('Server error: $message');
        } else {
          throw ServerException('Internal server error occurred');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while deleting multiple custom fields',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to delete multiple custom fields: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
