import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_email_model.dart';

class AccountEmailDao {
  static const String tableName = 'account_emails';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      accountId TEXT NOT NULL,
      email TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      UNIQUE(accountId, email)
    )
  ''';

  static Map<String, dynamic> toMap(AccountEmailModel accountEmail) {
    final now = DateTime.now().toIso8601String();
    return {
      'id': '${accountEmail.accountId}_${accountEmail.email}',
      'accountId': accountEmail.accountId,
      'email': accountEmail.email,
      'created_at': now,
      'updated_at': now,
    };
  }

  static AccountEmailModel fromMap(Map<String, dynamic> map) {
    return AccountEmailModel(
      accountId: map['accountId'] as String,
      email: map['email'] as String,
    );
  }

  // Insert or update an account email
  static Future<void> insertOrUpdate(
    dynamic db,
    AccountEmailModel accountEmail,
  ) async {
    final map = toMap(accountEmail);
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple account emails
  static Future<void> insertMultiple(
    dynamic db,
    List<AccountEmailModel> accountEmails,
  ) async {
    await db.transaction((txn) async {
      for (final accountEmail in accountEmails) {
        await insertOrUpdate(txn, accountEmail);
      }
    });
  }

  // Get all account emails for a specific account
  static Future<List<AccountEmailModel>> getByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'email ASC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get a specific account email
  static Future<AccountEmailModel?> getById(dynamic db, String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Get account email by account ID and email address
  static Future<AccountEmailModel?> getByAccountIdAndEmail(
    dynamic db,
    String accountId,
    String email,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND email = ?',
      whereArgs: [accountId, email],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Get all account emails
  static Future<List<AccountEmailModel>> getAll(dynamic db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'accountId ASC, email ASC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Search account emails by email address
  static Future<List<AccountEmailModel>> searchByEmail(
    dynamic db,
    String emailAddress,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'email LIKE ?',
      whereArgs: ['%$emailAddress%'],
      orderBy: 'email ASC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get account emails by domain
  static Future<List<AccountEmailModel>> getByDomain(
    dynamic db,
    String domain,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'email LIKE ?',
      whereArgs: ['%@$domain'],
      orderBy: 'email ASC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Update an account email
  static Future<int> update(dynamic db, AccountEmailModel accountEmail) async {
    final map = toMap(accountEmail);
    map['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      tableName,
      map,
      where: 'id = ?',
      whereArgs: [map['id']],
    );
  }

  // Delete an account email
  static Future<int> delete(dynamic db, String id) async {
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Delete account email by account ID and email
  static Future<int> deleteByAccountIdAndEmail(
    dynamic db,
    String accountId,
    String email,
  ) async {
    return await db.delete(
      tableName,
      where: 'accountId = ? AND email = ?',
      whereArgs: [accountId, email],
    );
  }

  // Delete all account emails for a specific account
  static Future<int> deleteByAccountId(dynamic db, String accountId) async {
    return await db.delete(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
  }

  // Delete all account emails
  static Future<int> deleteAll(dynamic db) async {
    return await db.delete(tableName);
  }

  // Get count of account emails for a specific account
  static Future<int> getCountByAccountId(dynamic db, String accountId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total count of all account emails
  static Future<int> getTotalCount(dynamic db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Check if an account email exists
  static Future<bool> exists(dynamic db, String accountId, String email) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ? AND email = ?',
      [accountId, email],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}
