import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/account_invoice_model.dart';

abstract class AccountInvoicesRemoteDataSource {
  Future<List<AccountInvoiceModel>> getInvoices(String accountId);
  Future<List<AccountInvoiceModel>> getPaginatedInvoices(String accountId);
}

@Injectable(as: AccountInvoicesRemoteDataSource)
class AccountInvoicesRemoteDataSourceImpl
    implements AccountInvoicesRemoteDataSource {
  final Dio _dio;

  AccountInvoicesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountInvoiceModel>> getInvoices(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/invoices');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with invoices array
        if (responseData['invoices'] != null &&
            responseData['invoices'] is List) {
          final List<dynamic> invoicesData =
              responseData['invoices'] as List<dynamic>;
          return invoicesData
              .map(
                (item) =>
                    AccountInvoiceModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> invoicesData =
              responseData['data'] as List<dynamic>;
          return invoicesData
              .map(
                (item) =>
                    AccountInvoiceModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account invoices',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account invoices: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account invoices');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account invoices',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account invoices',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account invoices: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountInvoiceModel>> getPaginatedInvoices(
    String accountId,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/invoices/pagination',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with invoices array
        if (responseData['invoices'] != null &&
            responseData['invoices'] is List) {
          final List<dynamic> invoicesData =
              responseData['invoices'] as List<dynamic>;
          return invoicesData
              .map(
                (item) =>
                    AccountInvoiceModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> invoicesData =
              responseData['data'] as List<dynamic>;
          return invoicesData
              .map(
                (item) =>
                    AccountInvoiceModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account invoices',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account invoices: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account invoices');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account invoices',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account invoices',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account invoices: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
