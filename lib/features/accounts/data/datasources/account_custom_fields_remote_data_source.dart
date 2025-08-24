import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_custom_field_model.dart';

abstract class AccountCustomFieldsRemoteDataSource {
  Future<List<AccountCustomFieldModel>> getAccountCustomFields(String accountId);
  Future<AccountCustomFieldModel> getCustomField(String accountId, String customFieldId);
  Future<AccountCustomFieldModel> createCustomField(
    String accountId,
    String name,
    String value,
  );
  Future<AccountCustomFieldModel> updateCustomField(
    String accountId,
    String customFieldId,
    String name,
    String value,
  );
  Future<void> deleteCustomField(String accountId, String customFieldId);
}

@Injectable(as: AccountCustomFieldsRemoteDataSource)
class AccountCustomFieldsRemoteDataSourceImpl implements AccountCustomFieldsRemoteDataSource {
  final Dio _dio;

  AccountCustomFieldsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountCustomFieldModel>> getAccountCustomFields(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/customFields');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> customFieldsData = responseData['data'] as List<dynamic>;
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
        throw NetworkException('Connection timeout while fetching custom fields');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account custom fields: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AccountCustomFieldModel> getCustomField(String accountId, String customFieldId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/customFields/$customFieldId');

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
        throw ServerException('Failed to fetch custom field: ${response.statusCode}');
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
        throw NetworkException('Connection timeout while fetching custom field');
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
        data: {
          'name': name,
          'value': value,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountCustomFieldModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException('Failed to create custom field: ${response.statusCode}');
        }
      } else {
        throw ServerException('Failed to create custom field: ${response.statusCode}');
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
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while creating custom field');
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
  Future<AccountCustomFieldModel> updateCustomField(
    String accountId,
    String customFieldId,
    String name,
    String value,
  ) async {
    try {
      final response = await _dio.put(
        '/accounts/$accountId/customFields/$customFieldId',
        data: {
          'name': name,
          'value': value,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountCustomFieldModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException('Failed to update custom field: ${response.statusCode}');
        }
      } else {
        throw ServerException('Failed to update custom field: ${response.statusCode}');
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
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while updating custom field');
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
  Future<void> deleteCustomField(String accountId, String customFieldId) async {
    try {
      final response = await _dio.delete('/accounts/$accountId/customFields/$customFieldId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to delete custom field: ${response.statusCode}');
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
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while deleting custom field');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to delete custom field: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
