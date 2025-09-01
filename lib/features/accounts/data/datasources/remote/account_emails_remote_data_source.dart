import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/account_email_model.dart';

abstract class AccountEmailsRemoteDataSource {
  Future<List<AccountEmailModel>> getAccountEmails(String accountId);
  Future<AccountEmailModel> getAccountEmail(String accountId, String emailId);
  Future<AccountEmailModel> createAccountEmail(String accountId, String email);
  Future<AccountEmailModel> updateAccountEmail(String accountId, String emailId, String email);
  Future<void> deleteAccountEmail(String accountId, String emailId);
  Future<List<AccountEmailModel>> searchEmailsByAddress(String emailAddress);
  Future<List<AccountEmailModel>> getEmailsByDomain(String domain);
}

@Injectable(as: AccountEmailsRemoteDataSource)
class AccountEmailsRemoteDataSourceImpl implements AccountEmailsRemoteDataSource {
  final Dio _dio;

  AccountEmailsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountEmailModel>> getAccountEmails(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/emails');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> emailsData = responseData['data'] as List<dynamic>;
          return emailsData
              .map((item) => AccountEmailModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account emails',
          );
        }
      } else {
        throw ServerException('Failed to fetch account emails: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account emails');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account emails',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account emails');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account emails: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountEmailModel> getAccountEmail(String accountId, String emailId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/emails/$emailId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountEmailModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account email',
          );
        }
      } else {
        throw ServerException('Failed to fetch account email: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account email');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account email',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account email not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account email');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account email: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountEmailModel> createAccountEmail(String accountId, String email) async {
    try {
      final response = await _dio.post(
        '/accounts/$accountId/emails',
        data: {'email': email},
      );

      if (response.statusCode == 201) {
        // Since the API returns 201 for successful creation but doesn't return the created email data,
        // we'll create a model with the provided data and a generated ID
        // In a real scenario, the API might return the created email data
        return AccountEmailModel(
          accountId: accountId,
          email: email,
        );
      } else {
        throw ServerException('Failed to create account email: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create account email');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create account email',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid email data');
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while creating account email');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to create account email: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountEmailModel> updateAccountEmail(String accountId, String emailId, String email) async {
    try {
      final response = await _dio.put(
        '/accounts/$accountId/emails/$emailId', // emailId is actually the email address
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        // Since the API returns 200 for successful update but doesn't return the updated email data,
        // we'll create a model with the provided data
        return AccountEmailModel(
          accountId: accountId,
          email: email,
        );
      } else {
        throw ServerException('Failed to update account email: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to update account email');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to update account email',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid email data');
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or email not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while updating account email');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to update account email: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteAccountEmail(String accountId, String emailId) async {
    try {
      final response = await _dio.delete('/accounts/$accountId/emails/$emailId');

      if (response.statusCode == 200) {
        // Successfully deleted - API returns 200 with success message
        return;
      } else {
        throw ServerException('Failed to delete account email: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete account email');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete account email',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account or email not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while deleting account email');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to delete account email: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountEmailModel>> searchEmailsByAddress(String emailAddress) async {
    try {
      final response = await _dio.get('/accounts/emails/search', queryParameters: {'email': emailAddress});

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> emailsData = responseData['data'] as List<dynamic>;
          return emailsData
              .map((item) => AccountEmailModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to search emails',
          );
        }
      } else {
        throw ServerException('Failed to search emails: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to search emails');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to search emails',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while searching emails');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to search emails: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountEmailModel>> getEmailsByDomain(String domain) async {
    try {
      final response = await _dio.get('/accounts/emails/domain', queryParameters: {'domain': domain});

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> emailsData = responseData['data'] as List<dynamic>;
          return emailsData
              .map((item) => AccountEmailModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch emails by domain',
          );
        }
      } else {
        throw ServerException('Failed to fetch emails by domain: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch emails by domain');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch emails by domain',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching emails by domain');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch emails by domain: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
