import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_audit_log_model.dart';

abstract class AccountAuditLogsRemoteDataSource {
  Future<List<AccountAuditLogModel>> getAccountAuditLogs(String accountId);
  Future<AccountAuditLogModel> getAccountAuditLog(String accountId, String logId);
  Future<List<AccountAuditLogModel>> getAuditLogsByAction(String accountId, String action);
  Future<List<AccountAuditLogModel>> getAuditLogsByEntityType(String accountId, String entityType);
  Future<List<AccountAuditLogModel>> getAuditLogsByUser(String accountId, String userId);
  Future<List<AccountAuditLogModel>> getAuditLogsByDateRange(String accountId, DateTime startDate, DateTime endDate);
  Future<List<AccountAuditLogModel>> getAuditLogsWithPagination(String accountId, int page, int pageSize);
  Future<Map<String, dynamic>> getAuditLogStatistics(String accountId);
  Future<List<AccountAuditLogModel>> searchAuditLogs(String accountId, String searchTerm);
}

@Injectable(as: AccountAuditLogsRemoteDataSource)
class AccountAuditLogsRemoteDataSourceImpl implements AccountAuditLogsRemoteDataSource {
  final Dio _dio;

  AccountAuditLogsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AccountAuditLogModel>> getAccountAuditLogs(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/auditLogs');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> logsData = responseData['data'] as List<dynamic>;
          return logsData
              .map((item) => AccountAuditLogModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account audit logs',
          );
        }
      } else {
        throw ServerException('Failed to fetch account audit logs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account audit logs');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account audit logs',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account audit logs');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account audit logs: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<AccountAuditLogModel> getAccountAuditLog(String accountId, String logId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/auditLogs/$logId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return AccountAuditLogModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch account audit log',
          );
        }
      } else {
        throw ServerException('Failed to fetch account audit log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to account audit log');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access account audit log',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Account audit log not found');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching account audit log');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch account audit log: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getAuditLogsByAction(String accountId, String action) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/auditLogs/action',
        queryParameters: {'action': action},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> logsData = responseData['data'] as List<dynamic>;
          return logsData
              .map((item) => AccountAuditLogModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch audit logs by action',
          );
        }
      } else {
        throw ServerException('Failed to fetch audit logs by action: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch audit logs by action');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch audit logs by action',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching audit logs by action');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch audit logs by action: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getAuditLogsByEntityType(String accountId, String entityType) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/auditLogs/entityType',
        queryParameters: {'entityType': entityType},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> logsData = responseData['data'] as List<dynamic>;
          return logsData
              .map((item) => AccountAuditLogModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch audit logs by entity type',
          );
        }
      } else {
        throw ServerException('Failed to fetch audit logs by entity type: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch audit logs by entity type');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch audit logs by entity type',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching audit logs by entity type');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch audit logs by entity type: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getAuditLogsByUser(String accountId, String userId) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/auditLogs/user',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> logsData = responseData['data'] as List<dynamic>;
          return logsData
              .map((item) => AccountAuditLogModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch audit logs by user',
          );
        }
      } else {
        throw ServerException('Failed to fetch audit logs by user: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch audit logs by user');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch audit logs by user',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching audit logs by user');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch audit logs by user: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getAuditLogsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/auditLogs/dateRange',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> logsData = responseData['data'] as List<dynamic>;
          return logsData
              .map((item) => AccountAuditLogModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch audit logs by date range',
          );
        }
      } else {
        throw ServerException('Failed to fetch audit logs by date range: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch audit logs by date range');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch audit logs by date range',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching audit logs by date range');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch audit logs by date range: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountAuditLogModel>> getAuditLogsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/auditLogs/pagination',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> logsData = responseData['data'] as List<dynamic>;
          return logsData
              .map((item) => AccountAuditLogModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch audit logs with pagination',
          );
        }
      } else {
        throw ServerException('Failed to fetch audit logs with pagination: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch audit logs with pagination');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch audit logs with pagination',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching audit logs with pagination');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch audit logs with pagination: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAuditLogStatistics(String accountId) async {
    try {
      final response = await _dio.get('/accounts/$accountId/auditLogs/statistics');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch audit log statistics',
          );
        }
      } else {
        throw ServerException('Failed to fetch audit log statistics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to fetch audit log statistics');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to fetch audit log statistics',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while fetching audit log statistics');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to fetch audit log statistics: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<AccountAuditLogModel>> searchAuditLogs(String accountId, String searchTerm) async {
    try {
      final response = await _dio.get(
        '/accounts/$accountId/auditLogs/search',
        queryParameters: {'searchTerm': searchTerm},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> logsData = responseData['data'] as List<dynamic>;
          return logsData
              .map((item) => AccountAuditLogModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to search audit logs',
          );
        }
      } else {
        throw ServerException('Failed to search audit logs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to search audit logs');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to search audit logs',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout while searching audit logs');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Failed to search audit logs: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
