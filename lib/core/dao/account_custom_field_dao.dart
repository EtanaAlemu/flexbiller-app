import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_custom_field_model.dart';

/// Data Access Object for AccountCustomFieldModel
class AccountCustomFieldDao {
  // Table name
  static const String tableName = 'account_custom_fields';

  // Column names
  static const String columnId = 'id';
  static const String columnAccountId = 'account_id';
  static const String columnName = 'name';
  static const String columnValue = 'value';
  static const String columnObjectType = 'object_type';
  static const String columnAuditLogs = 'audit_logs';
  static const String columnSyncStatus = 'sync_status';

  // SQL to create the table
  static String get createTableSQL =>
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnName TEXT NOT NULL,
      $columnValue TEXT NOT NULL,
      $columnObjectType TEXT NOT NULL,
      $columnAuditLogs TEXT,
      $columnSyncStatus TEXT NOT NULL
    )
  ''';

  // Convert AccountCustomFieldModel to database map
  static Map<String, dynamic> toMap(AccountCustomFieldModel model) {
    return {
      columnId: model.customFieldId,
      columnAccountId: model.objectId,
      columnName: model.name,
      columnValue: model.value,
      columnObjectType: model.objectType,
      columnAuditLogs: model.auditLogs != null
          ? jsonEncode(model.auditLogs)
          : null,
      columnSyncStatus: 'synced',
    };
  }

  // Convert database map to AccountCustomFieldModel
  static AccountCustomFieldModel? fromMap(Map<String, dynamic> map) {
    try {
      // Handle auditLogs parsing more robustly
      List<Map<String, dynamic>>? auditLogs;
      if (map[columnAuditLogs] != null) {
        final auditLogsData = map[columnAuditLogs];
        if (auditLogsData is String) {
          // If it's a JSON string, decode it
          final decoded = jsonDecode(auditLogsData);
          if (decoded is List) {
            auditLogs = decoded
                .map(
                  (item) => item is Map<String, dynamic>
                      ? item
                      : Map<String, dynamic>.from(item),
                )
                .toList();
          }
        } else if (auditLogsData is List) {
          // If it's already a list, convert each item to Map<String, dynamic>
          auditLogs = auditLogsData
              .map(
                (item) => item is Map<String, dynamic>
                    ? item
                    : Map<String, dynamic>.from(item),
              )
              .toList();
        }
      }

      return AccountCustomFieldModel(
        customFieldId: map[columnId] as String,
        objectId: map[columnAccountId] as String,
        objectType: map[columnObjectType] as String,
        name: map[columnName] as String,
        value: map[columnValue] as String,
        auditLogs: auditLogs,
      );
    } catch (e) {
      print('Error parsing AccountCustomFieldModel from database: $e');
      print('Raw data: $map');
      return null;
    }
  }

  // Helper methods for common operations
  static Future<void> insertCustomField(
    dynamic db,
    AccountCustomFieldModel customField,
  ) async {
    await db.insert(
      tableName,
      toMap(customField),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertMultipleCustomFields(
    dynamic db,
    List<AccountCustomFieldModel> customFields,
  ) async {
    await db.transaction((txn) async {
      for (final customField in customFields) {
        await txn.insert(
          tableName,
          toMap(customField),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<void> updateCustomField(
    dynamic db,
    AccountCustomFieldModel customField,
  ) async {
    await db.update(
      tableName,
      toMap(customField),
      where: '$columnId = ?',
      whereArgs: [customField.customFieldId],
    );
  }

  static Future<void> deleteCustomField(
    dynamic db,
    String customFieldId,
  ) async {
    await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [customFieldId],
    );
  }

  static Future<void> deleteMultipleCustomFields(
    dynamic db,
    List<String> customFieldIds,
  ) async {
    if (customFieldIds.isEmpty) return;

    final placeholders = customFieldIds.map((_) => '?').join(',');
    await db.delete(
      tableName,
      where: '$columnId IN ($placeholders)',
      whereArgs: customFieldIds,
    );
  }

  static Future<AccountCustomFieldModel?> getCustomFieldById(
    dynamic db,
    String customFieldId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [customFieldId],
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  static Future<List<AccountCustomFieldModel>> getCustomFieldsByAccount(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
      orderBy: '$columnName ASC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((customField) => customField != null)
        .cast<AccountCustomFieldModel>()
        .toList();
  }

  static Future<List<AccountCustomFieldModel>> getCustomFieldsByName(
    dynamic db,
    String accountId,
    String name,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnName LIKE ?',
      whereArgs: [accountId, '%$name%'],
      orderBy: '$columnName ASC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((customField) => customField != null)
        .cast<AccountCustomFieldModel>()
        .toList();
  }

  static Future<List<AccountCustomFieldModel>> getCustomFieldsByValue(
    dynamic db,
    String accountId,
    String value,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnValue LIKE ?',
      whereArgs: [accountId, '%$value%'],
      orderBy: '$columnName ASC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((customField) => customField != null)
        .cast<AccountCustomFieldModel>()
        .toList();
  }

  static Future<List<AccountCustomFieldModel>> getCustomFieldsByType(
    dynamic db,
    String accountId,
    String type,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnObjectType = ?',
      whereArgs: [accountId, type],
      orderBy: '$columnName ASC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((customField) => customField != null)
        .cast<AccountCustomFieldModel>()
        .toList();
  }

  static Future<List<AccountCustomFieldModel>> getCustomFieldsWithPagination(
    dynamic db,
    String accountId,
    int offset,
    int limit,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
      orderBy: '$columnName ASC',
      limit: limit,
      offset: offset,
    );

    return maps
        .map((map) => fromMap(map))
        .where((customField) => customField != null)
        .cast<AccountCustomFieldModel>()
        .toList();
  }

  static Future<List<AccountCustomFieldModel>> searchCustomFields(
    dynamic db,
    String accountId,
    String searchTerm,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where:
          '''
        $columnAccountId = ? AND (
          $columnName LIKE ? OR 
          $columnValue LIKE ? OR
          $columnObjectType LIKE ?
        )
      ''',
      whereArgs: [accountId, '%$searchTerm%', '%$searchTerm%', '%$searchTerm%'],
      orderBy: '$columnName ASC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((customField) => customField != null)
        .cast<AccountCustomFieldModel>()
        .toList();
  }

  static Future<int> getCustomFieldsCount(dynamic db, String accountId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableName WHERE $columnAccountId = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> deleteCustomFieldsByAccount(
    dynamic db,
    String accountId,
  ) async {
    await db.delete(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
    );
  }

  static Future<void> clearAllCustomFields(dynamic db) async {
    await db.delete(tableName);
  }
}
