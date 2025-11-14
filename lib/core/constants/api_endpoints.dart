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

  // Analytics endpoints
  static const String dashboardKPIs = '/analytics/dashboard-kpis';
  static String subscriptionTrends(int year) =>
      '/analytics/subscription-trends?year=$year';
  static String paymentStatusOverview(int year) =>
      '/analytics/payment-status-overview?year=$year';

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

  // Plans endpoints
  static const String plans = '/plans';

  // Payments endpoints
  static const String payments = '/payments';

  // Invoices endpoints
  static const String invoices = '/invoices';
  static String getAccountInvoices(String accountId) =>
      '/invoices/$accountId/account';
  static String getInvoiceById(String invoiceId) => '/invoices/$invoiceId';
  static String getInvoiceAuditLogsWithHistory(String invoiceId) =>
      '/invoices/$invoiceId/auditLogsWithHistory';
  static String adjustInvoiceItem(String invoiceId) => '/invoices/$invoiceId';

  // Bundles endpoints
  static const String bundles = '/bundles';
  static String getBundleById(String bundleId) => '/bundles/$bundleId';
  static String getBundlesForAccount(String accountId) =>
      '/bundles?accountId=$accountId';
}
