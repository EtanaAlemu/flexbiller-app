import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/api_response.dart';
import '../models/account_model.dart';
import '../../domain/entities/accounts_query_params.dart';

abstract class AccountsRemoteDataSource {
  Future<List<AccountModel>> getAccounts(AccountsQueryParams params);
  Future<AccountModel> getAccountById(String accountId);
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
          return AccountModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
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
        throw ServerException('Server error while fetching account');
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
          return AccountModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
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
        '/accounts/${account.id}',
        data: account.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
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

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else {
        throw ServerException(
          'Failed to delete account: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete account');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete account',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.response?.statusCode == 500) {
        throw ServerException('Server error while deleting account');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
