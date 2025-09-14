import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/child_account_model.dart';

class ChildAccountDao {
  static const String tableName = 'child_accounts';

  // Column names
  static const String columnUserId = 'user_id';
  static const String columnName = 'name';
  static const String columnEmail = 'email';
  static const String columnCurrency = 'currency';
  static const String columnIsPaymentDelegatedToParent =
      'is_payment_delegated_to_parent';
  static const String columnParentAccountId = 'parent_account_id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status';

  static String get createTableSQL =>
      '''
    CREATE TABLE $tableName (
      $columnEmail TEXT PRIMARY KEY,
      $columnUserId TEXT NOT NULL,
      $columnName TEXT NOT NULL,
      $columnCurrency TEXT NOT NULL,
      $columnIsPaymentDelegatedToParent INTEGER NOT NULL,
      $columnParentAccountId TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES users (id) ON DELETE CASCADE
    )
  ''';

  static Map<String, dynamic> toMap(
    ChildAccountModel childAccount, {
    String? userId,
  }) {
    return {
      columnUserId: userId,
      columnName: childAccount.name,
      columnEmail: childAccount.email,
      columnCurrency: childAccount.currency,
      columnIsPaymentDelegatedToParent: childAccount.isPaymentDelegatedToParent
          ? 1
          : 0,
      columnParentAccountId: childAccount.parentAccountId,
      columnCreatedAt: DateTime.now().toIso8601String(),
      columnUpdatedAt: DateTime.now().toIso8601String(),
      columnSyncStatus: 'synced',
    };
  }

  static ChildAccountModel fromMap(Map<String, dynamic> map) {
    return ChildAccountModel(
      name: map[columnName] as String,
      email: map[columnEmail] as String,
      currency: map[columnCurrency] as String,
      isPaymentDelegatedToParent:
          (map[columnIsPaymentDelegatedToParent] as int) == 1,
      parentAccountId: map[columnParentAccountId] as String,
    );
  }

  // Insert or update child account
  static Future<void> insertOrUpdate(
    Database db,
    ChildAccountModel childAccount, {
    String? userId,
  }) async {
    await db.insert(
      tableName,
      toMap(childAccount, userId: userId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete child account by email
  static Future<int> deleteByEmail(Database db, String email) async {
    return await db.delete(
      tableName,
      where: '$columnEmail = ?',
      whereArgs: [email],
    );
  }

  // Get child account by email
  static Future<ChildAccountModel?> getByEmail(
    Database db,
    String email,
  ) async {
    final maps = await db.query(
      tableName,
      where: '$columnEmail = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Get all child accounts
  static Future<List<ChildAccountModel>> getAll(
    Database db, {
    String? orderBy,
    String? userId,
  }) async {
    final maps = await db.query(
      tableName,
      where: userId != null ? '$columnUserId = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: orderBy,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  // Get child accounts by parent account ID
  static Future<List<ChildAccountModel>> getByParentAccountId(
    Database db,
    String parentAccountId, {
    String? userId,
  }) async {
    final whereClause = userId != null
        ? '$columnUserId = ? AND $columnParentAccountId = ?'
        : '$columnParentAccountId = ?';
    final whereArgs = userId != null
        ? [userId, parentAccountId]
        : [parentAccountId];

    final maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '$columnName ASC',
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  // Search child accounts
  static Future<List<ChildAccountModel>> search(
    Database db,
    String searchKey, {
    String? userId,
  }) async {
    final whereClause = userId != null
        ? '$columnUserId = ? AND ($columnName LIKE ? OR $columnEmail LIKE ?)'
        : '$columnName LIKE ? OR $columnEmail LIKE ?';
    final whereArgs = userId != null
        ? [userId, '%$searchKey%', '%$searchKey%']
        : ['%$searchKey%', '%$searchKey%'];

    final maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '$columnName ASC',
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  // Get count of child accounts
  static Future<int> getCount(Database db, {String? userId}) async {
    if (userId != null) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE $columnUserId = ?',
        [userId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } else {
      final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    }
  }

  // Check if child accounts exist
  static Future<bool> hasChildAccounts(Database db, {String? userId}) async {
    final count = await getCount(db, userId: userId);
    return count > 0;
  }

  // Clear all child accounts
  static Future<int> clearAll(Database db) async {
    return await db.delete(tableName);
  }

  // Get child accounts by query parameters
  static Future<List<ChildAccountModel>> getByQuery(
    Database db, {
    String? parentAccountId,
    String? searchKey,
    String? orderBy,
    String? userId,
  }) async {
    String whereClause = '';
    List<Object> whereArgs = [];

    if (userId != null) {
      whereClause = '$columnUserId = ?';
      whereArgs.add(userId);
    }

    if (parentAccountId != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += '$columnParentAccountId = ?';
      whereArgs.add(parentAccountId);
    }

    if (searchKey != null && searchKey.isNotEmpty) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += '($columnName LIKE ? OR $columnEmail LIKE ?)';
      whereArgs.addAll(['%$searchKey%', '%$searchKey%']);
    }

    final maps = await db.query(
      tableName,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy ?? '$columnName ASC',
    );

    return maps.map((map) => fromMap(map)).toList();
  }
}
