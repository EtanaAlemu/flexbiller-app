import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/api_response.dart';
import '../models/account_model.dart';
import '../../domain/entities/accounts_query_params.dart';

abstract class AccountsRemoteDataSource {
  Future<List<AccountModel>> getAccounts(AccountsQueryParams params);
  Future<AccountModel> getAccountById(String accountId);
  Future<List<AccountModel>> searchAccounts(String searchKey);
  Future<AccountModel> createAccount(AccountModel account);
  Future<AccountModel> updateAccount(AccountModel account);
  Future<void> deleteAccount(String accountId);
}

@Injectable(as: AccountsRemoteDataSource)
class AccountsRemoteDataSourceImpl implements AccountsRemoteDataSource {
  final Dio _dio;

  AccountsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountModel>> getAccounts(AccountsQueryParams params) async {
    try {
      final response = await _dio.get(
        '/accounts',
        queryParameters: params.toQueryParameters(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> accountsData =
              responseData['data'] as List<dynamic>;
          return accountsData
              .map(
                (item) => AccountModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch accounts',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch accounts: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to accounts');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access accounts',
        );
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate server issues
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Resource not found');
            }
          }
        }
        throw ServerException('Server error while fetching accounts');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountModel> getAccountById(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          // For get operations, the account data is directly in the data field
          // Handle nested response structure (for create operations)
          if (data['success'] == true && data['accountData'] != null) {
            return AccountModel.fromJson(
              data['accountData'] as Map<String, dynamic>,
            );
          } else if (data['accountData'] != null) {
            // Fallback to direct accountData access
            return AccountModel.fromJson(
              data['accountData'] as Map<String, dynamic>,
            );
          } else {
            // For get operations, parse the data directly as account data
            return AccountModel.fromJson(data);
          }
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate account doesn't exist
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account not found');
            }
          }
        }
        throw ServerException('Server error while fetching account');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountModel>> searchAccounts(String searchKey) async {
    try {
      final response = await _dio.get('/accounts/search/$searchKey');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> accountsData =
              responseData['data'] as List<dynamic>;
          return accountsData
              .map(
                (item) => AccountModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to search accounts',
          );
        }
      } else {
        throw ServerException(
          'Failed to search accounts: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to accounts');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access accounts',
        );
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate server issues
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Resource not found');
            }
          }
        }
        throw ServerException('Server error while searching accounts');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountModel> createAccount(AccountModel account) async {
    try {
      final response = await _dio.post('/accounts', data: account.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          // Handle nested response structure
          if (data['success'] == true && data['accountData'] != null) {
            return AccountModel.fromJson(
              data['accountData'] as Map<String, dynamic>,
            );
          } else if (data['accountData'] != null) {
            // Fallback to direct accountData access
            return AccountModel.fromJson(
              data['accountData'] as Map<String, dynamic>,
            );
          } else {
            // Try to parse the data directly as account data
            return AccountModel.fromJson(data);
          }
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to create account',
          );
        }
      } else {
        throw ServerException(
          'Failed to create account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid account data');
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create account');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create account',
        );
      } else if (e.response?.statusCode == 409) {
        throw ValidationException('Account already exists');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate server issues
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Resource not found');
            }
          }
        }
        throw ServerException('Server error while creating account');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountModel> updateAccount(AccountModel account) async {
    try {
      final response = await _dio.put(
        '/accounts/${account.accountId}',
        data: account.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          // For update operations, the account data is directly in the data field
          // Handle nested response structure (for create operations)
          if (data['success'] == true && data['accountData'] != null) {
            return AccountModel.fromJson(
              data['accountData'] as Map<String, dynamic>,
            );
          } else if (data['accountData'] != null) {
            // Fallback to direct accountData access
            return AccountModel.fromJson(
              data['accountData'] as Map<String, dynamic>,
            );
          } else {
            // For update operations, parse the data directly as account data
            return AccountModel.fromJson(data);
          }
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to update account',
          );
        }
      } else {
        throw ServerException(
          'Failed to update account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid account data');
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to update account');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to update account',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate server issues
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account not found');
            }
          }
        }
        throw ServerException('Server error while updating account');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    try {
      final response = await _dio.delete('/accounts/$accountId');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // For successful deletion, the API returns the deleted account data
        // We can optionally log or process this data, but deletion is successful
        if (responseData['message'] != null && 
            responseData['message'].toString().toLowerCase().contains('deleted successfully')) {
          // Account was deleted successfully
          return;
        } else {
          // Unexpected response format but status is 200
          return;
        }
      } else {
        throw ServerException(
          'Failed to delete account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid account data for deletion');
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete account');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete account',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate tenant issues or server problems
        final responseData = e.response?.data;
        if (responseData != null && responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Account not found');
            } else if (originalError.contains("doesn't belong to tenant")) {
              throw ValidationException('Account does not belong to your tenant');
            }
          }
        }
        throw ServerException('Server error while deleting account');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
