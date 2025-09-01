import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/account_bundle_model.dart';

abstract class AccountBundlesRemoteDataSource {
  Future<List<AccountBundleModel>> getAccountBundles(String accountId);
}

@Injectable(as: AccountBundlesRemoteDataSource)
class AccountBundlesRemoteDataSourceImpl
    implements AccountBundlesRemoteDataSource {
  final Dio _dio;

  AccountBundlesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountBundleModel>> getAccountBundles(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/bundles');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with bundles array
        if (responseData['bundles'] != null &&
            responseData['bundles'] is List) {
          final List<dynamic> bundlesData =
              responseData['bundles'] as List<dynamic>;
          return bundlesData
              .map(
                (item) =>
                    AccountBundleModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> bundlesData =
              responseData['data'] as List<dynamic>;
          return bundlesData
              .map(
                (item) =>
                    AccountBundleModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account bundles',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account bundles: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account bundles');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account bundles',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account bundles',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account bundles: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
