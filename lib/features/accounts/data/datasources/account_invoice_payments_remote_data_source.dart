import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_invoice_payment_model.dart';

abstract class AccountInvoicePaymentsRemoteDataSource {
  Future<List<AccountInvoicePaymentModel>> getAccountInvoicePayments(String accountId);
  Future<AccountInvoicePaymentModel> getAccountInvoicePayment(String accountId, String paymentId);
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsByStatus(String accountId, String status);
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsByDateRange(String accountId, DateTime startDate, DateTime endDate);
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsByMethod(String accountId, String paymentMethod);
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsByInvoiceNumber(String accountId, String invoiceNumber);
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsWithPagination(String accountId, int page, int pageSize);
  Future<Map<String, dynamic>> getInvoicePaymentStatistics(String accountId);
  Future<AccountInvoicePaymentModel> createInvoicePayment(
    String accountId,
    double paymentAmount,
    String currency,
    String paymentMethod,
    String? notes,
  );
}

@Injectable(as: AccountInvoicePaymentsRemoteDataSource)
class AccountInvoicePaymentsRemoteDataSourceImpl implements AccountInvoicePaymentsRemoteDataSource {
  final Dio _dio;

  AccountInvoicePaymentsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountInvoicePaymentModel>> getAccountInvoicePayments(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/invoicePayments');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> paymentsData = responseData['data'] as List<dynamic>;
          return paymentsData
              .map((item) => AccountInvoicePaymentModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account invoice payments',
          );
        }
      } else {
        throw ServerException('Failed to fetch account invoice payments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account invoice payments');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account invoice payments',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account invoice payments');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account invoice payments: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountInvoicePaymentModel> getAccountInvoicePayment(String accountId, String paymentId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/invoicePayments/$paymentId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountInvoicePaymentModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account invoice payment',
          );
        }
      } else {
        throw ServerException('Failed to fetch account invoice payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account invoice payment');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account invoice payment',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account invoice payment not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account invoice payment');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account invoice payment: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsByStatus(String accountId, String status) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/invoicePayments/status',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> paymentsData = responseData['data'] as List<dynamic>;
          return paymentsData
              .map((item) => AccountInvoicePaymentModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch invoice payments by status',
          );
        }
      } else {
        throw ServerException('Failed to fetch invoice payments by status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch invoice payments by status');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch invoice payments by status',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching invoice payments by status');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch invoice payments by status: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/invoicePayments/dateRange',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> paymentsData = responseData['data'] as List<dynamic>;
          return paymentsData
              .map((item) => AccountInvoicePaymentModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch invoice payments by date range',
          );
        }
      } else {
        throw ServerException('Failed to fetch invoice payments by date range: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch invoice payments by date range');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch invoice payments by date range',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching invoice payments by date range');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch invoice payments by date range: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsByMethod(String accountId, String paymentMethod) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/invoicePayments/method',
        queryParameters: {'method': paymentMethod},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> paymentsData = responseData['data'] as List<dynamic>;
          return paymentsData
              .map((item) => AccountInvoicePaymentModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch invoice payments by method',
          );
        }
      } else {
        throw ServerException('Failed to fetch invoice payments by method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch invoice payments by method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch invoice payments by method',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching invoice payments by method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch invoice payments by method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsByInvoiceNumber(
    String accountId,
    String invoiceNumber,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/invoicePayments/invoice',
        queryParameters: {'invoiceNumber': invoiceNumber},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> paymentsData = responseData['data'] as List<dynamic>;
          return paymentsData
              .map((item) => AccountInvoicePaymentModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch invoice payments by invoice number',
          );
        }
      } else {
        throw ServerException('Failed to fetch invoice payments by invoice number: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch invoice payments by invoice number');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch invoice payments by invoice number',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching invoice payments by invoice number');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch invoice payments by invoice number: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getInvoicePaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/invoicePayments/pagination',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> paymentsData = responseData['data'] as List<dynamic>;
          return paymentsData
              .map((item) => AccountInvoicePaymentModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch invoice payments with pagination',
          );
        }
      } else {
        throw ServerException('Failed to fetch invoice payments with pagination: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch invoice payments with pagination');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch invoice payments with pagination',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching invoice payments with pagination');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch invoice payments with pagination: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInvoicePaymentStatistics(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/invoicePayments/statistics');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch invoice payment statistics',
          );
        }
      } else {
        throw ServerException('Failed to fetch invoice payment statistics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch invoice payment statistics');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch invoice payment statistics',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching invoice payment statistics');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch invoice payment statistics: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountInvoicePaymentModel> createInvoicePayment(
    String accountId,
    double paymentAmount,
    String currency,
    String paymentMethod,
    String? notes,
  ) async {
    try {
      final response = await _dio.post(
        '/accounts/$accountId/invoicePayments',
        data: {
          'paymentAmount': paymentAmount,
          'currency': currency,
          'paymentMethod': paymentMethod,
          'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountInvoicePaymentModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to create invoice payment',
          );
        }
      } else {
        throw ServerException('Failed to create invoice payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create invoice payment');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create invoice payment',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while creating invoice payment');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to create invoice payment: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
