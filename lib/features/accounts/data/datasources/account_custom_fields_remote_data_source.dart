import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_custom_field_model.dart';

abstract class AccountCustomFieldsRemoteDataSource {
  Future<List<AccountCustomFieldModel>> getAllCustomFields(String accountId);
}

@Injectable(as: AccountCustomFieldsRemoteDataSource)
class AccountCustomFieldsRemoteDataSourceImpl
    implements AccountCustomFieldsRemoteDataSource {
  final Dio _dio;

  AccountCustomFieldsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountCustomFieldModel>> getAllCustomFields(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/allCustomFields');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with customFields array
        if (responseData['customFields'] != null &&
            responseData['customFields'] is List) {
          final List<dynamic> customFieldsData =
              responseData['customFields'] as List<dynamic>;
          return customFieldsData
              .map(
                (item) =>
                    AccountCustomFieldModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> customFieldsData =
              responseData['data'] as List<dynamic>;
          return customFieldsData
              .map(
                (item) =>
                    AccountCustomFieldModel.fromJson(item as Map<String, dynamic>),
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
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account custom fields',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch account custom fields: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
