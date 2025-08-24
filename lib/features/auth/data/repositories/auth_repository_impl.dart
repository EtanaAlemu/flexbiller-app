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
  Future<User> login(String email, String password) async {
    try {
      _logger.i('Starting login process for email: $email');

      final authResponse = await _remoteDataSource.login(email, password);
      _logger.i('Login successful, received access token');

      // Store tokens in secure storage
      await _secureStorage.saveAuthToken(authResponse.accessToken);
      await _secureStorage.saveRefreshToken(authResponse.refreshToken);
      _logger.i('Tokens stored in secure storage');

      // Decode JWT token to extract user information
      _logger.i('Decoding JWT token...');
      final jwtToken = _jwtService.decodeToken(authResponse.accessToken);
      _logger.i('JWT token decoded successfully');

      // Check if user role is allowed for mobile app
      if (jwtToken.appMetadata.role == 'EASYBILL_ADMIN') {
        _logger.w(
          'EASYBILL_ADMIN user attempted to login to mobile app: ${jwtToken.email}',
        );
        // Clear any stored tokens
        await _secureStorage.clearAuthTokens();
        throw AuthException(
          'EASYBILL_ADMIN users must use the web version. Please login at the web portal.',
        );
      }

      // Log extracted information
      _logger.i('User ID: ${jwtToken.sub}');
      _logger.i('User Email: ${jwtToken.email}');
      _logger.i('User Role: ${jwtToken.appMetadata.role}');
      _logger.i('Tenant ID: ${jwtToken.userMetadata.tenantId}');
      _logger.i('Company: ${jwtToken.userMetadata.metadata.company}');
      _logger.i('Department: ${jwtToken.userMetadata.metadata.department}');
      _logger.i(
        'API Key Available: ${jwtToken.userMetadata.apiKey.isNotEmpty}',
      );
      _logger.i(
        'Phone Verification: ${jwtToken.appMetadata.providers.contains('phone')}',
      );

      // Create user entity with JWT data
      final user = User.fromJwtData(
        id: jwtToken.sub,
        email: jwtToken.email,
        role: jwtToken.appMetadata.role,
        phone: jwtToken.phone,
        tenantId: jwtToken.userMetadata.tenantId,
        roleId: jwtToken.userMetadata.roleId,
        apiKey: jwtToken.userMetadata.apiKey,
        apiSecret: jwtToken.userMetadata.apiSecret,
        emailVerified: jwtToken.userMetadata.emailVerified,
        firstName: jwtToken.userMetadata.firstName,
        lastName: jwtToken.userMetadata.lastName,
        company: jwtToken.userMetadata.metadata.company,
        department: jwtToken.userMetadata.metadata.department,
        location: jwtToken.userMetadata.metadata.location,
        position: jwtToken.userMetadata.metadata.position,
        sessionId: jwtToken.sessionId,
        isAnonymous: jwtToken.isAnonymous,
      );

      _logger.i('User entity created successfully: ${user.displayName}');
      return user;
    } catch (e) {
      _logger.e('Login failed: $e');
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

      // Decode JWT token to extract user information
      final jwtToken = _jwtService.decodeToken(authResponse.accessToken);

      // Check if user role is allowed for mobile app
      if (jwtToken.appMetadata.role == 'EASYBILL_ADMIN') {
        _logger.w(
          'EASYBILL_ADMIN user attempted to register on mobile app: ${jwtToken.email}',
        );
        // Clear any stored tokens
        await _secureStorage.clearAuthTokens();
        throw AuthException(
          'EASYBILL_ADMIN users must use the web version. Please register at the web portal.',
        );
      }

      // Create user entity with JWT data
      final user = User.fromJwtData(
        id: jwtToken.sub,
        email: jwtToken.email,
        role: jwtToken.appMetadata.role,
        phone: jwtToken.phone,
        tenantId: jwtToken.userMetadata.tenantId,
        roleId: jwtToken.userMetadata.roleId,
        apiKey: jwtToken.userMetadata.apiKey,
        apiSecret: jwtToken.userMetadata.apiSecret,
        emailVerified: jwtToken.userMetadata.emailVerified,
        firstName: jwtToken.userMetadata.firstName,
        lastName: jwtToken.userMetadata.lastName,
        company: jwtToken.userMetadata.metadata.company,
        department: jwtToken.userMetadata.metadata.department,
        location: jwtToken.userMetadata.metadata.location,
        position: jwtToken.userMetadata.metadata.position,
        sessionId: jwtToken.sessionId,
        isAnonymous: jwtToken.isAnonymous,
      );

      return user;
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
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) return null;

      // Check if token is expired
      if (_jwtService.isTokenExpired(token)) {
        await _secureStorage.clearAuthTokens();
        return null;
      }

      // Decode JWT token to get user information
      final jwtToken = _jwtService.decodeToken(token);

      // Create user entity with JWT data
      final user = User.fromJwtData(
        id: jwtToken.sub,
        email: jwtToken.email,
        role: jwtToken.appMetadata.role,
        phone: jwtToken.phone,
        tenantId: jwtToken.userMetadata.tenantId,
        roleId: jwtToken.userMetadata.roleId,
        apiKey: jwtToken.userMetadata.apiKey,
        apiSecret: jwtToken.userMetadata.apiSecret,
        emailVerified: jwtToken.userMetadata.emailVerified,
        firstName: jwtToken.userMetadata.firstName,
        lastName: jwtToken.userMetadata.lastName,
        company: jwtToken.userMetadata.metadata.company,
        department: jwtToken.userMetadata.metadata.department,
        location: jwtToken.userMetadata.metadata.location,
        position: jwtToken.userMetadata.metadata.position,
        sessionId: jwtToken.sessionId,
        isAnonymous: jwtToken.isAnonymous,
      );

      return user;
    } catch (e) {
      // If there's an error decoding the token, clear it and return null
      await _secureStorage.clearAuthTokens();
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null) return false;

      // Check if token is expired
      return !_jwtService.isTokenExpired(token);
    } catch (e) {
      return false;
    }
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
