import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';
import 'secure_storage_service.dart';
import 'biometric_auth_service.dart';
import 'authentication_state_service.dart';
import 'user_session_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

@injectable
class AuthGuardService {
  final SecureStorageService _secureStorage;
  final BiometricAuthService _biometricAuth;
  final AuthenticationStateService _authStateService;
  final UserSessionService _userSessionService;
  final AuthRepository _authRepository;
  final Logger _logger;

  AuthGuardService(
    this._secureStorage,
    this._biometricAuth,
    this._authStateService,
    this._userSessionService,
    this._authRepository,
    this._logger,
  );

  /// Check if user needs biometric authentication
  Future<bool> needsBiometricAuth() async {
    try {
      // Use the authentication state service to check if user is authenticated
      final isAuthenticated = await _authStateService.isUserAuthenticated();
      if (!isAuthenticated) {
        _logger.i('User not authenticated, biometric auth not needed');
        return false;
      }

      // Get the authentication method
      final method = await _authStateService.getAuthenticationMethod();
      if (method == 'email_password') {
        _logger.i(
          'User authenticated via email/password, biometric auth not needed',
        );
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
      // Use the authentication state service to check if user is authenticated
      final isAuthenticated = await _authStateService.isUserAuthenticated();
      if (!isAuthenticated) {
        _logger.i('User not authenticated, access denied');
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

      _logger.i(
        'Access granted - user authenticated and biometric auth passed if required',
      );
      return true;
    } catch (e) {
      _logger.e('Error checking app access: $e');
      return false;
    }
  }

  /// Get authentication status for display
  Future<Map<String, dynamic>> getAuthStatus() async {
    try {
      final authInfo = await _authStateService.getAuthenticationInfo();
      final isBiometricEnabled = await _biometricAuth.isBiometricEnabled();
      final needsBiometric = await needsBiometricAuth();

      return {
        'hasValidToken': authInfo['hasValidToken'],
        'isBiometricEnabled': isBiometricEnabled,
        'needsBiometric': needsBiometric,
        'canAccessApp': await canAccessApp(),
        'tokenInfo': await _secureStorage.getTokenInfo(),
        'biometricTypes': await _biometricAuth.getAvailableBiometricNames(),
        'authInfo': authInfo,
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

      // Use the authentication state service to check if user is authenticated
      final isAuthenticated = await _authStateService.isUserAuthenticated();
      _logger.i(
        'Authentication state check: isAuthenticated = $isAuthenticated',
      );

      if (!isAuthenticated) {
        _logger.i('User not authenticated, proceeding to email/password login');
        return {
          'success': false,
          'method': 'none',
          'message': 'Please login with email and password.',
          'requiresLogin': true,
        };
      }

      // Get the authentication method
      final method = await _authStateService.getAuthenticationMethod();
      _logger.i('Authentication method: $method');

      if (method == null) {
        _logger.i('No authentication method - user should be logged out');
        return {
          'success': false,
          'method': 'none',
          'message': 'Session expired. Please login again.',
          'requiresLogin': true,
        };
      }

      if (method == 'email_password') {
        _logger.i(
          'User authenticated via email/password - granting direct access',
        );

        // Ensure user context is restored for already authenticated users
        await _restoreUserContextForAuthenticatedUser();

        return {
          'success': true,
          'method': 'direct_access',
          'message': 'Access granted.',
          'requiresLogin': false,
        };
      }

      // If method is 'biometric', proceed with biometric authentication
      _logger.i(
        'Biometric authentication required - proceeding with biometric check',
      );

      // Check if biometric is available and enabled
      final isBiometricEnabled = await _biometricAuth.isBiometricEnabled();
      if (!isBiometricEnabled) {
        _logger.i(
          'Biometric not available, proceeding to email/password login with pre-populated email',
        );
        return {
          'success': false,
          'method': 'fallback',
          'message':
              'Biometric authentication not available. Please login with email and password.',
          'requiresLogin': true,
          'prePopulateEmail': true, // Flag to pre-populate email in login form
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
        _logger.i(
          'Biometric authentication failed, offering fallback to email/password',
        );
        return {
          'success': false,
          'method': 'fallback',
          'message':
              'Biometric authentication failed. Please login with email and password.',
          'requiresLogin': true,
        };
      }
    } catch (e) {
      _logger.e('Error during authentication flow: $e');
      return {
        'success': false,
        'method': 'error',
        'message': 'An error occurred during authentication: $e',
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

  /// Restore user context for already authenticated users
  Future<void> _restoreUserContextForAuthenticatedUser() async {
    try {
      _logger.d('Restoring user context for authenticated user');

      // Check if user context is already set
      if (_userSessionService.hasActiveUser) {
        _logger.d(
          'User context already active: ${_userSessionService.currentUser?.email}',
        );
        return;
      }

      // Try to restore user context from stored data
      await _authRepository.restoreUserContext();

      if (_userSessionService.hasActiveUser) {
        _logger.d(
          'User context restored successfully: ${_userSessionService.currentUser?.email}',
        );
      } else {
        _logger.w('Failed to restore user context for authenticated user');
      }
    } catch (e) {
      _logger.e('Error restoring user context for authenticated user: $e');
      // Don't rethrow - this is not critical for authentication
    }
  }
}
