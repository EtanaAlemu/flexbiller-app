import '../config/build_config.dart';

class AppConstants {
  // API Configuration
  static String get baseUrl => '${BuildConfig.baseUrl}/api';
  static int get connectionTimeout =>
      BuildConfig.connectionTimeout.inMilliseconds;
  static int get receiveTimeout => 10000; // 10 seconds for receive timeout

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Database
  static const String databaseName = 'flexbiller.db';
  static const int databaseVersion = 1;

  // App Info
  static const String appName = 'FlexBiller';
  static const String appVersion = '1.0.0';
}
