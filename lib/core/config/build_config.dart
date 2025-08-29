import 'package:flutter/foundation.dart';

enum BuildEnvironment { development, staging, production }

class BuildConfig {
  static const String _devEmail = 'mbahar651@gmail.com';
  static const String _devPassword = 'Bhr@1234';

  // Staging credentials (if needed)
  static const String _stagingEmail = '';
  static const String _stagingPassword = '';

  // Production credentials - always empty
  static const String _prodEmail = '';
  static const String _prodPassword = '';

  static BuildEnvironment get environment {
    if (kDebugMode) {
      return BuildEnvironment.development;
    }

    // You can add more sophisticated logic here based on build flavors
    // For example, checking for specific environment variables or build configurations
    if (const String.fromEnvironment('ENVIRONMENT') == 'staging') {
      return BuildEnvironment.staging;
    }

    return BuildEnvironment.production;
  }

  static String get email {
    switch (environment) {
      case BuildEnvironment.development:
        return _devEmail;
      case BuildEnvironment.staging:
        return _stagingEmail;
      case BuildEnvironment.production:
        return _prodEmail;
    }
  }

  static String get password {
    switch (environment) {
      case BuildEnvironment.development:
        return _devPassword;
      case BuildEnvironment.staging:
        return _stagingPassword;
      case BuildEnvironment.production:
        return _prodPassword;
    }
  }

  static bool get isDevelopment => environment == BuildEnvironment.development;
  static bool get isStaging => environment == BuildEnvironment.staging;
  static bool get isProduction => environment == BuildEnvironment.production;

  // API endpoints
  static String get baseUrl {
    switch (environment) {
      case BuildEnvironment.development:
        return 'https://flexbillerapi.aumtech.org'; // Actual working API
      case BuildEnvironment.staging:
        return 'https://flexbillerapi.aumtech.org'; // Same for staging for now
      case BuildEnvironment.production:
        return 'https://flexbillerapi.aumtech.org'; // Same for production for now
    }
  }

  // Feature flags
  static bool get enableLogging => !isProduction;
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashlytics => isProduction;
  static bool get enablePerformanceMonitoring => isProduction;

  // App configuration
  static String get appName {
    switch (environment) {
      case BuildEnvironment.development:
        return 'FlexBiller Dev';
      case BuildEnvironment.staging:
        return 'FlexBiller Staging';
      case BuildEnvironment.production:
        return 'FlexBiller';
    }
  }

  // Timeouts
  static Duration get connectionTimeout {
    switch (environment) {
      case BuildEnvironment.development:
        return const Duration(seconds: 30); // Longer timeout for dev
      case BuildEnvironment.staging:
        return const Duration(seconds: 20);
      case BuildEnvironment.production:
        return const Duration(seconds: 15); // Shorter timeout for prod
    }
  }
}
