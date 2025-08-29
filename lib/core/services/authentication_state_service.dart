import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'secure_storage_service.dart';

@injectable
class AuthenticationStateService {
  final SecureStorageService _secureStorage;
  final Logger _logger;

  AuthenticationStateService(this._secureStorage, this._logger);

  /// Check if user is currently authenticated
  Future<bool> isUserAuthenticated() async {
    try {
      // Check if we have valid tokens
      final hasValidToken = await _secureStorage.hasValidToken();
      if (!hasValidToken) {
        _logger.d('DEBUG: User not authenticated - no valid tokens');
        return false;
      }

      // Check if user should stay logged in based on Remember Me preference
      final shouldStayLoggedIn = await _secureStorage.shouldStayLoggedIn();
      if (!shouldStayLoggedIn) {
        _logger.d('DEBUG: User not authenticated - session not persistent');
        return false;
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

      // Check if it's a fresh login (within 5 minutes)
      final isFreshLogin = await _secureStorage.isFreshLogin();
      if (isFreshLogin) {
        return 'email_password';
      }

      // If not fresh login but authenticated, it must be biometric
      return 'biometric';
    } catch (e) {
      _logger.e('DEBUG: Error getting authentication method: $e');
      return null;
    }
  }

  /// Clear authentication state (logout)
  Future<void> clearAuthenticationState() async {
    try {
      await _secureStorage.clearAuthTokens();
      _logger.d('DEBUG: Authentication state cleared');
    } catch (e) {
      _logger.e('DEBUG: Error clearing authentication state: $e');
    }
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
