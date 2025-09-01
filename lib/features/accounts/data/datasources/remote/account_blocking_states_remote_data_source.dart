import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/account_blocking_state_model.dart';

abstract class AccountBlockingStatesRemoteDataSource {
  Future<List<AccountBlockingStateModel>> getAccountBlockingStates(String accountId);
  Future<AccountBlockingStateModel> getAccountBlockingState(String accountId, String stateId);
  Future<AccountBlockingStateModel> createAccountBlockingState(
    String accountId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
    String type,
  );
  Future<AccountBlockingStateModel> updateAccountBlockingState(
    String accountId,
    String stateId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
  );
  Future<void> deleteAccountBlockingState(String accountId, String stateId);
  Future<List<AccountBlockingStateModel>> getBlockingStatesByService(String accountId, String service);
  Future<List<AccountBlockingStateModel>> getActiveBlockingStates(String accountId);
}

@Injectable(as: AccountBlockingStatesRemoteDataSource)
class AccountBlockingStatesRemoteDataSourceImpl implements AccountBlockingStatesRemoteDataSource {
  final DioClient _dioClient;

  AccountBlockingStatesRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<AccountBlockingStateModel>> getAccountBlockingStates(String accountId) async {
    try {
      final response = await _dioClient.dio.get('/accounts/$accountId/block');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> blockingStatesData = responseData['data'] as List<dynamic>;
          return blockingStatesData
              .map((item) => AccountBlockingStateModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account blocking states',
          );
        }
      } else {
        throw ServerException('Failed to fetch account blocking states: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account blocking states');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account blocking states',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account blocking states');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account blocking states: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountBlockingStateModel> getAccountBlockingState(String accountId, String stateId) async {
    try {
      final response = await _dioClient.dio.get('/accounts/$accountId/block/$stateId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountBlockingStateModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account blocking state',
          );
        }
      } else {
        throw ServerException('Failed to fetch account blocking state: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account blocking state');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account blocking state',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account blocking state not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account blocking state');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account blocking state: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountBlockingStateModel> createAccountBlockingState(
    String accountId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
    String type,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        '/accounts/$accountId/block',
        data: {
          'stateName': stateName,
          'service': service,
          'isBlockChange': isBlockChange,
          'isBlockEntitlement': isBlockEntitlement,
          'isBlockBilling': isBlockBilling,
          'type': type,
        },
      );

      if (response.statusCode == 201) {
        // Since the API returns 201 for successful creation but doesn't return the created data,
        // we'll create a model with the provided data
        return AccountBlockingStateModel(
          stateName: stateName,
          service: service,
          isBlockChange: isBlockChange,
          isBlockEntitlement: isBlockEntitlement,
          isBlockBilling: isBlockBilling,
          effectiveDate: effectiveDate,
          type: type,
        );
      } else {
        throw ServerException('Failed to create account blocking state: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create account blocking state');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create account blocking state',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid blocking state data');
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while creating account blocking state');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to create account blocking state: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountBlockingStateModel> updateAccountBlockingState(
    String accountId,
    String stateId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
  ) async {
    try {
      final response = await _dioClient.dio.put(
        '/accounts/$accountId/block/$stateId',
        data: {
          'stateName': stateName,
          'service': service,
          'isBlockChange': isBlockChange,
          'isBlockEntitlement': isBlockEntitlement,
          'isBlockBilling': isBlockBilling,
          'effectiveDate': effectiveDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountBlockingStateModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to update account blocking state',
          );
        }
      } else {
        throw ServerException('Failed to update account blocking state: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to update account blocking state');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to update account blocking state',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid blocking state data');
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account blocking state not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while updating account blocking state');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to update account blocking state: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteAccountBlockingState(String accountId, String stateId) async {
    try {
      final response = await _dioClient.dio.delete('/accounts/$accountId/block/$stateId');

      if (response.statusCode == 204) {
        // Successfully deleted - no content returned
        return;
      } else {
        throw ServerException('Failed to delete account blocking state: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete account blocking state');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete account blocking state',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account blocking state not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while deleting account blocking state');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to delete account blocking state: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> getBlockingStatesByService(String accountId, String service) async {
    try {
      final response = await _dioClient.dio.get('/accounts/$accountId/block/service', queryParameters: {'service': service});

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> blockingStatesData = responseData['data'] as List<dynamic>;
          return blockingStatesData
              .map((item) => AccountBlockingStateModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch blocking states by service',
          );
        }
      } else {
        throw ServerException('Failed to fetch blocking states by service: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch blocking states by service');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch blocking states by service',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching blocking states by service');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch blocking states by service: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> getActiveBlockingStates(String accountId) async {
    try {
      final response = await _dioClient.dio.get('/accounts/$accountId/block/active');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> blockingStatesData = responseData['data'] as List<dynamic>;
          return blockingStatesData
              .map((item) => AccountBlockingStateModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch active blocking states',
          );
        }
      } else {
        throw ServerException('Failed to fetch active blocking states: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch active blocking states');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch active blocking states',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching active blocking states');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch active blocking states: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
