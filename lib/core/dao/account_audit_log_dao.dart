import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_audit_log_model.dart';

/// Data Access Object for AccountAuditLogModel
class AccountAuditLogDao {
  static final Logger _logger = Logger();
  // Table name
  static const String tableName = 'account_audit_logs';

  // Column names
  static const String columnId = 'id';
  static const String columnAccountId = 'account_id';
  static const String columnUserId = 'user_id';
  static const String columnUserName = 'user_name';
  static const String columnAction = 'action';
  static const String columnEntityType = 'entity_type';
  static const String columnEntityId = 'entity_id';
  static const String columnOldValue = 'old_value';
  static const String columnNewValue = 'new_value';
  static const String columnDescription = 'description';
  static const String columnTimestamp = 'timestamp';
  static const String columnIpAddress = 'ip_address';
  static const String columnUserAgent = 'user_agent';
  static const String columnMetadata = 'metadata';
  static const String columnSyncStatus = 'sync_status';

  // SQL to create the table
  static String get createTableSQL =>
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnUserId TEXT NOT NULL,
      $columnUserName TEXT NOT NULL,
      $columnAction TEXT NOT NULL,
      $columnEntityType TEXT NOT NULL,
      $columnEntityId TEXT NOT NULL,
      $columnOldValue TEXT NOT NULL,
      $columnNewValue TEXT NOT NULL,
      $columnDescription TEXT NOT NULL,
      $columnTimestamp TEXT NOT NULL,
      $columnIpAddress TEXT,
      $columnUserAgent TEXT,
      $columnMetadata TEXT,
      $columnSyncStatus TEXT NOT NULL
    )
  ''';

  // Convert AccountAuditLogModel to database map
  static Map<String, dynamic> toMap(AccountAuditLogModel model) {
    return {
      columnId: model.id,
      columnAccountId: model.accountId,
      columnUserId: model.userId,
      columnUserName: model.userName,
      columnAction: model.action,
      columnEntityType: model.entityType,
      columnEntityId: model.entityId,
      columnOldValue: model.oldValue,
      columnNewValue: model.newValue,
      columnDescription: model.description,
      columnTimestamp: model.timestamp.toIso8601String(),
      columnIpAddress: model.ipAddress,
      columnUserAgent: model.userAgent,
      columnMetadata: model.metadata != null
          ? jsonEncode(model.metadata)
          : null,
      columnSyncStatus: 'synced',
    };
  }

  // Convert database map to AccountAuditLogModel
  static AccountAuditLogModel? fromMap(Map<String, dynamic> map) {
    try {
      return AccountAuditLogModel(
        id: map[columnId] as String,
        accountId: map[columnAccountId] as String,
        userId: map[columnUserId] as String,
        userName: map[columnUserName] as String,
        action: map[columnAction] as String,
        entityType: map[columnEntityType] as String,
        entityId: map[columnEntityId] as String,
        oldValue: map[columnOldValue] as String,
        newValue: map[columnNewValue] as String,
        description: map[columnDescription] as String,
        timestamp: DateTime.parse(map[columnTimestamp] as String),
        ipAddress: map[columnIpAddress] as String?,
        userAgent: map[columnUserAgent] as String?,
        metadata: map[columnMetadata] != null
            ? jsonDecode(map[columnMetadata] as String) as Map<String, dynamic>
            : null,
      );
    } catch (e) {
      _logger.e('Error parsing AccountAuditLogModel from database: $e');
      _logger.d('Raw data: $map');
      return null;
    }
  }

  // Helper methods for common operations
  static Future<void> insertAuditLog(
    dynamic db,
    AccountAuditLogModel auditLog,
  ) async {
    await db.insert(tableName, toMap(auditLog));
  }

  static Future<void> insertMultipleAuditLogs(
    dynamic db,
    List<AccountAuditLogModel> auditLogs,
  ) async {
    await db.transaction((txn) async {
      for (final auditLog in auditLogs) {
        await txn.insert(tableName, toMap(auditLog));
      }
    });
  }

  static Future<void> updateAuditLog(
    dynamic db,
    AccountAuditLogModel auditLog,
  ) async {
    await db.update(
      tableName,
      toMap(auditLog),
      where: '$columnId = ?',
      whereArgs: [auditLog.id],
    );
  }

  static Future<void> deleteAuditLog(dynamic db, String auditLogId) async {
    await db.delete(tableName, where: '$columnId = ?', whereArgs: [auditLogId]);
  }

  static Future<AccountAuditLogModel?> getAuditLogById(
    dynamic db,
    String auditLogId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [auditLogId],
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  static Future<List<AccountAuditLogModel>> getAuditLogsByAccount(
    dynamic db,
    String accountId, {
    String? userId,
  }) async {
    final whereClause = userId != null
        ? '$columnAccountId = ? AND $columnUserId = ?'
        : '$columnAccountId = ?';
    final whereArgs = userId != null ? [accountId, userId] : [accountId];

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '$columnTimestamp DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((auditLog) => auditLog != null)
        .cast<AccountAuditLogModel>()
        .toList();
  }

  static Future<List<AccountAuditLogModel>> getAuditLogsByAction(
    dynamic db,
    String accountId,
    String action,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnAction = ?',
      whereArgs: [accountId, action],
      orderBy: '$columnTimestamp DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((auditLog) => auditLog != null)
        .cast<AccountAuditLogModel>()
        .toList();
  }

  static Future<List<AccountAuditLogModel>> getAuditLogsByEntityType(
    dynamic db,
    String accountId,
    String entityType,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnEntityType = ?',
      whereArgs: [accountId, entityType],
      orderBy: '$columnTimestamp DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((auditLog) => auditLog != null)
        .cast<AccountAuditLogModel>()
        .toList();
  }

  static Future<List<AccountAuditLogModel>> getAuditLogsByUser(
    dynamic db,
    String accountId,
    String userId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnUserId = ?',
      whereArgs: [accountId, userId],
      orderBy: '$columnTimestamp DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((auditLog) => auditLog != null)
        .cast<AccountAuditLogModel>()
        .toList();
  }

  static Future<List<AccountAuditLogModel>> getAuditLogsByDateRange(
    dynamic db,
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnTimestamp BETWEEN ? AND ?',
      whereArgs: [
        accountId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: '$columnTimestamp DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((auditLog) => auditLog != null)
        .cast<AccountAuditLogModel>()
        .toList();
  }

  static Future<List<AccountAuditLogModel>> getAuditLogsWithPagination(
    dynamic db,
    String accountId,
    int offset,
    int limit,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
      orderBy: '$columnTimestamp DESC',
      limit: limit,
      offset: offset,
    );

    return maps
        .map((map) => fromMap(map))
        .where((auditLog) => auditLog != null)
        .cast<AccountAuditLogModel>()
        .toList();
  }

  static Future<List<AccountAuditLogModel>> searchAuditLogs(
    dynamic db,
    String accountId,
    String searchTerm,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where:
          '''
        $columnAccountId = ? AND (
          $columnAction LIKE ? OR 
          $columnDescription LIKE ? OR 
          $columnUserName LIKE ? OR
          $columnEntityType LIKE ?
        )
      ''',
      whereArgs: [
        accountId,
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
      ],
      orderBy: '$columnTimestamp DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((auditLog) => auditLog != null)
        .cast<AccountAuditLogModel>()
        .toList();
  }

  static Future<int> getAuditLogsCount(dynamic db, String accountId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableName WHERE $columnAccountId = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> deleteAuditLogsByAccount(
    dynamic db,
    String accountId,
  ) async {
    await db.delete(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
    );
  }

  static Future<void> clearAllAuditLogs(dynamic db) async {
    await db.delete(tableName);
  }
}
