import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/auth_response.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String name);
  Future<void> logout();
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> forgotPassword(String email);
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
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
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid credentials');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid request data');
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
  Future<AuthResponse> register(String email, String password, String name) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
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
        throw ValidationException('User already exists');
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
      await dio.post('/auth/logout');
    } on DioException catch (e) {
      // Logout can fail silently, just log the error
      print('Logout error: ${e.message}');
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh-token',
        data: {
          'refreshToken': refreshToken,
        },
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
      final response = await dio.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
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
}
