import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<User> login(String email, String password) async {
    try {
      final authResponse = await _remoteDataSource.login(email, password);
      
      // Store tokens in secure storage
      // TODO: Inject SecureStorageService and store tokens
      // await _secureStorage.write(key: AppConstants.authTokenKey, value: authResponse.accessToken);
      // await _secureStorage.write(key: AppConstants.refreshTokenKey, value: authResponse.refreshToken);
      
      return authResponse.user.toEntity();
    } catch (e) {
      // Re-throw the exception to be handled by the BLoC
      rethrow;
    }
  }

  @override
  Future<User> register(String email, String password, String name) async {
    try {
      final authResponse = await _remoteDataSource.register(email, password, name);
      
      // Store tokens in secure storage
      // TODO: Inject SecureStorageService and store tokens
      
      return authResponse.user.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      // TODO: Clear tokens from secure storage
    } catch (e) {
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
      // TODO: Get refresh token from secure storage
      final refreshToken = 'dummy_token';
      // Call remote data source to refresh token
      return await _remoteDataSource.refreshToken(refreshToken);
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
}
