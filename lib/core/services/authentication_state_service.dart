import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'secure_storage_service.dart';

@injectable
class AuthenticationStateService {
  final SecureStorageService _secureStorage;
  final Logger _logger;

  AuthenticationStateService(this._secureStorage, this._logger);

  // Cache management
  void _invalidateAuthCache() {
    // No cache to invalidate
  }

  /// Check if user is currently authenticated
  Future<bool> isUserAuthenticated() async {
    try {
      // Always check fresh for authentication state (don't use cache for critical auth checks)
      _logger.d('DEBUG: Checking authentication state (fresh check)');

      // Check if we have valid tokens
      final hasValidToken = await _secureStorage.hasValidToken();
      if (!hasValidToken) {
        _logger.d('DEBUG: User not authenticated - no valid tokens');
        return false;
      }

      // Check if user should stay logged in based on Remember Me preference
      final shouldStayLoggedIn = await _secureStorage.shouldStayLoggedIn();
      _logger.d('DEBUG: shouldStayLoggedIn result: $shouldStayLoggedIn');

      if (!shouldStayLoggedIn) {
        // Fallback: If we have valid tokens but fresh login check failed,
        // still consider user authenticated for current session
        _logger.d(
          'DEBUG: Fresh login check failed, but user has valid tokens - allowing authentication for current session',
        );
        return true;
      }

      _logger.d('DEBUG: User is authenticated');
      return true;
    } catch (e) {
      _logger.e('DEBUG: Error checking authentication state: $e');
      return false;
    }
  }

  /// Get authentication method (email_password, biometric, or null if not authenticated)
  Future<String?> getAuthenticationMethod() async {
    try {
      if (!await isUserAuthenticated()) {
        return null;
      }

      // Check if this is a fresh login (within current session)
      final isFreshLogin = await _secureStorage.isFreshLogin();
      if (isFreshLogin) {
        return 'email_password';
      }

      // If not fresh login but authenticated, check Remember Me preference
      final rememberMe = await _secureStorage.getRememberMe();
      if (rememberMe) {
        // User has Remember Me enabled, require biometric or password
        return 'biometric';
      } else {
        // No Remember Me and fresh login expired - user should be logged out
        return null;
      }
    } catch (e) {
      _logger.e('DEBUG: Error getting authentication method: $e');
      return null;
    }
  }

  /// Clear authentication state (logout)
  Future<void> clearAuthenticationState() async {
    try {
      await _secureStorage.clearAuthTokens();
      _invalidateAuthCache(); // Clear cached authentication state
      _logger.d('DEBUG: Authentication state cleared');
    } catch (e) {
      _logger.e('DEBUG: Error clearing authentication state: $e');
    }
  }

  /// Invalidate authentication cache (useful after login)
  void invalidateCache() {
    _invalidateAuthCache();
  }

  /// Get authentication info for debugging
  Future<Map<String, dynamic>> getAuthenticationInfo() async {
    try {
      final isAuthenticated = await isUserAuthenticated();
      final method = await getAuthenticationMethod();
      final rememberMe = await _secureStorage.getRememberMe();
      final hasValidToken = await _secureStorage.hasValidToken();
      final isFreshLogin = await _secureStorage.isFreshLogin();

      return {
        'isAuthenticated': isAuthenticated,
        'method': method,
        'rememberMe': rememberMe,
        'hasValidToken': hasValidToken,
        'isFreshLogin': isFreshLogin,
      };
    } catch (e) {
      _logger.e('DEBUG: Error getting authentication info: $e');
      return {
        'isAuthenticated': false,
        'method': null,
        'rememberMe': false,
        'hasValidToken': false,
        'isFreshLogin': false,
        'error': e.toString(),
      };
    }
  }
}
