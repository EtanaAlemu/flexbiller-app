import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_payment_method_model.dart';

abstract class AccountPaymentMethodsRemoteDataSource {
  Future<List<AccountPaymentMethodModel>> getAccountPaymentMethods(String accountId);
  Future<AccountPaymentMethodModel> getAccountPaymentMethod(String accountId, String paymentMethodId);
  Future<AccountPaymentMethodModel?> getDefaultPaymentMethod(String accountId);
  Future<List<AccountPaymentMethodModel>> getActivePaymentMethods(String accountId);
  Future<List<AccountPaymentMethodModel>> getPaymentMethodsByType(String accountId, String type);
  Future<AccountPaymentMethodModel> setDefaultPaymentMethod(String accountId, String paymentMethodId, bool payAllUnpaidInvoices);
  Future<AccountPaymentMethodModel> createPaymentMethod(String accountId, String paymentMethodType, String paymentMethodName, Map<String, dynamic> paymentDetails);
  Future<AccountPaymentMethodModel> updatePaymentMethod(String accountId, String paymentMethodId, Map<String, dynamic> updates);
  Future<void> deletePaymentMethod(String accountId, String paymentMethodId);
  Future<AccountPaymentMethodModel> deactivatePaymentMethod(String accountId, String paymentMethodId);
  Future<AccountPaymentMethodModel> reactivatePaymentMethod(String accountId, String paymentMethodId);
  Future<List<AccountPaymentMethodModel>> refreshPaymentMethods(String accountId);
}

@Injectable(as: AccountPaymentMethodsRemoteDataSource)
class AccountPaymentMethodsRemoteDataSourceImpl implements AccountPaymentMethodsRemoteDataSource {
  final Dio _dio;

  AccountPaymentMethodsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountPaymentMethodModel>> getAccountPaymentMethods(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/paymentMethods');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> methodsData = responseData['data'] as List<dynamic>;
          return methodsData
              .map((item) => AccountPaymentMethodModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account payment methods',
          );
        }
      } else {
        throw ServerException('Failed to fetch account payment methods: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account payment methods');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account payment methods',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account payment methods');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account payment methods: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentMethodModel> getAccountPaymentMethod(String accountId, String paymentMethodId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/paymentMethods/$paymentMethodId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountPaymentMethodModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account payment method',
          );
        }
      } else {
        throw ServerException('Failed to fetch account payment method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account payment method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account payment method',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account payment method not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account payment method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account payment method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentMethodModel?> getDefaultPaymentMethod(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/paymentMethods/default');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountPaymentMethodModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else if (responseData['success'] == true && responseData['data'] == null) {
          return null; // No default payment method
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch default payment method',
          );
        }
      } else {
        throw ServerException('Failed to fetch default payment method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch default payment method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch default payment method',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching default payment method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch default payment method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getActivePaymentMethods(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/paymentMethods/active');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> methodsData = responseData['data'] as List<dynamic>;
          return methodsData
              .map((item) => AccountPaymentMethodModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch active payment methods',
          );
        }
      } else {
        throw ServerException('Failed to fetch active payment methods: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch active payment methods');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch active payment methods',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching active payment methods');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch active payment methods: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getPaymentMethodsByType(String accountId, String type) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/paymentMethods/type',
        queryParameters: {'type': type},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> methodsData = responseData['data'] as List<dynamic>;
          return methodsData
              .map((item) => AccountPaymentMethodModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch payment methods by type',
          );
        }
      } else {
        throw ServerException('Failed to fetch payment methods by type: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch payment methods by type');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch payment methods by type',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching payment methods by type');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch payment methods by type: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentMethodModel> setDefaultPaymentMethod(
    String accountId,
    String paymentMethodId,
    bool payAllUnpaidInvoices,
  ) async {
    try {
      final response = await _dio.put(
        '/accounts/$accountId/paymentMethods/$paymentMethodId/setDefault',
        queryParameters: {'payAllUnpaidInvoices': payAllUnpaidInvoices},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountPaymentMethodModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to set default payment method',
          );
        }
      } else {
        throw ServerException('Failed to set default payment method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to set default payment method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to set default payment method',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or payment method not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while setting default payment method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to set default payment method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentMethodModel> createPaymentMethod(
    String accountId,
    String paymentMethodType,
    String paymentMethodName,
    Map<String, dynamic> paymentDetails,
  ) async {
    try {
      final response = await _dio.post(
        '/accounts/$accountId/paymentMethods',
        data: {
          'paymentMethodType': paymentMethodType,
          'paymentMethodName': paymentMethodName,
          ...paymentDetails,
        },
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountPaymentMethodModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to create payment method',
          );
        }
      } else {
        throw ServerException('Failed to create payment method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create payment method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create payment method',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid payment method data');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while creating payment method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to create payment method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentMethodModel> updatePaymentMethod(
    String accountId,
    String paymentMethodId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dio.put(
        '/accounts/$accountId/paymentMethods/$paymentMethodId',
        data: updates,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountPaymentMethodModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to update payment method',
          );
        }
      } else {
        throw ServerException('Failed to update payment method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to update payment method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to update payment method',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or payment method not found');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid update data');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while updating payment method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to update payment method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deletePaymentMethod(String accountId, String paymentMethodId) async {
    try {
      final response = await _dio.delete('/accounts/$accountId/paymentMethods/$paymentMethodId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] != true) {
          throw ServerException(
            responseData['message'] ?? 'Failed to delete payment method',
          );
        }
      } else {
        throw ServerException('Failed to delete payment method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete payment method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete payment method',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or payment method not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while deleting payment method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to delete payment method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentMethodModel> deactivatePaymentMethod(String accountId, String paymentMethodId) async {
    try {
      final response = await _dio.put(
        '/accounts/$accountId/paymentMethods/$paymentMethodId/deactivate',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountPaymentMethodModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to deactivate payment method',
          );
        }
      } else {
        throw ServerException('Failed to deactivate payment method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to deactivate payment method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to deactivate payment method',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or payment method not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while deactivating payment method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to deactivate payment method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountPaymentMethodModel> reactivatePaymentMethod(String accountId, String paymentMethodId) async {
    try {
      final response = await _dio.put(
        '/accounts/$accountId/paymentMethods/$paymentMethodId/reactivate',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountPaymentMethodModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to reactivate payment method',
          );
        }
      } else {
        throw ServerException('Failed to reactivate payment method: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to reactivate payment method');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to reactivate payment method',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or payment method not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while reactivating payment method');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to reactivate payment method: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> refreshPaymentMethods(String accountId) async {
    try {
      final response = await _dio.put('/accounts/$accountId/paymentMethods/refresh');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> methodsData = responseData['data'] as List<dynamic>;
          return methodsData
              .map((item) => AccountPaymentMethodModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to refresh payment methods',
          );
        }
      } else {
        throw ServerException('Failed to refresh payment methods: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to refresh payment methods');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to refresh payment methods',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while refreshing payment methods');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to refresh payment methods: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
