import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response.dart';
import 'package:flexbiller_app/core/services/secure_storage_service.dart';
import 'package:flexbiller_app/core/services/jwt_service.dart';
import 'package:flexbiller_app/core/errors/exceptions.dart';
import 'package:logger/logger.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final JwtService _jwtService;
  final Logger _logger = Logger();

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._secureStorage,
    this._jwtService,
  );

  @override
  Future<User> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      _logger.i('Starting login process for email: $email');

      // Debug: Check if we can access the remote data source
      _logger.i('Remote data source type: ${_remoteDataSource.runtimeType}');

      // Debug: Check if we can access the Dio client
      if (_remoteDataSource is AuthRemoteDataSourceImpl) {
        final dioClient =
            (_remoteDataSource as AuthRemoteDataSourceImpl).dioClient;
        _logger.i('Dio client base URL: ${dioClient.dio.options.baseUrl}');
        _logger.i(
          'Dio client connection timeout: ${dioClient.dio.options.connectTimeout}',
        );
        _logger.i(
          'Dio client receive timeout: ${dioClient.dio.options.receiveTimeout}',
        );
      }

      final authResponse = await _remoteDataSource.login(email, password);
      _logger.i('Login successful, received access token');

      // Store tokens in secure storage
      _logger.i('Saving access token...');
      await _secureStorage.saveAuthToken(authResponse.accessToken);
      _logger.i('Access token saved');

      _logger.i('Saving refresh token...');
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);
      _logger.i('Refresh token saved');

      // Decode JWT token first to get actual expiration time
      _logger.i('Decoding JWT token to get actual expiration time...');
      final jwtToken = _jwtService.decodeToken(authResponse.accessToken);
      _logger.i('JWT token decoded successfully');

      // Use JWT's actual expiration time instead of calculating from expires_in
      final actualExpirationTime = DateTime.fromMillisecondsSinceEpoch(
        jwtToken.exp! * 1000,
      );
      _logger.i('JWT expiration time: $actualExpirationTime');
      _logger.i('Current time: ${DateTime.now()}');
      _logger.i('Token valid for: ${authResponse.expiresIn} seconds');

      _logger.i('Saving actual JWT expiration time...');
      await _secureStorage.saveTokenExpirationDateTime(actualExpirationTime);
      _logger.i('Token expiration saved');

      _logger.i('All tokens and expiration time stored in secure storage');

      // Verify tokens were saved and are accessible
      final storageVerified = await _secureStorage.verifyTokenStorage();
      if (!storageVerified) {
        _logger.e('Token storage verification failed after saving');
        throw AuthException('Failed to store authentication tokens securely');
      }

      _logger.i('Token storage verification successful');

      // Mark this as a fresh login to skip biometric authentication
      await _secureStorage.markFreshLogin();
      _logger.i(
        'Fresh login marked - user will not be prompted for biometric authentication',
      );

      // Save Remember Me preference
      await _secureStorage.setRememberMe(rememberMe);
      _logger.i('Remember Me preference saved: $rememberMe');

      // Additional verification - check individual tokens
      final savedAccessToken = await _secureStorage.getAuthToken();
      final savedRefreshToken = await _secureStorage.getRefreshToken();
      final savedExpiration = await _secureStorage.getTokenExpiration();

      _logger.i(
        'Verification - Saved access token: ${savedAccessToken != null ? 'YES' : 'NO'}',
      );
      _logger.i(
        'Verification - Saved refresh token: ${savedRefreshToken != null ? 'YES' : 'NO'}',
      );
      _logger.i(
        'Verification - Saved expiration: ${savedExpiration != null ? 'YES' : 'NO'}',
      );

      // Check if user role is allowed for mobile app
      if (jwtToken.appMetadata?.role == 'EASYBILL_ADMIN') {
        _logger.w(
          'EASYBILL_ADMIN user attempted to login to mobile app: ${jwtToken.email ?? 'Unknown'}',
        );
        // Clear any stored tokens
        await _secureStorage.clearAuthTokens();
        throw AuthException(
          'EASYBILL_ADMIN users must use the web version. Please login at the web portal.',
        );
      }

      // Log extracted information with null safety
      _logger.i('User ID: ${jwtToken.sub ?? 'Unknown'}');
      _logger.i('User Email: ${jwtToken.email ?? 'Unknown'}');
      _logger.i('User Role: ${jwtToken.appMetadata?.role ?? 'Unknown'}');
      _logger.i('Tenant ID: ${jwtToken.userMetadata?.tenantId ?? 'Unknown'}');
      _logger.i(
        'Company: ${jwtToken.userMetadata?.metadata?.company ?? 'Unknown'}',
      );
      _logger.i(
        'Department: ${jwtToken.userMetadata?.metadata?.department ?? 'Unknown'}',
      );
      _logger.i(
        'API Key Available: ${(jwtToken.userMetadata?.apiKey?.isNotEmpty ?? false)}',
      );
      _logger.i(
        'Phone Verification: ${jwtToken.appMetadata?.providers?.contains('phone') ?? false}',
      );

      // Create user entity with JWT data using safe access
      final user = User.fromJwtData(
        id: jwtToken.sub ?? '',
        email: jwtToken.email ?? '',
        role: jwtToken.appMetadata?.role ?? '',
        phone: jwtToken.phone ?? '',
        tenantId: jwtToken.userMetadata?.tenantId ?? '',
        roleId: jwtToken.userMetadata?.roleId ?? '',
        apiKey: jwtToken.userMetadata?.apiKey ?? '',
        apiSecret: jwtToken.userMetadata?.apiSecret ?? '',
        emailVerified: jwtToken.userMetadata?.emailVerified ?? false,
        firstName: jwtToken.userMetadata?.firstName ?? '',
        lastName: jwtToken.userMetadata?.lastName ?? '',
        company: jwtToken.userMetadata?.metadata?.company ?? '',
        department: jwtToken.userMetadata?.metadata?.department ?? '',
        location: jwtToken.userMetadata?.metadata?.location ?? '',
        position: jwtToken.userMetadata?.metadata?.position ?? '',
        sessionId: jwtToken.sessionId ?? '',
        isAnonymous: jwtToken.isAnonymous ?? false,
      );

      _logger.i('User entity created successfully: ${user.displayName}');
      return user;
    } catch (e) {
      _logger.e('Login failed: $e');

      // Add more detailed error logging for debugging
      if (e is ServerException) {
        _logger.e(
          'Server Exception - Status: ${e.statusCode}, Message: ${e.message}',
        );
      } else if (e is NetworkException) {
        _logger.e('Network Exception - Message: ${e.message}');
      } else if (e is AuthException) {
        _logger.e('Auth Exception - Message: ${e.message}');
      } else {
        _logger.e('Unexpected Exception Type: ${e.runtimeType} - Message: $e');
      }

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

      // Store tokens and expiration time in secure storage
      await _secureStorage.saveAuthToken(authResponse.accessToken);
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);
      await _secureStorage.saveTokenExpiration(authResponse.expiresIn);

      // Decode JWT token to extract user information
      final jwtToken = _jwtService.decodeToken(authResponse.accessToken);

      // Check if user role is allowed for mobile app
      if (jwtToken.appMetadata?.role == 'EASYBILL_ADMIN') {
        _logger.w(
          'EASYBILL_ADMIN user attempted to register on mobile app: ${jwtToken.email ?? 'Unknown'}',
        );
        // Clear any stored tokens
        await _secureStorage.clearAuthTokens();
        throw AuthException(
          'EASYBILL_ADMIN users must use the web version. Please register at the web portal.',
        );
      }

      // Create user entity with JWT data using safe access
      final user = User.fromJwtData(
        id: jwtToken.sub ?? '',
        email: jwtToken.email ?? '',
        role: jwtToken.appMetadata?.role ?? '',
        phone: jwtToken.phone ?? '',
        tenantId: jwtToken.userMetadata?.tenantId ?? '',
        roleId: jwtToken.userMetadata?.roleId ?? '',
        apiKey: jwtToken.userMetadata?.apiKey ?? '',
        apiSecret: jwtToken.userMetadata?.apiSecret ?? '',
        emailVerified: jwtToken.userMetadata?.emailVerified ?? false,
        firstName: jwtToken.userMetadata?.firstName ?? '',
        lastName: jwtToken.userMetadata?.lastName ?? '',
        company: jwtToken.userMetadata?.metadata?.company ?? '',
        department: jwtToken.userMetadata?.metadata?.department ?? '',
        location: jwtToken.userMetadata?.metadata?.location ?? '',
        position: jwtToken.userMetadata?.metadata?.position ?? '',
        sessionId: jwtToken.sessionId ?? '',
        isAnonymous: jwtToken.isAnonymous ?? false,
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasValidToken();
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
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) return null;

      // Check if token is expired using secure storage
      if (await _secureStorage.isTokenExpired()) {
        await _secureStorage.clearAuthTokens();
        return null;
      }

      // Decode JWT token to get user information
      final jwtToken = _jwtService.decodeToken(token);

      // Create user entity with JWT data using safe access
      final user = User.fromJwtData(
        id: jwtToken.sub ?? '',
        email: jwtToken.email ?? '',
        role: jwtToken.appMetadata?.role ?? '',
        phone: jwtToken.phone ?? '',
        tenantId: jwtToken.userMetadata?.tenantId ?? '',
        roleId: jwtToken.userMetadata?.roleId ?? '',
        apiKey: jwtToken.userMetadata?.apiKey ?? '',
        apiSecret: jwtToken.userMetadata?.apiSecret ?? '',
        emailVerified: jwtToken.userMetadata?.emailVerified ?? false,
        firstName: jwtToken.userMetadata?.firstName ?? '',
        lastName: jwtToken.userMetadata?.lastName ?? '',
        company: jwtToken.userMetadata?.metadata?.company ?? '',
        department: jwtToken.userMetadata?.metadata?.department ?? '',
        location: jwtToken.userMetadata?.metadata?.location ?? '',
        position: jwtToken.userMetadata?.metadata?.position ?? '',
        sessionId: jwtToken.sessionId ?? '',
        isAnonymous: jwtToken.isAnonymous ?? false,
      );

      return user;
    } catch (e) {
      // If there's an error decoding the token, clear it and return null
      await _secureStorage.clearAuthTokens();
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getTokenStatus() async {
    return await _secureStorage.getTokenInfo();
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

      // Store new tokens and expiration time
      await _secureStorage.saveAuthToken(authResponse.accessToken);
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);
      await _secureStorage.saveTokenExpiration(authResponse.expiresIn);

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
    _logger.i(
      '🏗️ AuthRepository.changePassword() - Starting password change operation',
    );
    _logger.d(
      '📝 Repository Input: Old password length: ${oldPassword.length}, New password length: ${newPassword.length}',
    );

    try {
      _logger.i('📡 Calling RemoteDataSource.changePassword()...');
      await _remoteDataSource.changePassword(oldPassword, newPassword);
      _logger.i('✅ AuthRepository.changePassword() completed successfully');
    } catch (e) {
      _logger.e('❌ AuthRepository.changePassword() failed: $e');
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
