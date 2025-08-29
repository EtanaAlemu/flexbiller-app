import 'package:local_auth/local_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@injectable
class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final Logger _logger = Logger();

  BiometricAuthService(this._localAuth);

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      _logger.i('Biometric available: $isAvailable, Device supported: $isDeviceSupported');
      
      return isAvailable && isDeviceSupported;
    } catch (e) {
      _logger.e('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      _logger.i('Available biometrics: $availableBiometrics');
      return availableBiometrics;
    } catch (e) {
      _logger.e('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if device has biometric hardware
  Future<bool> hasBiometricHardware() async {
    try {
      final hasHardware = await _localAuth.canCheckBiometrics;
      _logger.i('Has biometric hardware: $hasHardware');
      return hasHardware;
    } catch (e) {
      _logger.e('Error checking biometric hardware: $e');
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to access FlexBiller',
  }) async {
    try {
      _logger.i('Starting biometric authentication...');
      
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      _logger.i('Biometric authentication result: $result');
      return result;
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enabled in settings
  Future<bool> isBiometricEnabled() async {
    try {
      final isAvailable = await isBiometricAvailable();
      final hasHardware = await hasBiometricHardware();
      
      return isAvailable && hasHardware;
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
