import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_payment_model.dart';

abstract class AccountPaymentsRemoteDataSource {
  Future<List<AccountPaymentModel>> getAccountPayments(String accountId);
  Future<AccountPaymentModel> getAccountPayment(
    String accountId,
    String paymentId,
  );
  Future<List<AccountPaymentModel>> getAccountPaymentsByStatus(
    String accountId,
    String status,
  );
  Future<List<AccountPaymentModel>> getAccountPaymentsByType(
    String accountId,
    String type,
  );
  Future<List<AccountPaymentModel>> getAccountPaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<AccountPaymentModel>> getAccountPaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );
  Future<Map<String, dynamic>> getAccountPaymentStatistics(String accountId);
  Future<List<AccountPaymentModel>> searchAccountPayments(
    String accountId,
    String searchTerm,
  );
  Future<List<AccountPaymentModel>> getRefundedPayments(String accountId);
  Future<List<AccountPaymentModel>> getFailedPayments(String accountId);
  Future<List<AccountPaymentModel>> getSuccessfulPayments(String accountId);
  Future<List<AccountPaymentModel>> getPendingPayments(String accountId);

  /// Create a new payment for an account
  Future<AccountPaymentModel> createAccountPayment({
    required String accountId,
    required String paymentMethodId,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    String? description,
    Map<String, dynamic>? properties,
  });

  /// Create a new payment using external key (global endpoint)
  Future<AccountPaymentModel> createGlobalPayment({
    required String externalKey,
    required String paymentMethodId,
    required String transactionExternalKey,
    required String paymentExternalKey,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    List<Map<String, dynamic>>? properties,
  });
}

@Injectable(as: AccountPaymentsRemoteDataSource)
class AccountPaymentsRemoteDataSourceImpl
    implements AccountPaymentsRemoteDataSource {
  final Dio _dio;

  AccountPaymentsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountPaymentModel>> getAccountPayments(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/payments');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account payments',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account payments: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account payments');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account payments',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account payments',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account payments: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentModel> getAccountPayment(
    String accountId,
    String paymentId,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/payments/$paymentId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountPaymentModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account payment',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account payment: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account payment');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account payment',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account payment not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account payment',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account payment: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> getAccountPaymentsByStatus(
    String accountId,
    String status,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/payments/status',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ??
                'Failed to fetch account payments by status',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account payments by status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch account payments by status');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch account payments by status',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account payments by status',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch account payments by status: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> getAccountPaymentsByType(
    String accountId,
    String type,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/payments/type',
        queryParameters: {'type': type},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ??
                'Failed to fetch account payments by type',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account payments by type: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch account payments by type');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch account payments by type',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account payments by type',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch account payments by type: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> getAccountPaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/payments/dateRange',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ??
                'Failed to fetch account payments by date range',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account payments by date range: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(
          'Unauthorized to fetch account payments by date range',
        );
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch account payments by date range',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account payments by date range',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch account payments by date range: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> getAccountPaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/payments/paginated',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ??
                'Failed to fetch account payments with pagination',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account payments with pagination: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(
          'Unauthorized to fetch account payments with pagination',
        );
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch account payments with pagination',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account payments with pagination',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch account payments with pagination: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAccountPaymentStatistics(
    String accountId,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/payments/statistics',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw ServerException(
            responseData['message'] ??
                'Failed to fetch account payment statistics',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account payment statistics: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch account payment statistics');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch account payment statistics',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching account payment statistics',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch account payment statistics: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> searchAccountPayments(
    String accountId,
    String searchTerm,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/payments/search',
        queryParameters: {'searchTerm': searchTerm},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to search account payments',
          );
        }
      } else {
        throw ServerException(
          'Failed to search account payments: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to search account payments');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to search account payments',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while searching account payments',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to search account payments: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> getRefundedPayments(
    String accountId,
  ) async {
    try {
      final response = await _dio.get('/accounts/$accountId/payments/refunded');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch refunded payments',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch refunded payments: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch refunded payments');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch refunded payments',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching refunded payments',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch refunded payments: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> getFailedPayments(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/payments/failed');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch failed payments',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch failed payments: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch failed payments');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch failed payments',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching failed payments',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch failed payments: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> getSuccessfulPayments(
    String accountId,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/payments/successful',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch successful payments',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch successful payments: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch successful payments');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch successful payments',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching successful payments',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException(
          'Failed to fetch successful payments: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentModel>> getPendingPayments(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/payments/pending');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle new response format with payments array
        if (responseData['payments'] != null &&
            responseData['payments'] is List) {
          final List<dynamic> paymentsData =
              responseData['payments'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          final List<dynamic> paymentsData =
              responseData['data'] as List<dynamic>;
          return paymentsData
              .map(
                (item) =>
                    AccountPaymentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch pending payments',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch pending payments: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch pending payments');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch pending payments',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while fetching pending payments',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch pending payments: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentModel> createAccountPayment({
    required String accountId,
    required String paymentMethodId,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    String? description,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final response = await _dio.post(
        '/accounts/$accountId/payments',
        data: {
          'paymentMethodId': paymentMethodId,
          'transactionType': transactionType,
          'amount': amount,
          'currency': currency,
          'effectiveDate': effectiveDate.toIso8601String(),
          if (description != null) 'description': description,
          if (properties != null) 'properties': properties,
        },
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        // Handle new response format with nested payment.paymentData structure
        if (responseData['payment'] != null &&
            responseData['payment']['paymentData'] != null) {
          return AccountPaymentModel.fromJson(
            responseData['payment']['paymentData'] as Map<String, dynamic>,
          );
        }
        // Handle new response format with direct payment object
        else if (responseData['payment'] != null) {
          return AccountPaymentModel.fromJson(
            responseData['payment'] as Map<String, dynamic>,
          );
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          return AccountPaymentModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to create account payment',
          );
        }
      } else {
        throw ServerException(
          'Failed to create account payment: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create account payment');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create account payment',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while creating account payment',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to create account payment: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentModel> createGlobalPayment({
    required String externalKey,
    required String paymentMethodId,
    required String transactionExternalKey,
    required String paymentExternalKey,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    List<Map<String, dynamic>>? properties,
  }) async {
    try {
      final response = await _dio.post(
        '/accounts/payments',
        queryParameters: {
          'externalKey': externalKey,
          'paymentMethodId': paymentMethodId,
        },
        data: {
          'transactionExternalKey': transactionExternalKey,
          'paymentExternalKey': paymentExternalKey,
          'transactionType': transactionType,
          'amount': amount,
          'currency': currency,
          'effectiveDate': effectiveDate.toIso8601String(),
          if (properties != null) 'properties': properties,
        },
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        // Handle new response format with direct payment object
        if (responseData['payment'] != null) {
          return AccountPaymentModel.fromJson(
            responseData['payment'] as Map<String, dynamic>,
          );
        }
        // Handle old response format with data field
        else if (responseData['success'] == true &&
            responseData['data'] != null) {
          return AccountPaymentModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to create global payment',
          );
        }
      } else {
        throw ServerException(
          'Failed to create global payment: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create global payment');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create global payment',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found for global payment');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Connection timeout while creating global payment',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to create global payment: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
