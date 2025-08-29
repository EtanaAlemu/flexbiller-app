import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'secure_storage_service.dart';
import 'biometric_auth_service.dart';

@injectable
class AuthGuardService {
  final SecureStorageService _secureStorage;
  final BiometricAuthService _biometricAuth;
  final Logger _logger = Logger();

  AuthGuardService(this._secureStorage, this._biometricAuth);

  /// Check if user needs biometric authentication
  Future<bool> needsBiometricAuth() async {
    try {
      // Check if user has valid tokens
      final hasValidToken = await _secureStorage.hasValidToken();
      if (!hasValidToken) {
        _logger.i('No valid tokens found, biometric auth not needed');
        return false;
      }

      // Check if biometric is available and enabled
      final isBiometricEnabled = await _biometricAuth.isBiometricEnabled();
      if (!isBiometricEnabled) {
        _logger.i('Biometric not available or enabled');
        return false;
      }

      _logger.i('Biometric authentication required');
      return true;
    } catch (e) {
      _logger.e('Error checking if biometric auth is needed: $e');
      return false;
    }
  }

  /// Authenticate user with biometrics if required
  Future<bool> authenticateIfRequired() async {
    try {
      final needsAuth = await needsBiometricAuth();
      if (!needsAuth) {
        _logger.i('Biometric authentication not required');
        return true;
      }

      _logger.i('Starting biometric authentication...');
      final result = await _biometricAuth.authenticate(
        reason: 'Please authenticate to access FlexBiller',
      );

      if (result) {
        _logger.i('Biometric authentication successful');
      } else {
        _logger.w('Biometric authentication failed or cancelled');
      }

      return result;
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Check if user can access the app (has valid tokens and passed biometric auth if required)
  Future<bool> canAccessApp() async {
    try {
      // First check if tokens are valid
      final hasValidToken = await _secureStorage.hasValidToken();
      if (!hasValidToken) {
        _logger.i('No valid tokens, access denied');
        return false;
      }

      // If biometric is required, authenticate
      final needsBiometric = await needsBiometricAuth();
      if (needsBiometric) {
        final biometricResult = await _biometricAuth.authenticate(
          reason: 'Please authenticate to access FlexBiller',
        );
        
        if (!biometricResult) {
          _logger.w('Biometric authentication failed, access denied');
          return false;
        }
      }

      _logger.i('Access granted - valid tokens and biometric auth passed');
      return true;
    } catch (e) {
      _logger.e('Error checking app access: $e');
      return false;
    }
  }

  /// Get authentication status for display
  Future<Map<String, dynamic>> getAuthStatus() async {
    try {
      final hasValidToken = await _secureStorage.hasValidToken();
      final isBiometricEnabled = await _biometricAuth.isBiometricEnabled();
      final needsBiometric = await needsBiometricAuth();
      
      return {
        'hasValidToken': hasValidToken,
        'isBiometricEnabled': isBiometricEnabled,
        'needsBiometric': needsBiometric,
        'canAccessApp': await canAccessApp(),
        'tokenInfo': await _secureStorage.getTokenInfo(),
        'biometricTypes': await _biometricAuth.getAvailableBiometricNames(),
      };
    } catch (e) {
      _logger.e('Error getting auth status: $e');
      return {
        'hasValidToken': false,
        'isBiometricEnabled': false,
        'needsBiometric': false,
        'canAccessApp': false,
        'error': e.toString(),
      };
    }
  }

  /// Complete authentication flow with biometric + fallback
  /// Returns: {'success': bool, 'method': 'biometric'|'fallback'|'none', 'message': string}
  Future<Map<String, dynamic>> authenticateWithFallback() async {
    try {
      _logger.i('Starting authentication flow with fallback...');
      
      // Check if we have valid tokens
      final hasValidToken = await _secureStorage.hasValidToken();
      _logger.i('Token validation check: hasValidToken = $hasValidToken');
      
      if (!hasValidToken) {
        // Get detailed token info for debugging
        final tokenInfo = await _secureStorage.getTokenInfo();
        _logger.i('Token info for debugging: $tokenInfo');
        
        _logger.i('No valid tokens, proceeding to email/password login');
        return {
          'success': false,
          'method': 'none',
          'message': 'No valid tokens found. Please login with email and password.',
          'requiresLogin': true,
        };
      }

      // Check if biometric is available and enabled
      final isBiometricEnabled = await _biometricAuth.isBiometricEnabled();
      if (!isBiometricEnabled) {
        _logger.i('Biometric not available, proceeding to email/password login');
        return {
          'success': false,
          'method': 'none',
          'message': 'Biometric authentication not available. Please login with email and password.',
          'requiresLogin': true,
        };
      }

      // Try biometric authentication
      _logger.i('Attempting biometric authentication...');
      final biometricResult = await _biometricAuth.authenticate(
        reason: 'Please authenticate to access FlexBiller',
      );

      if (biometricResult) {
        _logger.i('Biometric authentication successful');
        return {
          'success': true,
          'method': 'biometric',
          'message': 'Biometric authentication successful!',
          'requiresLogin': false,
        };
      } else {
        _logger.i('Biometric authentication failed, offering fallback to email/password');
        return {
          'success': false,
          'method': 'fallback',
          'message': 'Biometric authentication failed. Please login with email and password.',
          'requiresLogin': true,
        };
      }
    } catch (e) {
      _logger.e('Error during authentication flow: $e');
      return {
        'success': false,
        'method': 'error',
        'message': 'Authentication error: $e',
        'requiresLogin': true,
      };
    }
  }

  /// Check if user should be redirected to login page
  Future<bool> shouldRedirectToLogin() async {
    try {
      final authResult = await authenticateWithFallback();
      return authResult['requiresLogin'] == true;
    } catch (e) {
      _logger.e('Error checking if should redirect to login: $e');
      return true; // Default to requiring login on error
    }
  }
}
