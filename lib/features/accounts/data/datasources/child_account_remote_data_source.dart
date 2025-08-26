import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/child_account_model.dart';

abstract class ChildAccountRemoteDataSource {
  Future<ChildAccountModel> createChildAccount(ChildAccountModel childAccount);
}

@Injectable(as: ChildAccountRemoteDataSource)
class ChildAccountRemoteDataSourceImpl implements ChildAccountRemoteDataSource {
  final Dio _dio;

  ChildAccountRemoteDataSourceImpl(this._dio);

  @override
  Future<ChildAccountModel> createChildAccount(ChildAccountModel childAccount) async {
    try {
      final response = await _dio.post(
        '/accounts',
        data: childAccount.toJson(),
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        // Handle new response format with nested data.accountData
        if (responseData['data'] != null && 
            responseData['data']['accountData'] != null) {
          return ChildAccountModel.fromJson(
            responseData['data']['accountData'] as Map<String, dynamic>,
          );
        }
        // Handle old response format with direct data field
        else if (responseData['success'] == true && responseData['data'] != null) {
          return ChildAccountModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to create child account',
          );
        }
      } else {
        throw ServerException(
          'Failed to create child account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create child account');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create child account',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid child account data');
      } else if (e.response?.statusCode == 409) {
        throw ValidationException('Account with this email already exists');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while creating child account',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to create child account: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
