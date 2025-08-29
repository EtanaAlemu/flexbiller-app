import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String _devEmail = 'mbahar651@gmail.com';
  static const String _devPassword = 'Bhr@1234';

  // Production credentials - these should be empty or null in production
  static const String _prodEmail = '';
  static const String _prodPassword = '';

  static String get email {
    if (kDebugMode) {
      return _devEmail;
    }
    return _prodEmail;
  }

  static String get password {
    if (kDebugMode) {
      return _devPassword;
    }
    return _prodPassword;
  }

  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;

  // API endpoints can also be environment-specific
  static String get baseUrl {
    if (kDebugMode) {
      return 'https://dev-api.flexbiller.com'; // Development API
    }
    return 'https://api.flexbiller.com'; // Production API
  }

  // Other environment-specific configurations
  static bool get enableLogging => kDebugMode;
  static bool get enableAnalytics => kReleaseMode;
}

