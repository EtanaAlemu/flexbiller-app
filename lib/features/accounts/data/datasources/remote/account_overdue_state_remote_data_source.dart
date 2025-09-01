import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/account_overdue_state_model.dart';

abstract class AccountOverdueStateRemoteDataSource {
  Future<AccountOverdueStateModel> getOverdueState(String accountId);
}

@Injectable(as: AccountOverdueStateRemoteDataSource)
class AccountOverdueStateRemoteDataSourceImpl
    implements AccountOverdueStateRemoteDataSource {
  final DioClient _dioClient;

  AccountOverdueStateRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AccountOverdueStateModel> getOverdueState(String accountId) async {
    try {
      final response = await _dioClient.dio.get('/accounts/$accountId/overdue');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with overdueState object
        if (responseData['overdueState'] != null) {
          return AccountOverdueStateModel.fromJson(
            responseData['overdueState'] as Map<String, dynamic>,
          );
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          return AccountOverdueStateModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account overdue state',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account overdue state: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account overdue state');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account overdue state',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account overdue state',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch account overdue state: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
