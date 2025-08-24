import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response.dart';
import 'package:flexbiller_app/core/services/secure_storage_service.dart';
import 'package:flexbiller_app/core/errors/exceptions.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<User> login(String email, String password) async {
    try {
      final authResponse = await _remoteDataSource.login(email, password);

      // Store tokens in secure storage
      await _secureStorage.saveAuthToken(authResponse.accessToken);
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);

      return authResponse.user.toEntity();
    } catch (e) {
      // Re-throw the exception to be handled by the BLoC
      rethrow;
    }
  }

  @override
  Future<User> register(String email, String password, String name) async {
    try {
      final authResponse = await _remoteDataSource.register(
        email,
        password,
        name,
      );

      // Store tokens in secure storage
      await _secureStorage.saveAuthToken(authResponse.accessToken);
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);

      return authResponse.user.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      // Clear tokens from secure storage
      await _secureStorage.clearAuthTokens();
      await _secureStorage.clear(); // Clear all stored data
    } catch (e) {
      // Even if logout fails, clear local tokens for security
      await _secureStorage.clearAuthTokens();
      await _secureStorage.clear();
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    // TODO: Implement get current user logic
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    // TODO: Implement authentication check
    return false;
  }

  @override
  Future<AuthResponse> refreshToken() async {
    try {
      // Get refresh token from secure storage
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }
      // Call remote data source to refresh token
      final authResponse = await _remoteDataSource.refreshToken(refreshToken);

      // Store new tokens
      await _secureStorage.saveAuthToken(authResponse.accessToken);
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _remoteDataSource.changePassword(oldPassword, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _remoteDataSource.resetPassword(token, newPassword);
    } catch (e) {
      rethrow;
    }
  }
}
