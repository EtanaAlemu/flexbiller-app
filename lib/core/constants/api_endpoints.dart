class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';
  static const String resetPassword = '/auth/reset-password';

  // Subscriptions endpoints
  static const String recentSubscriptions =
      '/api/analytics/recent-subscriptions';
  static const String getSubscriptionById = '/api/subscriptions';
  static const String getSubscriptionsForAccount = '/api/subscriptions/account';
  static const String subscriptionCustomFields = '/api/subscriptions';

  // Tags endpoints
  static const String getAllTags = '/api/tags';
  static const String searchTags = '/api/tags/search';

  // Tag Definitions endpoints
  static const String getTagDefinitions = '/api/tagDefinitions';
  static const String createTagDefinition = '/api/tagDefinitions';
  static const String getTagDefinitionById = '/api/tagDefinitions';
  static const String getTagDefinitionAuditLogsWithHistory = '/api/tagDefinitions';
  static const String deleteTagDefinition = '/api/tagDefinitions';
}
