import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/dao/account_audit_log_dao.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../models/account_audit_log_model.dart';

abstract class AccountAuditLogsLocalDataSource {
  Future<void> cacheAuditLogs(List<AccountAuditLogModel> auditLogs);
  Future<void> cacheAuditLog(AccountAuditLogModel auditLog);
  Future<List<AccountAuditLogModel>> getCachedAuditLogs(String accountId);
  Future<AccountAuditLogModel?> getCachedAuditLog(String auditLogId);
  Future<List<AccountAuditLogModel>> getCachedAuditLogsByAction(
    String accountId,
    String action,
  );
  Future<List<AccountAuditLogModel>> getCachedAuditLogsByEntityType(
    String accountId,
    String entityType,
  );
  Future<List<AccountAuditLogModel>> getCachedAuditLogsByUser(
    String accountId,
    String userId,
  );
  Future<List<AccountAuditLogModel>> getCachedAuditLogsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<AccountAuditLogModel>> getCachedAuditLogsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );
  Future<List<AccountAuditLogModel>> searchCachedAuditLogs(
    String accountId,
    String searchTerm,
  );
  Future<int> getCachedAuditLogsCount(String accountId);
  Future<void> updateCachedAuditLog(AccountAuditLogModel auditLog);
  Future<void> deleteCachedAuditLog(String auditLogId);
  Future<void> deleteCachedAuditLogsByAccount(String accountId);
  Future<void> clearAllCachedAuditLogs();
  Future<bool> hasCachedAuditLogs(String accountId);
}

