import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/account_cba_rebalancing_model.dart';

abstract class AccountCbaRebalancingRemoteDataSource {
  Future<AccountCbaRebalancingModel> rebalanceCba(String accountId);
}

@Injectable(as: AccountCbaRebalancingRemoteDataSource)
class AccountCbaRebalancingRemoteDataSourceImpl
    implements AccountCbaRebalancingRemoteDataSource {
  final Dio _dio;

  AccountCbaRebalancingRemoteDataSourceImpl(this._dio);

  @override
  Future<AccountCbaRebalancingModel> rebalanceCba(String accountId) async {
    try {
      final response = await _dio.put('/accounts/$accountId/cbaRebalancing');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with direct fields
        if (responseData['message'] != null &&
            responseData['accountId'] != null &&
            responseData['result'] != null) {
          return AccountCbaRebalancingModel.fromJson(responseData);
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          return AccountCbaRebalancingModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to rebalance account CBA',
          );
        }
      } else {
        throw ServerException(
          'Failed to rebalance account CBA: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to rebalance account CBA');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to rebalance account CBA',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid CBA rebalancing request');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while rebalancing account CBA',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to rebalance account CBA: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
