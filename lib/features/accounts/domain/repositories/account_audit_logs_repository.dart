import '../entities/account_audit_log.dart';

abstract class AccountAuditLogsRepository {
  /// Get all audit logs for a specific account
  Future<List<AccountAuditLog>> getAccountAuditLogs(String accountId);

  /// Get a specific audit log by ID
  Future<AccountAuditLog> getAccountAuditLog(String accountId, String logId);

  /// Get audit logs by action type
  Future<List<AccountAuditLog>> getAuditLogsByAction(String accountId, String action);

  /// Get audit logs by entity type
  Future<List<AccountAuditLog>> getAuditLogsByEntityType(String accountId, String entityType);

  /// Get audit logs by user
  Future<List<AccountAuditLog>> getAuditLogsByUser(String accountId, String userId);

  /// Get audit logs by date range
  Future<List<AccountAuditLog>> getAuditLogsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get audit logs with pagination
  Future<List<AccountAuditLog>> getAuditLogsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );

  /// Get audit log statistics for an account
  Future<Map<String, dynamic>> getAuditLogStatistics(String accountId);

  /// Search audit logs by description or other fields
  Future<List<AccountAuditLog>> searchAuditLogs(String accountId, String searchTerm);
}
