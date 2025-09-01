import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/account_audit_log.dart';
import '../../domain/repositories/account_audit_logs_repository.dart';
import '../datasources/local/account_audit_logs_local_data_source.dart';
import '../datasources/remote/account_audit_logs_remote_data_source.dart';

@LazySingleton(as: AccountAuditLogsRepository)
class AccountAuditLogsRepositoryImpl implements AccountAuditLogsRepository {
  final AccountAuditLogsRemoteDataSource _remoteDataSource;
  final AccountAuditLogsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger();

  // Stream controllers for reactive UI updates
  final StreamController<List<AccountAuditLog>> _auditLogsStreamController =
      StreamController<List<AccountAuditLog>>.broadcast();
  final StreamController<List<AccountAuditLog>>
  _auditLogsPaginatedStreamController =
      StreamController<List<AccountAuditLog>>.broadcast();

  AccountAuditLogsRepositoryImpl({
    required AccountAuditLogsRemoteDataSource remoteDataSource,
    required AccountAuditLogsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Stream<List<AccountAuditLog>> get auditLogsStream =>
      _auditLogsStreamController.stream;

  @override
  Stream<List<AccountAuditLog>> get auditLogsPaginatedStream =>
      _auditLogsPaginatedStreamController.stream;

  @override
  Future<List<AccountAuditLog>> getAccountAuditLogs(String accountId) async {
    try {
      // First, try to get cached data for immediate response
      final cachedAuditLogs = await _localDataSource.getCachedAuditLogs(
        accountId,
      );

      if (cachedAuditLogs.isNotEmpty) {
        _logger.d(
          'Returning ${cachedAuditLogs.length} cached audit logs for account: $accountId',
        );

        // Convert to entities and add to stream for UI update
        final entities = cachedAuditLogs
            .map((model) => model.toEntity())
            .toList();
        _auditLogsStreamController.add(entities);

        // Start background sync if online
        _syncAuditLogsInBackground(accountId);

        return entities;
      }

      // If no cache, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached data, fetching from remote for account: $accountId',
        );
        final remoteAuditLogs = await _remoteDataSource.getAccountAuditLogs(
          accountId,
        );

        // Cache the remote data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        // Convert to entities, add to stream and return
        final entities = remoteAuditLogs
            .map((model) => model.toEntity())
            .toList();
        _auditLogsStreamController.add(entities);
        return entities;
      } else {
        _logger.w('No cached data and offline for account: $accountId');
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e('Server error getting audit logs for account: $accountId - $e');
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error getting audit logs for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error getting audit logs for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountAuditLog> getAccountAuditLog(
    String accountId,
    String logId,
  ) async {
    try {
      // First, try to get cached data for immediate response
      final cachedAuditLog = await _localDataSource.getCachedAuditLog(logId);

      if (cachedAuditLog != null) {
        _logger.d('Returning cached audit log: $logId for account: $accountId');
        return cachedAuditLog.toEntity();
      }

      // If no cache, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached data, fetching from remote for account: $accountId, logId: $logId',
        );
        final remoteAuditLog = await _remoteDataSource.getAccountAuditLog(
          accountId,
          logId,
        );

        // Cache the remote data
        await _localDataSource.cacheAuditLog(remoteAuditLog);

        return remoteAuditLog.toEntity();
      } else {
        _logger.w(
          'No cached data and offline for account: $accountId, logId: $logId',
        );
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e(
        'Server error getting audit log: $logId for account: $accountId - $e',
      );
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error getting audit log: $logId for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error getting audit log: $logId for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> getAuditLogsByAction(
    String accountId,
    String action,
  ) async {
    try {
      // First, try to get cached data for immediate response
      final cachedAuditLogs = await _localDataSource.getCachedAuditLogsByAction(
        accountId,
        action,
      );

      if (cachedAuditLogs.isNotEmpty) {
        _logger.d(
          'Returning ${cachedAuditLogs.length} cached audit logs by action: $action for account: $accountId',
        );
        return cachedAuditLogs.map((model) => model.toEntity()).toList();
      }

      // If no cache, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached data by action, fetching from remote for account: $accountId, action: $action',
        );
        final remoteAuditLogs = await _remoteDataSource.getAuditLogsByAction(
          accountId,
          action,
        );

        // Cache the remote data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        return remoteAuditLogs.map((model) => model.toEntity()).toList();
      } else {
        _logger.w(
          'No cached data by action and offline for account: $accountId, action: $action',
        );
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e(
        'Server error getting audit logs by action for account: $accountId - $e',
      );
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error getting audit logs by action for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error getting audit logs by action for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> getAuditLogsByEntityType(
    String accountId,
    String entityType,
  ) async {
    try {
      // First, try to get cached data for immediate response
      final cachedAuditLogs = await _localDataSource
          .getCachedAuditLogsByEntityType(accountId, entityType);

      if (cachedAuditLogs.isNotEmpty) {
        _logger.d(
          'Returning ${cachedAuditLogs.length} cached audit logs by entity type: $entityType for account: $accountId',
        );
        return cachedAuditLogs.map((model) => model.toEntity()).toList();
      }

      // If no cache, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached data by entity type, fetching from remote for account: $accountId, entityType: $entityType',
        );
        final remoteAuditLogs = await _remoteDataSource
            .getAuditLogsByEntityType(accountId, entityType);

        // Cache the remote data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        return remoteAuditLogs.map((model) => model.toEntity()).toList();
      } else {
        _logger.w(
          'No cached data by entity type and offline for account: $accountId, entityType: $entityType',
        );
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e(
        'Server error getting audit logs by entity type for account: $accountId - $e',
      );
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error getting audit logs by entity type for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error getting audit logs by entity type for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> getAuditLogsByUser(
    String accountId,
    String userId,
  ) async {
    try {
      // First, try to get cached data for immediate response
      final cachedAuditLogs = await _localDataSource.getCachedAuditLogsByUser(
        accountId,
        userId,
      );

      if (cachedAuditLogs.isNotEmpty) {
        _logger.d(
          'Returning ${cachedAuditLogs.length} cached audit logs by user: $userId for account: $accountId',
        );
        return cachedAuditLogs.map((model) => model.toEntity()).toList();
      }

      // If no cache, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached data by user, fetching from remote for account: $accountId, userId: $userId',
        );
        final remoteAuditLogs = await _remoteDataSource.getAuditLogsByUser(
          accountId,
          userId,
        );

        // Cache the remote data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        return remoteAuditLogs.map((model) => model.toEntity()).toList();
      } else {
        _logger.w(
          'No cached data by user and offline for account: $accountId, userId: $userId',
        );
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e(
        'Server error getting audit logs by user for account: $accountId - $e',
      );
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error getting audit logs by user for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error getting audit logs by user for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> getAuditLogsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // First, try to get cached data for immediate response
      final cachedAuditLogs = await _localDataSource
          .getCachedAuditLogsByDateRange(accountId, startDate, endDate);

      if (cachedAuditLogs.isNotEmpty) {
        _logger.d(
          'Returning ${cachedAuditLogs.length} cached audit logs by date range for account: $accountId',
        );
        return cachedAuditLogs.map((model) => model.toEntity()).toList();
      }

      // If no cache, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached data by date range, fetching from remote for account: $accountId',
        );
        final remoteAuditLogs = await _remoteDataSource.getAuditLogsByDateRange(
          accountId,
          startDate,
          endDate,
        );

        // Cache the remote data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        return remoteAuditLogs.map((model) => model.toEntity()).toList();
      } else {
        _logger.w(
          'No cached data by date range and offline for account: $accountId',
        );
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e(
        'Server error getting audit logs by date range for account: $accountId - $e',
      );
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error getting audit logs by date range for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error getting audit logs by date range for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> getAuditLogsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      // First, try to get cached data for immediate response
      final cachedAuditLogs = await _localDataSource
          .getCachedAuditLogsWithPagination(accountId, page, pageSize);

      if (cachedAuditLogs.isNotEmpty) {
        _logger.d(
          'Returning ${cachedAuditLogs.length} cached paginated audit logs for account: $accountId (page: $page)',
        );

        // Convert to entities and add to stream for UI update
        final entities = cachedAuditLogs
            .map((model) => model.toEntity())
            .toList();
        _auditLogsPaginatedStreamController.add(entities);

        // Start background sync if online
        _syncAuditLogsPaginatedInBackground(accountId, page, pageSize);

        return entities;
      }

      // If no cache, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached paginated data, fetching from remote for account: $accountId (page: $page)',
        );
        final remoteAuditLogs = await _remoteDataSource
            .getAuditLogsWithPagination(accountId, page, pageSize);

        // Cache the remote data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        // Convert to entities, add to stream and return
        final entities = remoteAuditLogs
            .map((model) => model.toEntity())
            .toList();
        _auditLogsPaginatedStreamController.add(entities);
        return entities;
      } else {
        _logger.w(
          'No cached paginated data and offline for account: $accountId (page: $page)',
        );
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e(
        'Server error getting paginated audit logs for account: $accountId - $e',
      );
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error getting paginated audit logs for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error getting paginated audit logs for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAuditLogStatistics(String accountId) async {
    try {
      if (await _networkInfo.isConnected) {
        _logger.d(
          'Fetching audit log statistics from remote for account: $accountId',
        );
        return await _remoteDataSource.getAuditLogStatistics(accountId);
      } else {
        _logger.w('Offline and no cached statistics for account: $accountId');
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e(
        'Server error getting audit log statistics for account: $accountId - $e',
      );
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error getting audit log statistics for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error getting audit log statistics for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> searchAuditLogs(
    String accountId,
    String searchTerm,
  ) async {
    try {
      // First, try to get cached data for immediate response
      final cachedAuditLogs = await _localDataSource.searchCachedAuditLogs(
        accountId,
        searchTerm,
      );

      if (cachedAuditLogs.isNotEmpty) {
        _logger.d(
          'Returning ${cachedAuditLogs.length} cached search results for account: $accountId, searchTerm: $searchTerm',
        );
        return cachedAuditLogs.map((model) => model.toEntity()).toList();
      }

      // If no cache, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached search results, fetching from remote for account: $accountId, searchTerm: $searchTerm',
        );
        final remoteAuditLogs = await _remoteDataSource.searchAuditLogs(
          accountId,
          searchTerm,
        );

        // Cache the remote data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        return remoteAuditLogs.map((model) => model.toEntity()).toList();
      } else {
        _logger.w(
          'No cached search results and offline for account: $accountId, searchTerm: $searchTerm',
        );
        throw Exception('No data available offline');
      }
    } on ServerException catch (e) {
      _logger.e(
        'Server error searching audit logs for account: $accountId - $e',
      );
      rethrow;
    } on NetworkException catch (e) {
      _logger.e(
        'Network error searching audit logs for account: $accountId - $e',
      );
      rethrow;
    } catch (e) {
      _logger.e(
        'Unexpected error searching audit logs for account: $accountId - $e',
      );
      rethrow;
    }
  }

  // Background synchronization methods
  Future<void> _syncAuditLogsInBackground(String accountId) async {
    try {
      if (await _networkInfo.isConnected) {
        _logger.d(
          'Starting background sync for audit logs, account: $accountId',
        );

        final remoteAuditLogs = await _remoteDataSource.getAccountAuditLogs(
          accountId,
        );

        // Update local cache with fresh data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        // Convert to entities and add fresh data to stream for UI update
        final entities = remoteAuditLogs
            .map((model) => model.toEntity())
            .toList();
        _auditLogsStreamController.add(entities);

        _logger.d(
          'Background sync completed for audit logs, account: $accountId',
        );
      }
    } catch (e) {
      _logger.w(
        'Background sync failed for audit logs, account: $accountId - $e',
      );
      // Don't throw - background sync failures shouldn't affect the main flow
    }
  }

  Future<void> _syncAuditLogsPaginatedInBackground(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      if (await _networkInfo.isConnected) {
        _logger.d(
          'Starting background sync for paginated audit logs, account: $accountId, page: $page',
        );

        final remoteAuditLogs = await _remoteDataSource
            .getAuditLogsWithPagination(accountId, page, pageSize);

        // Update local cache with fresh data
        await _localDataSource.cacheAuditLogs(remoteAuditLogs);

        // Convert to entities and add fresh data to stream for UI update
        final entities = remoteAuditLogs
            .map((model) => model.toEntity())
            .toList();
        _auditLogsPaginatedStreamController.add(entities);

        _logger.d(
          'Background sync completed for paginated audit logs, account: $accountId, page: $page',
        );
      }
    } catch (e) {
      _logger.w(
        'Background sync failed for paginated audit logs, account: $accountId, page: $page - $e',
      );
      // Don't throw - background sync failures shouldn't affect the main flow
    }
  }

  // Cleanup method to dispose of stream controllers
  void dispose() {
    _auditLogsStreamController.close();
    _auditLogsPaginatedStreamController.close();
  }
}
