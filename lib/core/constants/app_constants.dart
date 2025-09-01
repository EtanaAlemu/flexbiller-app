import '../config/build_config.dart';

class AppConstants {
  // API Configuration
  static String get baseUrl => '${BuildConfig.baseUrl}/api';
  static int get connectionTimeout =>
      BuildConfig.connectionTimeout.inMilliseconds;
  static int get receiveTimeout =>
      60000; // 60 seconds for receive timeout (increased from 10s)

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpirationKey = 'token_expiration';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Database
  static const String databaseName = 'flexbiller.db';
  static const int databaseVersion = 2;

  // App Info
  static const String appName = 'FlexBiller';
  static const String appVersion = '1.0.0';
}