@Injectable(as: AccountAuditLogsLocalDataSource)
class AccountAuditLogsLocalDataSourceImpl
    implements AccountAuditLogsLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger = Logger();

  AccountAuditLogsLocalDataSourceImpl(
    this._databaseService,
    this._userSessionService,
  );

  @override
  Future<void> cacheAuditLogs(List<AccountAuditLogModel> auditLogs) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping audit logs caching',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      await AccountAuditLogDao.insertMultipleAuditLogs(db, auditLogs);
      _logger.d('Cached ${auditLogs.length} audit logs successfully');
    } catch (e) {
      _logger.e('Error caching audit logs: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheAuditLog(AccountAuditLogModel auditLog) async {
    try {
      final db = await _databaseService.database;
      await AccountAuditLogDao.insertAuditLog(db, auditLog);
      _logger.d('Cached audit log: ${auditLog.id} successfully');
    } catch (e) {
      _logger.e('Error caching audit log: ${auditLog.id} - $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getCachedAuditLogs(
    String accountId,
  ) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning empty audit logs list',
            );
            return [];
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return [];
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      final auditLogs = await AccountAuditLogDao.getAuditLogsByAccount(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved ${auditLogs.length} cached audit logs for account: $accountId',
      );
      return auditLogs;
    } catch (e) {
      _logger.w(
        'Error retrieving cached audit logs for account: $accountId - $e',
      );
      // Return empty list if there's an error (e.g., table doesn't exist yet)
      return [];
    }
  }

  @override
  Future<AccountAuditLogModel?> getCachedAuditLog(String auditLogId) async {
    try {
      final db = await _databaseService.database;
      final auditLog = await AccountAuditLogDao.getAuditLogById(db, auditLogId);

      if (auditLog != null) {
        _logger.d('Retrieved cached audit log: $auditLogId');
        return auditLog;
      }

      _logger.d('No cached audit log found for: $auditLogId');
      return null;
    } catch (e) {
      _logger.w('Error retrieving cached audit log: $auditLogId - $e');
      return null;
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getCachedAuditLogsByAction(
    String accountId,
    String action,
  ) async {
    try {
      final db = await _databaseService.database;
      final auditLogs = await AccountAuditLogDao.getAuditLogsByAction(
        db,
        accountId,
        action,
      );
      _logger.d(
        'Retrieved ${auditLogs.length} cached audit logs by action: $action for account: $accountId',
      );
      return auditLogs;
    } catch (e) {
      _logger.w(
        'Error retrieving cached audit logs by action for account: $accountId, action: $action - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getCachedAuditLogsByEntityType(
    String accountId,
    String entityType,
  ) async {
    try {
      final db = await _databaseService.database;
      final auditLogs = await AccountAuditLogDao.getAuditLogsByEntityType(
        db,
        accountId,
        entityType,
      );
      _logger.d(
        'Retrieved ${auditLogs.length} cached audit logs by entity type: $entityType for account: $accountId',
      );
      return auditLogs;
    } catch (e) {
      _logger.w(
        'Error retrieving cached audit logs by entity type for account: $accountId, entityType: $entityType - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getCachedAuditLogsByUser(
    String accountId,
    String userId,
  ) async {
    try {
      final db = await _databaseService.database;
      final auditLogs = await AccountAuditLogDao.getAuditLogsByUser(
        db,
        accountId,
        userId,
      );
      _logger.d(
        'Retrieved ${auditLogs.length} cached audit logs by user: $userId for account: $accountId',
      );
      return auditLogs;
    } catch (e) {
      _logger.w(
        'Error retrieving cached audit logs by user for account: $accountId, userId: $userId - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getCachedAuditLogsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _databaseService.database;
      final auditLogs = await AccountAuditLogDao.getAuditLogsByDateRange(
        db,
        accountId,
        startDate,
        endDate,
      );
      _logger.d(
        'Retrieved ${auditLogs.length} cached audit logs by date range for account: $accountId',
      );
      return auditLogs;
    } catch (e) {
      _logger.w(
        'Error retrieving cached audit logs by date range for account: $accountId - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getCachedAuditLogsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final db = await _databaseService.database;
      final offset = page * pageSize;
      final auditLogs = await AccountAuditLogDao.getAuditLogsWithPagination(
        db,
        accountId,
        offset,
        pageSize,
      );
      _logger.d(
        'Retrieved ${auditLogs.length} cached audit logs with pagination for account: $accountId (page: $page, size: $pageSize)',
      );
      return auditLogs;
    } catch (e) {
      _logger.w(
        'Error retrieving cached audit logs with pagination for account: $accountId - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountAuditLogModel>> searchCachedAuditLogs(
    String accountId,
    String searchTerm,
  ) async {
    try {
      final db = await _databaseService.database;
      final auditLogs = await AccountAuditLogDao.searchAuditLogs(
        db,
        accountId,
        searchTerm,
      );
      _logger.d(
        'Retrieved ${auditLogs.length} cached audit logs by search term: $searchTerm for account: $accountId',
      );
      return auditLogs;
    } catch (e) {
      _logger.w(
        'Error searching cached audit logs for account: $accountId, searchTerm: $searchTerm - $e',
      );
      return [];
    }
  }

  @override
  Future<int> getCachedAuditLogsCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountAuditLogDao.getAuditLogsCount(db, accountId);
      _logger.d(
        'Retrieved cached audit logs count: $count for account: $accountId',
      );
      return count;
    } catch (e) {
      _logger.w(
        'Error retrieving cached audit logs count for account: $accountId - $e',
      );
      return 0;
    }
  }

  @override
  Future<void> updateCachedAuditLog(AccountAuditLogModel auditLog) async {
    try {
      final db = await _databaseService.database;
      await AccountAuditLogDao.updateAuditLog(db, auditLog);
      _logger.d('Updated cached audit log: ${auditLog.id} successfully');
    } catch (e) {
      _logger.e('Error updating cached audit log: ${auditLog.id} - $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedAuditLog(String auditLogId) async {
    try {
      final db = await _databaseService.database;
      await AccountAuditLogDao.deleteAuditLog(db, auditLogId);
      _logger.d('Deleted cached audit log: $auditLogId successfully');
    } catch (e) {
      _logger.e('Error deleting cached audit log: $auditLogId - $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedAuditLogsByAccount(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountAuditLogDao.deleteAuditLogsByAccount(db, accountId);
      _logger.d(
        'Deleted cached audit logs for account: $accountId successfully',
      );
    } catch (e) {
      _logger.e(
        'Error deleting cached audit logs for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedAuditLogs() async {
    try {
      final db = await _databaseService.database;
      await AccountAuditLogDao.clearAllAuditLogs(db);
      _logger.d('Cleared all cached audit logs successfully');
    } catch (e) {
      _logger.e('Error clearing cached audit logs: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedAuditLogs(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountAuditLogDao.getAuditLogsCount(db, accountId);
      return count > 0;
    } catch (e) {
      _logger.e(
        'Error checking if cached audit logs exist for account: $accountId - $e',
      );
      // If table doesn't exist, return false instead of throwing
      if (e.toString().contains('no such table: account_audit_logs')) {
        _logger.w(
          'Account audit logs table does not exist yet, returning false',
        );
        return false;
      }
      rethrow;
    }
  }
}
