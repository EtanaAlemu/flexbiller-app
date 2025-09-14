class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';
  static const String resetPassword = '/auth/reset-password';
  static const String updateUser = '/users';

  // Subscriptions endpoints
  static const String recentSubscriptions = '/analytics/recent-subscriptions';
  static const String getSubscriptionById = '/subscriptions';
  static const String getSubscriptionsForAccount = '/subscriptions/account';
  static const String subscriptionCustomFields = '/subscriptions';
  static const String blockSubscription = '/subscriptions'; // Base for blocking
  static const String createSubscriptionWithAddOns =
      '/subscriptions/createSubscriptionWithAddOns';
  static const String getSubscriptionAuditLogsWithHistory =
      '/subscriptions'; // Base for audit logs
  static const String updateSubscriptionBcd =
      '/subscriptions'; // Base for updating BCD

  // Tags endpoints
  static const String getAllTags = '/tags';
  static const String searchTags = '/tags/search';

  // Tag Definitions endpoints
  static const String getTagDefinitions = '/tagDefinitions';
  static const String createTagDefinition = '/tagDefinitions';
  static const String getTagDefinitionById = '/tagDefinitions';
  static const String getTagDefinitionAuditLogsWithHistory = '/tagDefinitions';
  static const String deleteTagDefinition = '/tagDefinitions';
}
