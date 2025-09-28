import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../models/auth_response.dart';
import '../../domain/entities/user.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/dao/auth_dao.dart';
import '../../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String name);
  Future<void> logout();
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> forgotPassword(String email);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> resetPassword(String token, String newPassword);
  Future<User> updateUser(User user);
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;
  final Logger _logger = Logger();

  AuthRemoteDataSourceImpl(this._dioClient);

  // Public getter for DioClient to allow access from repository for debugging
  DioClient get dioClient => _dioClient;

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      _logger.i(
        '🌐 Making login request to: ${_dioClient.dio.options.baseUrl}${ApiEndpoints.login}',
      );
      _logger.i('📤 Request data: ${AuthDao.loginBody(email, password)}');
      _logger.i(
        '⏱️ Connection timeout: ${_dioClient.dio.options.connectTimeout}',
      );
      _logger.i('⏱️ Receive timeout: ${_dioClient.dio.options.receiveTimeout}');

      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: AuthDao.loginBody(email, password),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          response.data,
          (json) => AuthResponse.fromJson(json),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Check if the nested data also indicates success
          if (apiResponse.data!.success) {
            return apiResponse.data!;
          } else {
            throw ServerException(
              'Login failed: ${apiResponse.message}',
              response.statusCode,
            );
          }
        } else {
          throw ServerException(
            apiResponse.message ?? 'Login failed',
            response.statusCode,
          );
        }
      } else {
        throw ServerException(
          'Login failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ DioException caught: ${e.type}');
      _logger.e('❌ DioException message: ${e.message}');
      _logger.e('❌ DioException error: ${e.error}');
      _logger.e('❌ DioException response status: ${e.response?.statusCode}');
      _logger.e('❌ DioException response data: ${e.response?.data}');
      _logger.e('❌ DioException request URL: ${e.requestOptions.uri}');
      _logger.e('❌ DioException request method: ${e.requestOptions.method}');
      _logger.e('❌ DioException request data: ${e.requestOptions.data}');

      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid credentials');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid request data');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection and try again.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(
          'Request timeout. The server is taking too long to respond. Please try again.',
        );
      } else if (e.type == DioExceptionType.unknown) {
        // Handle unknown DioException types, often caused by network issues
        final errorMessage =
            e.error?.toString() ?? e.message ?? 'Unknown network error';
        if (errorMessage.contains(
              'Connection closed before full header was received',
            ) ||
            errorMessage.contains('HttpException') ||
            errorMessage.contains('SocketException') ||
            errorMessage.contains('NetworkException')) {
          throw NetworkException(
            'Connection failed. Please check your internet connection and try again.',
          );
        } else {
          throw NetworkException('Network error: $errorMessage');
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'Unable to connect to the server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Request timeout. Please try again.');
      } else {
        throw ServerException(
          e.message ?? 'Network error occurred',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AuthResponse> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: AuthDao.registerBody(email, password, name),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          response.data,
          (json) => AuthResponse.fromJson(json),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Check if the nested data also indicates success
          if (apiResponse.data!.success) {
            return apiResponse.data!;
          } else {
            throw ServerException(
              'Registration failed: ${apiResponse.message}',
              response.statusCode,
            );
          }
        } else {
          throw ServerException(
            apiResponse.message ?? 'Registration failed',
            response.statusCode,
          );
        }
      } else {
        throw ServerException(
          'Registration failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid registration data');
      } else if (e.response?.statusCode == 409) {
        throw AuthException('User already exists');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else {
        throw ServerException(
          e.message ?? 'Network error occurred',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await _dioClient.dio.post(ApiEndpoints.logout);
      if (response.statusCode == 204) {
        // Handle 204 No Content
        return;
      } else if (response.statusCode != 200) {
        throw ServerException(
          'Logout failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid or expired token');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else {
        throw ServerException(
          e.message ?? 'Network error occurred',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.refreshToken,
        data: AuthDao.refreshTokenBody(refreshToken),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          response.data,
          (json) => AuthResponse.fromJson(json),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Check if the nested data also indicates success
          if (apiResponse.data!.success) {
            return apiResponse.data!;
          } else {
            throw ServerException(
              'Token refresh failed: ${apiResponse.message}',
              response.statusCode,
            );
          }
        } else {
          throw ServerException(
            apiResponse.message ?? 'Token refresh failed',
            response.statusCode,
          );
        }
      } else {
        throw ServerException(
          'Token refresh failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid refresh token');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid refresh token format');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else {
        throw ServerException(
          e.message ?? 'Network error occurred',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: AuthDao.forgotPasswordBody(email),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json,
        );

        if (apiResponse.success) {
          // Password reset email sent successfully
          return;
        } else {
          throw ServerException(
            apiResponse.message ?? 'Failed to send password reset email',
            response.statusCode,
          );
        }
      } else {
        throw ServerException(
          'Password reset failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid email address');
      } else if (e.response?.statusCode == 404) {
        throw AuthException('Email not found');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else {
        throw ServerException(
          e.message ?? 'Network error occurred',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    _logger.i('🌐 AuthRemoteDataSource.changePassword() - Starting API call');
    _logger.d(
      '📝 API Input: Old password length: ${oldPassword.length}, New password length: ${newPassword.length}',
    );
    _logger.i('🔗 Endpoint: ${ApiEndpoints.changePassword}');

    try {
      _logger.i('📤 Making POST request to change password endpoint...');
      final response = await _dioClient.dio.post(
        ApiEndpoints.changePassword,
        data: AuthDao.changePasswordBody(oldPassword, newPassword),
      );

      _logger.i('📥 Response received - Status: ${response.statusCode}');
      _logger.d('📊 Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        _logger.i('✅ HTTP 200 - Processing successful response');
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json,
        );

        _logger.d('📋 API Response: ${apiResponse.toJson((data) => data)}');

        if (apiResponse.success) {
          _logger.i('🎉 Password changed successfully via API');
          return;
        } else {
          _logger.w(
            '⚠️ API returned success: false - Message: ${apiResponse.message}',
          );
          throw ServerException(
            apiResponse.message ?? 'Failed to change password',
            response.statusCode,
          );
        }
      } else {
        _logger.w('⚠️ Non-200 status code: ${response.statusCode}');
        throw ServerException(
          'Password change failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e(
        '❌ DioException during password change: ${e.type} - ${e.message}',
      );
      _logger.d('🔗 Request URL: ${e.requestOptions.uri}');
      _logger.d('📊 Response Status: ${e.response?.statusCode}');
      _logger.d('📥 Response Data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        if (e.response?.data?['error'] == 'Unauthorized') {
          _logger.e('🔒 Unauthorized: No authorization token provided');
          throw AuthException('No authorization token provided');
        } else {
          _logger.e('🔒 Unauthorized: Invalid or expired token');
          throw AuthException('Invalid or expired token');
        }
      } else if (e.response?.statusCode == 400) {
        _logger.e('❌ Bad Request: Invalid password format');
        throw ValidationException('Invalid password format');
      } else if (e.response?.statusCode == 500) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['error'] == 'CONNECTION_ERROR') {
          _logger.e('❌ Server Error: Current password is incorrect');
          throw AuthException('Current password is incorrect');
        } else {
          _logger.e(
            '❌ Server Error: ${errorData?['error'] ?? 'Unknown server error'}',
          );
          throw ServerException('Server error occurred');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        _logger.e('⏰ Connection Timeout');
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        _logger.e('⏰ Receive Timeout');
        throw NetworkException('Request timeout');
      } else {
        _logger.e('❌ Network Error: ${e.message}');
        throw ServerException(
          e.message ?? 'Network error occurred',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      _logger.e('❌ Unexpected error during password change: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.resetPassword,
        data: AuthDao.resetPasswordBody(token, newPassword),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json,
        );

        if (apiResponse.success) {
          // Password reset successfully
          return;
        } else {
          throw ServerException(
            apiResponse.message ?? 'Failed to reset password',
            response.statusCode,
          );
        }
      } else {
        throw ServerException(
          'Password reset failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid or expired reset token');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid password format');
      } else if (e.response?.statusCode == 500) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['error'] == 'CONNECTION_ERROR') {
          throw AuthException('Invalid or expired reset token');
        } else {
          throw ServerException('Server error occurred');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else {
        throw ServerException(
          e.message ?? 'Network error occurred',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<User> updateUser(User user) async {
    try {
      _logger.i('🌐 Updating user: ${user.email}');

      final response = await _dioClient.dio.put(
        '${ApiEndpoints.updateUser}/${user.id}',
        data: {
          'email': user.email,
          'name': user.name,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'phone': user.phone,
          'company': user.company,
          'department': user.department,
          'location': user.location,
          'position': user.position,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (json) => json,
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Create updated user from response
          final updatedUser = User.fromJwtData(
            id: user.id,
            email: apiResponse.data!['email'] ?? user.email,
            role: user.role,
            phone: apiResponse.data!['phone'] ?? user.phone,
            tenantId: user.tenantId,
            roleId: user.roleId,
            apiKey: user.apiKey,
            apiSecret: user.apiSecret,
            emailVerified:
                apiResponse.data!['emailVerified'] ?? user.emailVerified,
            firstName: apiResponse.data!['firstName'] ?? user.firstName,
            lastName: apiResponse.data!['lastName'] ?? user.lastName,
            company: apiResponse.data!['company'] ?? user.company,
            department: apiResponse.data!['department'] ?? user.department,
            location: apiResponse.data!['location'] ?? user.location,
            position: apiResponse.data!['position'] ?? user.position,
            sessionId: user.sessionId,
            isAnonymous: user.isAnonymous,
          );

          _logger.i('✅ User updated successfully');
          return updatedUser;
        } else {
          throw ServerException(
            apiResponse.message ?? 'Failed to update user',
            response.statusCode,
          );
        }
      } else {
        throw ServerException(
          'User update failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ DioException during user update: ${e.type} - ${e.message}');

      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid or expired token');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid user data');
      } else if (e.response?.statusCode == 404) {
        throw AuthException('User not found');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Request timeout');
      } else {
        throw ServerException(
          e.message ?? 'Network error occurred',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      _logger.e('❌ Unexpected error during user update: $e');
      throw ServerException('Unexpected error: $e');
    }
  }
}
