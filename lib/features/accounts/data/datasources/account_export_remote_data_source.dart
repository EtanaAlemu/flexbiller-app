import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_export_model.dart';

abstract class AccountExportRemoteDataSource {
  Future<AccountExportModel> exportAccountData(String accountId, {String? format});
}

@Injectable(as: AccountExportRemoteDataSource)
class AccountExportRemoteDataSourceImpl implements AccountExportRemoteDataSource {
  final Dio _dio;

  AccountExportRemoteDataSourceImpl(this._dio);

  @override
  Future<AccountExportModel> exportAccountData(String accountId, {String? format}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (format != null) {
        queryParams['format'] = format;
      }

      final response = await _dio.get(
        '/accounts/$accountId/export',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with exportData object
        if (responseData['exportData'] != null) {
          return AccountExportModel.fromJson(
            responseData['exportData'] as Map<String, dynamic>,
          );
        }
        // Handle old response format with data field
        else if (responseData['success'] == true && responseData['data'] != null) {
          return AccountExportModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to export account data',
          );
        }
      } else {
        throw ServerException(
          'Failed to export account data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to export account data');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to export account data',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid export request');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while exporting account data',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to export account data: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
