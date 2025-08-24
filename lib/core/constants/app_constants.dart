class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://flexbiller.aumtech.org/api';
  static const int connectionTimeout = 5000;
  static const int receiveTimeout = 3000;
  
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

