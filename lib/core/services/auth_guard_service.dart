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
}
