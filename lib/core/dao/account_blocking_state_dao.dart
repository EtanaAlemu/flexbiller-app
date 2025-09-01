import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_blocking_state_model.dart';

/// Data Access Object for AccountBlockingStateModel
class AccountBlockingStateDao {
  // Table name
  static const String tableName = 'account_blocking_states';

  // Column names
  static const String columnId = 'id';
  static const String columnAccountId = 'account_id';
  static const String columnStateName = 'state_name';
  static const String columnService = 'service';
  static const String columnIsBlockChange = 'is_block_change';
  static const String columnIsBlockEntitlement = 'is_block_entitlement';
  static const String columnIsBlockBilling = 'is_block_billing';
  static const String columnEffectiveDate = 'effective_date';
  static const String columnType = 'type';
  static const String columnSyncStatus = 'sync_status';

  // SQL to create the table
  static String get createTableSQL =>
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnStateName TEXT NOT NULL,
      $columnService TEXT NOT NULL,
      $columnIsBlockChange INTEGER NOT NULL,
      $columnIsBlockEntitlement INTEGER NOT NULL,
      $columnIsBlockBilling INTEGER NOT NULL,
      $columnEffectiveDate TEXT NOT NULL,
      $columnType TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL
    )
  ''';

  // Convert AccountBlockingStateModel to database map
  static Map<String, dynamic> toMap(AccountBlockingStateModel model) {
    return {
      columnId: '${model.service}_${model.stateName}', // Generate unique ID
      columnAccountId:
          'default', // Since model doesn't have accountId, use default
      columnStateName: model.stateName,
      columnService: model.service,
      columnIsBlockChange: model.isBlockChange ? 1 : 0,
      columnIsBlockEntitlement: model.isBlockEntitlement ? 1 : 0,
      columnIsBlockBilling: model.isBlockBilling ? 1 : 0,
      columnEffectiveDate: model.effectiveDate.toIso8601String(),
      columnType: model.type,
      columnSyncStatus: 'synced',
    };
  }

  // Convert database map to AccountBlockingStateModel
  static AccountBlockingStateModel? fromMap(Map<String, dynamic> map) {
    try {
      return AccountBlockingStateModel(
        stateName: map[columnStateName] as String,
        service: map[columnService] as String,
        isBlockChange: (map[columnIsBlockChange] as int) == 1,
        isBlockEntitlement: (map[columnIsBlockEntitlement] as int) == 1,
        isBlockBilling: (map[columnIsBlockBilling] as int) == 1,
        effectiveDate: DateTime.parse(map[columnEffectiveDate] as String),
        type: map[columnType] as String,
      );
    } catch (e) {
      print('Error parsing AccountBlockingStateModel from database: $e');
      print('Raw data: $map');
      return null;
    }
  }

  // Helper methods for common operations
  static Future<void> insertBlockingState(
    dynamic db,
    AccountBlockingStateModel blockingState,
  ) async {
    await db.insert(tableName, toMap(blockingState));
  }

  static Future<void> insertMultipleBlockingStates(
    dynamic db,
    List<AccountBlockingStateModel> blockingStates,
  ) async {
    await db.transaction((txn) async {
      for (final blockingState in blockingStates) {
        await txn.insert(tableName, toMap(blockingState));
      }
    });
  }

  static Future<void> updateBlockingState(
    dynamic db,
    AccountBlockingStateModel blockingState,
  ) async {
    await db.update(
      tableName,
      toMap(blockingState),
      where: '$columnId = ?',
      whereArgs: ['${blockingState.service}_${blockingState.stateName}'],
    );
  }

  static Future<void> deleteBlockingState(
    dynamic db,
    String blockingStateId,
  ) async {
    await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [blockingStateId],
    );
  }

  static Future<AccountBlockingStateModel?> getBlockingStateById(
    dynamic db,
    String blockingStateId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [blockingStateId],
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  static Future<List<AccountBlockingStateModel>> getBlockingStatesByAccount(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
      orderBy: '$columnEffectiveDate DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((blockingState) => blockingState != null)
        .cast<AccountBlockingStateModel>()
        .toList();
  }

  static Future<List<AccountBlockingStateModel>> getBlockingStatesByState(
    dynamic db,
    String accountId,
    String state,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnStateName = ?',
      whereArgs: [accountId, state],
      orderBy: '$columnEffectiveDate DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((blockingState) => blockingState != null)
        .cast<AccountBlockingStateModel>()
        .toList();
  }

  static Future<List<AccountBlockingStateModel>> getActiveBlockingStates(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnIsBlockChange = 1',
      whereArgs: [accountId],
      orderBy: '$columnEffectiveDate DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((blockingState) => blockingState != null)
        .cast<AccountBlockingStateModel>()
        .toList();
  }

  static Future<List<AccountBlockingStateModel>> getBlockingStatesByService(
    dynamic db,
    String accountId,
    String service,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnService = ?',
      whereArgs: [accountId, service],
      orderBy: '$columnEffectiveDate DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((blockingState) => blockingState != null)
        .cast<AccountBlockingStateModel>()
        .toList();
  }

  static Future<List<AccountBlockingStateModel>> getBlockingStatesByDateRange(
    dynamic db,
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ? AND $columnEffectiveDate BETWEEN ? AND ?',
      whereArgs: [
        accountId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: '$columnEffectiveDate DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((blockingState) => blockingState != null)
        .cast<AccountBlockingStateModel>()
        .toList();
  }

  static Future<List<AccountBlockingStateModel>>
  getBlockingStatesWithPagination(
    dynamic db,
    String accountId,
    int offset,
    int limit,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
      orderBy: '$columnEffectiveDate DESC',
      limit: limit,
      offset: offset,
    );

    return maps
        .map((map) => fromMap(map))
        .where((blockingState) => blockingState != null)
        .cast<AccountBlockingStateModel>()
        .toList();
  }

  static Future<List<AccountBlockingStateModel>> searchBlockingStates(
    dynamic db,
    String accountId,
    String searchTerm,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where:
          '''
        $columnAccountId = ? AND (
          $columnStateName LIKE ? OR 
          $columnService LIKE ? OR 
          $columnType LIKE ?
        )
      ''',
      whereArgs: [accountId, '%$searchTerm%', '%$searchTerm%', '%$searchTerm%'],
      orderBy: '$columnEffectiveDate DESC',
    );

    return maps
        .map((map) => fromMap(map))
        .where((blockingState) => blockingState != null)
        .cast<AccountBlockingStateModel>()
        .toList();
  }

  static Future<int> getBlockingStatesCount(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableName WHERE $columnAccountId = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<int> getActiveBlockingStatesCount(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM $tableName WHERE $columnAccountId = ? AND $columnIsBlockChange = 1',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> deleteBlockingStatesByAccount(
    dynamic db,
    String accountId,
  ) async {
    await db.delete(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
    );
  }

  static Future<void> clearAllBlockingStates(dynamic db) async {
    await db.delete(tableName);
  }
}
