import 'package:injectable/injectable.dart';
import '../../domain/entities/account_audit_log.dart';
import '../../domain/repositories/account_audit_logs_repository.dart';
import '../datasources/remote/account_audit_logs_remote_data_source.dart';

@Injectable(as: AccountAuditLogsRepository)
class AccountAuditLogsRepositoryImpl implements AccountAuditLogsRepository {
  final AccountAuditLogsRemoteDataSource _remoteDataSource;

  AccountAuditLogsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountAuditLog>> getAccountAuditLogs(String accountId) async {
    try {
      final logModels = await _remoteDataSource.getAccountAuditLogs(accountId);
      return logModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountAuditLog> getAccountAuditLog(String accountId, String logId) async {
    try {
      final logModel = await _remoteDataSource.getAccountAuditLog(accountId, logId);
      return logModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> getAuditLogsByAction(String accountId, String action) async {
    try {
      final logModels = await _remoteDataSource.getAuditLogsByAction(accountId, action);
      return logModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> getAuditLogsByEntityType(String accountId, String entityType) async {
    try {
      final logModels = await _remoteDataSource.getAuditLogsByEntityType(accountId, entityType);
      return logModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> getAuditLogsByUser(String accountId, String userId) async {
    try {
      final logModels = await _remoteDataSource.getAuditLogsByUser(accountId, userId);
      return logModels.map((model) => model.toEntity()).toList();
    } catch (e) {
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
      final logModels = await _remoteDataSource.getAuditLogsByDateRange(accountId, startDate, endDate);
      return logModels.map((model) => model.toEntity()).toList();
    } catch (e) {
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
      final logModels = await _remoteDataSource.getAuditLogsWithPagination(accountId, page, pageSize);
      return logModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAuditLogStatistics(String accountId) async {
    try {
      return await _remoteDataSource.getAuditLogStatistics(accountId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountAuditLog>> searchAuditLogs(String accountId, String searchTerm) async {
    try {
      final logModels = await _remoteDataSource.searchAuditLogs(accountId, searchTerm);
      return logModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
