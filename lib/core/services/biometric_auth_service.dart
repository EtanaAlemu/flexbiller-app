import 'package:local_auth/local_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@injectable
class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final Logger _logger = Logger();

  BiometricAuthService(this._localAuth);

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      // Check if we're on a supported platform first
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        final isAvailable = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();

        _logger.i(
          'Biometric available: $isAvailable, Device supported: $isDeviceSupported',
        );

        return isAvailable && isDeviceSupported;
      } else {
        _logger.i(
          'Biometric not supported on platform: $defaultTargetPlatform',
        );
        return false;
      }
    } on PlatformException catch (e) {
      _logger.e(
        'Platform error checking biometric availability: ${e.code} - ${e.message}',
      );
      // Handle specific platform errors
      switch (e.code) {
        case 'NotAvailable':
        case 'NotEnrolled':
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          return false;
        default:
          _logger.e('Unknown platform error: ${e.code}');
          return false;
      }
    } catch (e) {
      _logger.e('General error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        _logger.i('Available biometrics: $availableBiometrics');
        return availableBiometrics;
      } else {
        _logger.i(
          'Biometric not supported on platform: $defaultTargetPlatform',
        );
        return [];
      }
    } on PlatformException catch (e) {
      _logger.e(
        'Platform error getting available biometrics: ${e.code} - ${e.message}',
      );
      return [];
    } catch (e) {
      _logger.e('General error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if device has biometric hardware
  Future<bool> hasBiometricHardware() async {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        final hasHardware = await _localAuth.canCheckBiometrics;
        _logger.i('Has biometric hardware: $hasHardware');
        return hasHardware;
      } else {
        _logger.i(
          'Biometric hardware not supported on platform: $defaultTargetPlatform',
        );
        return false;
      }
    } on PlatformException catch (e) {
      _logger.e(
        'Platform error checking biometric hardware: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      _logger.e('General error checking biometric hardware: $e');
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to access FlexBiller',
  }) async {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        _logger.i(
          'Starting biometric authentication on $defaultTargetPlatform...',
        );

        final result = await _localAuth.authenticate(
          localizedReason: reason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
            useErrorDialogs: true,
          ),
        );

        _logger.i('Biometric authentication result: $result');
        return result;
      } else {
        _logger.i(
          'Biometric authentication not supported on platform: $defaultTargetPlatform',
        );
        return false;
      }
    } on PlatformException catch (e) {
      _logger.e(
        'Platform error during biometric authentication: ${e.code} - ${e.message}',
      );
      // Handle specific platform errors
      switch (e.code) {
        case 'NotAvailable':
          _logger.w('Biometric authentication not available on this device');
          break;
        case 'NotEnrolled':
          _logger.w('No biometrics enrolled on this device');
          break;
        case 'LockedOut':
          _logger.w('Biometric authentication temporarily locked out');
          break;
        case 'PermanentlyLockedOut':
          _logger.w('Biometric authentication permanently locked out');
          break;
        case 'UserCancel':
          _logger.i('User cancelled biometric authentication');
          break;
        default:
          _logger.e('Unknown platform error: ${e.code}');
      }
      return false;
    } catch (e) {
      _logger.e('General error during biometric authentication: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enabled in settings
  Future<bool> isBiometricEnabled() async {
    try {
      // Check if we're on a supported platform
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        final isAvailable = await isBiometricAvailable();
        final hasHardware = await hasBiometricHardware();

        return isAvailable && hasHardware;
      } else {
        _logger.i(
          'Biometric not supported on this platform: $defaultTargetPlatform',
        );
        return false;
      }
    } catch (e) {
      _logger.e('Error checking if biometric is enabled: $e');
      return false;
    }
  }

  /// Get biometric type name for display
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.weak:
        return 'Weak Biometric';
      case BiometricType.strong:
        return 'Strong Biometric';
      default:
        return 'Biometric';
    }
  }

  /// Get all available biometric types as a list of names
  Future<List<String>> getAvailableBiometricNames() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.map((type) => getBiometricTypeName(type)).toList();
  }
}
