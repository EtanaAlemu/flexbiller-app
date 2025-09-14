import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import 'package:logger/logger.dart';

@injectable
class SecureStorageService {
  final FlutterSecureStorage _storage;
  final Logger _logger;

  // Cache for frequently accessed data
  String? _cachedAuthToken;
  String? _cachedRefreshToken;
  bool? _cachedTokenValidity;
  DateTime? _lastTokenValidation;
  static const Duration _cacheValidityDuration = Duration(seconds: 30);

  SecureStorageService(this._storage, this._logger);

  // Cache management methods
  void _invalidateCache() {
    _cachedAuthToken = null;
    _cachedRefreshToken = null;
    _cachedTokenValidity = null;
    _lastTokenValidation = null;
  }

  bool _isCacheValid() {
    if (_lastTokenValidation == null) return false;
    return DateTime.now().difference(_lastTokenValidation!) <
        _cacheValidityDuration;
  }

  // Write data to secure storage
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      // No need for delays or verification - secure storage is reliable
    } catch (e) {
      _logger.e(
        'DEBUG: Error writing to secure storage - Key: $key, Error: $e',
      );
      rethrow;
    }
  }

  // Read data from secure storage
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete data from secure storage
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Clear all data
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  // Get all keys
  Future<List<String>> getAllKeys() async {
    return await _storage.readAll().then((map) => map.keys.toList());
  }

  // Auth token specific methods
  Future<void> saveAuthToken(String token) async {
    try {
      await write(AppConstants.authTokenKey, token);
      _cachedAuthToken = token;
      _invalidateCache(); // Invalidate cache when tokens change
      _logger.d('DEBUG: Access token saved successfully');
    } catch (e) {
      _logger.e('DEBUG: Error saving access token: $e');
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      // Return cached token if available and cache is valid
      if (_cachedAuthToken != null && _isCacheValid()) {
        return _cachedAuthToken;
      }

      final token = await read(AppConstants.authTokenKey);
      _cachedAuthToken = token;
      _logger.d(
        'DEBUG: Retrieved access token: ${token != null ? 'YES' : 'NO'}',
      );
      return token;
    } catch (e) {
      _logger.e('DEBUG: Error retrieving access token: $e');
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await write(AppConstants.refreshTokenKey, token);
      _cachedRefreshToken = token;
      _invalidateCache(); // Invalidate cache when tokens change
      _logger.d('DEBUG: Refresh token saved successfully');
    } catch (e) {
      _logger.e('DEBUG: Error saving refresh token: $e');
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      // Return cached token if available and cache is valid
      if (_cachedRefreshToken != null && _isCacheValid()) {
        return _cachedRefreshToken;
      }

      final token = await read(AppConstants.refreshTokenKey);
      _cachedRefreshToken = token;
      _logger.d(
        'DEBUG: Retrieved refresh token: ${token != null ? 'YES' : 'NO'}',
      );
      return token;
    } catch (e) {
      _logger.e('DEBUG: Error retrieving refresh token: $e');
      return null;
    }
  }

  Future<void> clearAuthTokens() async {
    await delete(AppConstants.authTokenKey);
    await delete(AppConstants.refreshTokenKey);
    await delete(AppConstants.tokenExpirationKey);
    await delete('fresh_login_timestamp'); // Clear fresh login flag
    await delete('remember_me'); // Clear Remember Me preference
    _invalidateCache(); // Clear all cached data
  }

  // Clear fresh login flag
  Future<void> clearFreshLoginFlag() async {
    try {
      await delete('fresh_login_timestamp');
      _logger.d('DEBUG: Fresh login flag cleared');
    } catch (e) {
      _logger.e('DEBUG: Error clearing fresh login flag: $e');
    }
  }

  // Clear fresh login flag when session becomes stale
  Future<void> markSessionStale() async {
    try {
      await clearFreshLoginFlag();
      _logger.d('DEBUG: Session marked as stale - fresh login flag cleared');
    } catch (e) {
      _logger.e('DEBUG: Error marking session as stale: $e');
    }
  }

  // Token expiration methods
  Future<void> saveTokenExpiration(int expiresIn) async {
    try {
      // Calculate expiration timestamp (current time + expires_in seconds)
      final expirationTimestamp =
          DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
      await write(
        AppConstants.tokenExpirationKey,
        expirationTimestamp.toString(),
      );
      _logger.d('DEBUG: Token expiration saved successfully');
    } catch (e) {
      _logger.e('DEBUG: Error saving token expiration: $e');
      rethrow;
    }
  }

  // Save token expiration using actual DateTime
  Future<void> saveTokenExpirationDateTime(DateTime expirationTime) async {
    try {
      await write(
        AppConstants.tokenExpirationKey,
        expirationTime.millisecondsSinceEpoch.toString(),
      );
      _logger.d('DEBUG: Token expiration DateTime saved successfully');
    } catch (e) {
      _logger.e('DEBUG: Error saving token expiration DateTime: $e');
      rethrow;
    }
  }

  Future<DateTime?> getTokenExpiration() async {
    final timestamp = await read(AppConstants.tokenExpirationKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    }
    return null;
  }

  Future<bool> isTokenExpired() async {
    final expiration = await getTokenExpiration();
    if (expiration == null) {
      // If no expiration, clear fresh login flag and consider expired
      await clearFreshLoginFlag();
      return true;
    }

    // Check if current time is past expiration (with 30 second buffer)
    final now = DateTime.now();
    final bufferTime = Duration(seconds: 30);
    final isExpired = now.isAfter(expiration.subtract(bufferTime));

    // If token is expired, clear fresh login flag
    if (isExpired) {
      await clearFreshLoginFlag();
    }

    return isExpired;
  }

  Future<bool> hasValidToken() async {
    try {
      // Always check fresh data for critical authentication checks
      // Don't rely on cache for authentication state
      _logger.d(
        'DEBUG: hasValidToken - Checking fresh token data (cache bypassed)',
      );

      final token = await getAuthToken();
      _logger.d(
        'DEBUG: hasValidToken - Token retrieved: ${token != null ? 'YES (${token.length} chars)' : 'NO'}',
      );

      if (token == null) {
        _logger.d('DEBUG: hasValidToken - No access token found');
        _cachedTokenValidity = false;
        _lastTokenValidation = DateTime.now();
        return false;
      }

      final isExpired = await isTokenExpired();
      _logger.d('DEBUG: hasValidToken - Token expired: $isExpired');

      if (isExpired) {
        _logger.d('DEBUG: hasValidToken - Token is expired');
        _cachedTokenValidity = false;
        _lastTokenValidation = DateTime.now();
        return false;
      }

      _logger.d('DEBUG: hasValidToken - Token is valid');
      _cachedTokenValidity = true;
      _lastTokenValidation = DateTime.now();
      return true;
    } catch (e) {
      _logger.e('DEBUG: hasValidToken - Error checking token validity: $e');
      _cachedTokenValidity = false;
      _lastTokenValidation = DateTime.now();
      return false;
    }
  }

  // Verify token storage immediately after saving
  Future<bool> verifyTokenStorage() async {
    try {
      final accessToken = await getAuthToken();
      final refreshToken = await getRefreshToken();
      final expiration = await getTokenExpiration();

      final hasAccess = accessToken != null && accessToken.isNotEmpty;
      final hasRefresh = refreshToken != null && refreshToken.isNotEmpty;
      final hasExpiration = expiration != null;

      _logger.d(
        'DEBUG: verifyTokenStorage - Access: $hasAccess, Refresh: $hasRefresh, Expiration: $hasExpiration',
      );

      return hasAccess && hasRefresh && hasExpiration;
    } catch (e) {
      _logger.e('DEBUG: verifyTokenStorage - Error: $e');
      return false;
    }
  }

  // Debug method to get token information
  Future<Map<String, dynamic>> getTokenInfo() async {
    final token = await getAuthToken();
    final refreshToken = await getRefreshToken();
    final expiration = await getTokenExpiration();
    final isExpired = await isTokenExpired();

    return {
      'hasAccessToken': token != null,
      'hasRefreshToken': refreshToken != null,
      'expirationTime': expiration?.toIso8601String(),
      'isExpired': isExpired,
      'currentTime': DateTime.now().toIso8601String(),
      'timeUntilExpiration': expiration != null
          ? expiration.difference(DateTime.now()).inSeconds
          : null,
    };
  }

  // Force refresh secure storage data - useful for debugging
  Future<void> forceRefresh() async {
    try {
      // Clear any potential cached data by re-reading all keys
      final allKeys = await getAllKeys();
      _logger.d('DEBUG: forceRefresh - Available keys: $allKeys');

      // Re-read auth-related keys to ensure fresh data
      final accessToken = await getAuthToken();
      final refreshToken = await getRefreshToken();
      final expiration = await getTokenExpiration();

      _logger.d(
        'DEBUG: forceRefresh - Access token: ${accessToken != null ? 'YES' : 'NO'}',
      );
      _logger.d(
        'DEBUG: forceRefresh - Refresh token: ${refreshToken != null ? 'YES' : 'NO'}',
      );
      _logger.d(
        'DEBUG: forceRefresh - Expiration: ${expiration != null ? 'YES' : 'NO'}',
      );
    } catch (e) {
      _logger.e('DEBUG: forceRefresh - Error: $e');
    }
  }

  // User data methods
  Future<void> saveUserId(String userId) async {
    await write(AppConstants.userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return await read(AppConstants.userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await write(AppConstants.userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    return await read(AppConstants.userEmailKey);
  }

  // Refresh token validation - useful after login to ensure fresh data
  Future<bool> refreshTokenValidation() async {
    try {
      // Invalidate cache to ensure fresh data
      _invalidateCache();

      final accessToken = await getAuthToken();
      final refreshToken = await getRefreshToken();
      final expiration = await getTokenExpiration();

      if (accessToken == null || refreshToken == null || expiration == null) {
        _logger.d(
          'DEBUG: refreshTokenValidation - Missing tokens or expiration',
        );
        return false;
      }

      // Check if token is expired
      final now = DateTime.now();
      final bufferTime = Duration(seconds: 30);
      final isExpired = now.isAfter(expiration.subtract(bufferTime));

      _logger.d('DEBUG: refreshTokenValidation - Token expired: $isExpired');
      return !isExpired;
    } catch (e) {
      _logger.e('DEBUG: refreshTokenValidation - Error: $e');
      return false;
    }
  }

  // Track fresh login to skip biometric authentication (valid for configured timeout)
  Future<void> markFreshLogin() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await write('fresh_login_timestamp', now.toString());
      _invalidateCache(); // Invalidate cache when fresh login is marked
      _logger.d('DEBUG: Fresh login timestamp saved: $now');
    } catch (e) {
      _logger.e('DEBUG: Error marking fresh login: $e');
    }
  }

  // Check if this is a fresh login (within configured timeout)
  Future<bool> isFreshLogin() async {
    try {
      // Always read fresh from storage (don't use cache for this critical check)
      final timestamp = await _storage.read(key: 'fresh_login_timestamp');
      if (timestamp == null) {
        _logger.d('DEBUG: Fresh login check - No timestamp found');
        return false;
      }

      final loginTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(timestamp),
      );
      final now = DateTime.now();
      final difference = now.difference(loginTime);

      // Consider it fresh if within configured timeout
      final isFresh =
          difference.inSeconds < AppConstants.freshLoginTimeoutSeconds;
      _logger.d(
        'DEBUG: Fresh login check - Login time: $loginTime, Current: $now, Difference: ${difference.inSeconds}s, Is fresh: $isFresh',
      );

      // Auto-clear the flag if it's no longer fresh
      if (!isFresh) {
        await clearFreshLoginFlag();
        _logger.d('DEBUG: Fresh login flag auto-cleared (expired)');
      }

      return isFresh;
    } catch (e) {
      _logger.e('DEBUG: Error checking fresh login: $e');
      return false;
    }
  }

  // Remember Me functionality
  Future<void> setRememberMe(bool remember) async {
    try {
      await write('remember_me', remember.toString());
      _logger.d('DEBUG: Remember Me preference saved: $remember');
    } catch (e) {
      _logger.e('DEBUG: Error saving Remember Me preference: $e');
    }
  }

  Future<bool> getRememberMe() async {
    try {
      final preference = await read('remember_me');
      final remember = preference == 'true';
      _logger.d('DEBUG: Remember Me preference retrieved: $remember');
      return remember;
    } catch (e) {
      _logger.e('DEBUG: Error retrieving Remember Me preference: $e');
      return false; // Default to false for security
    }
  }

  // Check if biometric authentication should be required
  Future<bool> shouldRequireBiometric() async {
    try {
      // Check if it's a fresh login first
      final isFreshLoginCheck = await isFreshLogin();

      // If it's a fresh login, biometric is never required
      if (isFreshLoginCheck) {
        _logger.d(
          'DEBUG: Biometric requirement check - Fresh login: true, Should require: false (just logged in)',
        );
        return false;
      }

      // If not a fresh login, check Remember Me preference
      final rememberMe = await getRememberMe();

      // Require biometric only if:
      // 1. Not a fresh login (user didn't just log in)
      // 2. AND Remember Me is checked (user wants persistent session)
      final shouldRequire = rememberMe;

      _logger.d(
        'DEBUG: Biometric requirement check - Fresh login: $isFreshLoginCheck, Remember Me: $rememberMe, Should require: $shouldRequire',
      );

      return shouldRequire;
    } catch (e) {
      _logger.e('DEBUG: Error checking biometric requirement: $e');
      return false; // Default to false for security
    }
  }

  // Check if user should stay logged in (session persistence)
  Future<bool> shouldStayLoggedIn() async {
    try {
      // For the current session, user should always stay logged in
      // Remember Me only affects session persistence across app restarts
      final isFreshLoginCheck = await isFreshLogin();
      _logger.d(
        'DEBUG: shouldStayLoggedIn - isFreshLoginCheck: $isFreshLoginCheck',
      );

      // If it's a fresh login, user should stay logged in for current session
      if (isFreshLoginCheck) {
        _logger.d(
          'DEBUG: Session persistence check - Fresh login: true, Should stay logged in: true (current session)',
        );
        return true;
      }

      // If not a fresh login, check Remember Me preference for cross-session persistence
      final rememberMe = await getRememberMe();
      _logger.d('DEBUG: shouldStayLoggedIn - rememberMe: $rememberMe');

      if (rememberMe) {
        _logger.d(
          'DEBUG: Session persistence check - Fresh login: false, Remember Me: true, Should stay logged in: true (cross-session persistence)',
        );
        return true;
      } else {
        _logger.d(
          'DEBUG: Session persistence check - Fresh login: false, Remember Me: false, Should stay logged in: false (no cross-session persistence)',
        );
        return false;
      }
    } catch (e) {
      _logger.e('DEBUG: Error checking session persistence: $e');
      return false; // Default to false for security
    }
  }
}
