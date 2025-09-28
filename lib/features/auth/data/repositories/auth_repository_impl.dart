import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_local_data_source.dart';
import '../models/auth_response.dart';
import 'package:flexbiller_app/core/services/secure_storage_service.dart';
import 'package:flexbiller_app/core/services/jwt_service.dart';
import 'package:flexbiller_app/core/services/user_session_service.dart';
import 'package:flexbiller_app/core/errors/exceptions.dart';
import 'package:flexbiller_app/core/utils/error_handler.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final JwtService _jwtService;
  final UserLocalDataSource _userLocalDataSource;
  final UserSessionService _userSessionService;
  final Logger _logger = Logger();

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._secureStorage,
    this._jwtService,
    this._userLocalDataSource,
    this._userSessionService,
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
        final dioClient = _remoteDataSource.dioClient;
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

      // Persist user to local database
      try {
        _logger.i('Persisting user to local database...');
        await _userLocalDataSource.saveUser(user);

        // Also save auth token to local database
        await _userLocalDataSource.saveAuthToken(
          user.id,
          authResponse.accessToken,
          authResponse.refreshToken,
          actualExpirationTime,
        );

        _logger.i(
          'User and auth token successfully persisted to local database',
        );
      } catch (dbError) {
        _logger.w('Failed to persist user to local database: $dbError');
        // Don't fail the login if database persistence fails
        // The user can still use the app with secure storage
      }

      // Set the current user context for multi-user support
      await _userSessionService.setCurrentUser(user);
      _logger.i('User context set successfully: ${user.email}');

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
      } else if (e is DioException) {
        _logger.e(
          'Dio Exception - Type: ${e.type}, Status: ${e.response?.statusCode}, Message: ${e.message}',
        );
      } else {
        _logger.e('Unexpected Exception Type: ${e.runtimeType} - Message: $e');
      }

      // Convert technical errors to user-friendly exceptions
      if (e is DioException) {
        final userFriendlyMessage =
            ErrorHandler.convertDioExceptionToUserMessage(e, context: 'login');
        throw ServerException(userFriendlyMessage, e.response?.statusCode);
      } else if (e is ServerException) {
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(
          e.message,
          context: 'login',
        );
        throw ServerException(userFriendlyMessage, e.statusCode);
      } else if (e is NetworkException) {
        // NetworkException already has user-friendly messages, just rethrow
        rethrow;
      } else if (e is AuthException) {
        // Don't modify AuthException messages as they might be business logic specific
        rethrow;
      } else {
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(
          e,
          context: 'login',
        );
        throw ServerException(userFriendlyMessage);
      }
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

      // Persist user to local database
      try {
        _logger.i('Persisting user to local database after registration...');
        await _userLocalDataSource.saveUser(user);

        // Also save auth token to local database
        final expirationTime = DateTime.now().add(
          Duration(seconds: authResponse.expiresIn),
        );
        await _userLocalDataSource.saveAuthToken(
          user.id,
          authResponse.accessToken,
          authResponse.refreshToken,
          expirationTime,
        );

        _logger.i(
          'User and auth token successfully persisted to local database after registration',
        );
      } catch (dbError) {
        _logger.w(
          'Failed to persist user to local database after registration: $dbError',
        );
        // Don't fail the registration if database persistence fails
        // The user can still use the app with secure storage
      }

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

      // Clear user data from local database
      try {
        await _userLocalDataSource.clearAllData();
        _logger.i('User data cleared from local database');
      } catch (dbError) {
        _logger.w('Failed to clear user data from local database: $dbError');
        // Don't fail logout if database clearing fails
      }

      // Clear current user context
      await _userSessionService.clearCurrentUser();
      _logger.i('User context cleared successfully');
    } catch (e) {
      // Even if logout fails, clear local tokens for security
      await _secureStorage.clearAuthTokens();
      await _secureStorage.clear();

      // Try to clear database data as well
      try {
        await _userLocalDataSource.clearAllData();
      } catch (dbError) {
        _logger.w(
          'Failed to clear user data from local database during error handling: $dbError',
        );
      }

      // Clear current user context even if logout failed
      await _userSessionService.clearCurrentUser();
      _logger.i('User context cleared successfully (after error)');

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
      final userId = jwtToken.sub ?? '';

      // Try to get user from local database first
      try {
        final localUser = await _userLocalDataSource.getUserById(userId);
        if (localUser != null) {
          _logger.d('User retrieved from local database: ${localUser.email}');

          // Update user data if needed (e.g., if JWT has newer information)
          final updatedUser = localUser.copyWith(
            sessionId: jwtToken.sessionId ?? localUser.sessionId,
            updatedAt: DateTime.now(),
          );

          // Save updated user to database
          await _userLocalDataSource.updateUser(updatedUser);

          return updatedUser;
        }
      } catch (dbError) {
        _logger.w('Failed to retrieve user from local database: $dbError');
        // Continue with JWT-based user creation
      }

      // If not in database, create user entity with JWT data using safe access
      final user = User.fromJwtData(
        id: userId,
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

      // Try to save user to local database for future use
      try {
        await _userLocalDataSource.saveUser(user);
        _logger.d('User saved to local database for future use');
      } catch (dbError) {
        _logger.w('Failed to save user to local database: $dbError');
        // Don't fail if database save fails
      }

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

      // Update auth token in local database if user exists
      try {
        final jwtToken = _jwtService.decodeToken(authResponse.accessToken);
        final userId = jwtToken.sub ?? '';

        if (userId.isNotEmpty) {
          final expirationTime = DateTime.now().add(
            Duration(seconds: authResponse.expiresIn),
          );
          await _userLocalDataSource.updateAuthToken(
            userId,
            authResponse.accessToken,
            authResponse.refreshToken,
            expirationTime,
          );
          _logger.d('Auth token updated in local database for user: $userId');
        }
      } catch (dbError) {
        _logger.w('Failed to update auth token in local database: $dbError');
        // Don't fail token refresh if database update fails
      }

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

  @override
  Future<User> updateUser(User user) async {
    try {
      _logger.i('Updating user: ${user.email}');

      // Update user in local database first (local-first approach)
      await _userLocalDataSource.updateUser(user);
      _logger.i('User updated in local database');

      // Update user on remote server
      final updatedUser = await _remoteDataSource.updateUser(user);
      _logger.i('User updated on remote server');

      // Update local database with the response from server
      await _userLocalDataSource.updateUser(updatedUser);
      _logger.i('Local database updated with server response');

      return updatedUser;
    } catch (e) {
      _logger.e('Error updating user: $e');
      rethrow;
    }
  }

  /// Restore user context from stored user ID
  /// This is called during app initialization to restore the last active user
  Future<void> restoreUserContext() async {
    try {
      _logger.d('Restoring user context from stored user ID');
      print('DEBUG: restoreUserContext called');

      // Restore the user session context
      await _userSessionService.restoreCurrentUserContext();

      // If we have a current user ID, load the full user object
      if (_userSessionService.hasActiveUser) {
        final userId = _userSessionService.currentUserId!;
        final user = await _userLocalDataSource.getUserById(userId);

        if (user != null) {
          await _userSessionService.setCurrentUser(user);
          _logger.d('User context restored successfully: ${user.email}');
        } else {
          _logger.w(
            'User with ID $userId not found in local database, clearing context',
          );
          await _userSessionService.clearCurrentUser();
        }
      } else {
        _logger.d('No stored user context found');
      }
    } catch (e) {
      _logger.e('Error restoring user context: $e');
      // Don't rethrow - this is not critical for app startup
    }
  }
}
