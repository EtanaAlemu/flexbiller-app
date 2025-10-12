import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/accounts/data/models/account_email_model.dart';

class AccountEmailDao {
  static const String tableName = 'account_emails';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnId = 'id';
  static const String columnAccountId = 'accountId';
  static const String columnEmail = 'email';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnEmail TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      UNIQUE($columnAccountId, $columnEmail)
    )
  ''';

  static Map<String, dynamic> toMap(AccountEmailModel accountEmail) {
    final now = DateTime.now().toIso8601String();
    return {
      columnId: '${accountEmail.accountId}_${accountEmail.email}',
      columnAccountId: accountEmail.accountId,
      columnEmail: accountEmail.email,
      columnCreatedAt: now,
      columnUpdatedAt: now,
    };
  }

  static AccountEmailModel fromMap(Map<String, dynamic> map) {
    return AccountEmailModel(
      accountId: map[columnAccountId] as String,
      email: map[columnEmail] as String,
    );
  }

  /// Insert or update an account email
  static Future<void> insertOrUpdate(
    Database db,
    AccountEmailModel accountEmail,
  ) async {
    try {
      final map = toMap(accountEmail);
      await db.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d(
        'Account email inserted/updated successfully: ${accountEmail.email} for account: ${accountEmail.accountId}',
      );
    } catch (e) {
      _logger.e('Error inserting account email: $e');
      rethrow;
    }
  }

  /// Insert multiple account emails
  static Future<void> insertMultiple(
    Database db,
    List<AccountEmailModel> accountEmails,
  ) async {
    try {
      await db.transaction((txn) async {
        for (final accountEmail in accountEmails) {
          final map = toMap(accountEmail);
          await txn.insert(
            tableName,
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      _logger.d('Inserted ${accountEmails.length} account emails successfully');
    } catch (e) {
      _logger.e('Error inserting multiple account emails: $e');
      rethrow;
    }
  }

  /// Get all account emails for a specific account
  static Future<List<AccountEmailModel>> getByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnEmail ASC',
      );

      final emails = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${emails.length} emails for account: $accountId');
      return emails;
    } catch (e) {
      _logger.e('Error retrieving account emails by account ID: $e');
      rethrow;
    }
  }

  /// Get a specific account email by ID
  static Future<AccountEmailModel?> getById(Database db, String id) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Account email retrieved successfully: $id');
        return fromMap(maps.first);
      }
      _logger.d('Account email not found: $id');
      return null;
    } catch (e) {
      _logger.e('Error retrieving account email by ID: $e');
      rethrow;
    }
  }

  /// Get account email by account ID and email address
  static Future<AccountEmailModel?> getByAccountIdAndEmail(
    Database db,
    String accountId,
    String email,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnEmail = ?',
        whereArgs: [accountId, email],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d(
          'Account email retrieved successfully: $email for account: $accountId',
        );
        return fromMap(maps.first);
      }
      _logger.d('Account email not found: $email for account: $accountId');
      return null;
    } catch (e) {
      _logger.e('Error retrieving account email by account ID and email: $e');
      rethrow;
    }
  }

  /// Get all account emails
  static Future<List<AccountEmailModel>> getAll(Database db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: '$columnAccountId ASC, $columnEmail ASC',
      );

      final emails = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${emails.length} account emails');
      return emails;
    } catch (e) {
      _logger.e('Error retrieving all account emails: $e');
      rethrow;
    }
  }

  /// Search account emails by email address
  static Future<List<AccountEmailModel>> searchByEmail(
    Database db,
    String emailAddress,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnEmail LIKE ?',
        whereArgs: ['%$emailAddress%'],
        orderBy: '$columnEmail ASC',
      );

      final emails = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Found ${emails.length} emails matching "$emailAddress"');
      return emails;
    } catch (e) {
      _logger.e('Error searching account emails by email: $e');
      rethrow;
    }
  }

  /// Get account emails by domain
  static Future<List<AccountEmailModel>> getByDomain(
    Database db,
    String domain,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnEmail LIKE ?',
        whereArgs: ['%@$domain'],
        orderBy: '$columnEmail ASC',
      );

      final emails = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${emails.length} emails for domain: $domain');
      return emails;
    } catch (e) {
      _logger.e('Error retrieving account emails by domain: $e');
      rethrow;
    }
  }

  /// Get account emails by domain for a specific account
  static Future<List<AccountEmailModel>> getByDomainForAccount(
    Database db,
    String accountId,
    String domain,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnEmail LIKE ?',
        whereArgs: [accountId, '%@$domain'],
        orderBy: '$columnEmail ASC',
      );

      final emails = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${emails.length} emails for domain $domain and account: $accountId',
      );
      return emails;
    } catch (e) {
      _logger.e('Error retrieving account emails by domain for account: $e');
      rethrow;
    }
  }

  /// Update an account email
  static Future<void> update(
    Database db,
    AccountEmailModel accountEmail,
  ) async {
    try {
      final map = toMap(accountEmail);
      map[columnUpdatedAt] = DateTime.now().toIso8601String();

      await db.update(
        tableName,
        map,
        where: '$columnId = ?',
        whereArgs: [map[columnId]],
      );
      _logger.d(
        'Account email updated successfully: ${accountEmail.email} for account: ${accountEmail.accountId}',
      );
    } catch (e) {
      _logger.e('Error updating account email: $e');
      rethrow;
    }
  }

  /// Delete an account email by ID
  static Future<void> delete(Database db, String id) async {
    try {
      await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
      _logger.d('Account email deleted successfully: $id');
    } catch (e) {
      _logger.e('Error deleting account email: $e');
      rethrow;
    }
  }

  /// Delete account email by account ID and email
  static Future<void> deleteByAccountIdAndEmail(
    Database db,
    String accountId,
    String email,
  ) async {
    try {
      await db.delete(
        tableName,
        where: '$columnAccountId = ? AND $columnEmail = ?',
        whereArgs: [accountId, email],
      );
      _logger.d(
        'Account email deleted successfully: $email for account: $accountId',
      );
    } catch (e) {
      _logger.e('Error deleting account email by account ID and email: $e');
      rethrow;
    }
  }

  /// Delete all account emails for a specific account
  static Future<void> deleteByAccountId(Database db, String accountId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
      );
      _logger.d('Account emails deleted successfully for account: $accountId');
    } catch (e) {
      _logger.e('Error deleting account emails by account ID: $e');
      rethrow;
    }
  }

  /// Delete all account emails
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All account emails deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all account emails: $e');
      rethrow;
    }
  }

  /// Get count of account emails for a specific account
  static Future<int> getCountByAccountId(Database db, String accountId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Account email count for account $accountId: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting account email count by account ID: $e');
      rethrow;
    }
  }

  /// Get count by domain
  static Future<int> getCountByDomain(Database db, String domain) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnEmail LIKE ?',
        ['%@$domain'],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Account email count for domain $domain: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting account email count by domain: $e');
      rethrow;
    }
  }

  /// Get total count of all account emails
  static Future<int> getTotalCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Total account email count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting total account email count: $e');
      rethrow;
    }
  }

  /// Check if an account email exists
  static Future<bool> exists(
    Database db,
    String accountId,
    String email,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ? AND $columnEmail = ?',
        [accountId, email],
      );
      final exists = (Sqflite.firstIntValue(result) ?? 0) > 0;
      _logger.d(
        'Account email exists check for $email in account $accountId: $exists',
      );
      return exists;
    } catch (e) {
      _logger.e('Error checking if account email exists: $e');
      rethrow;
    }
  }

  /// Check if email exists across all accounts
  static Future<bool> emailExists(Database db, String email) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnEmail = ?',
        [email],
      );
      final exists = (Sqflite.firstIntValue(result) ?? 0) > 0;
      _logger.d('Email exists check for $email: $exists');
      return exists;
    } catch (e) {
      _logger.e('Error checking if email exists: $e');
      rethrow;
    }
  }

  /// Get unique domains from all emails
  static Future<List<String>> getUniqueDomains(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT DISTINCT SUBSTR($columnEmail, INSTR($columnEmail, "@") + 1) as domain FROM $tableName ORDER BY domain',
      );
      final domains = result.map((row) => row['domain'] as String).toList();
      _logger.d('Retrieved ${domains.length} unique domains');
      return domains;
    } catch (e) {
      _logger.e('Error getting unique domains: $e');
      rethrow;
    }
  }

  /// Get unique domains for a specific account
  static Future<List<String>> getUniqueDomainsForAccount(
    Database db,
    String accountId,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT DISTINCT SUBSTR($columnEmail, INSTR($columnEmail, "@") + 1) as domain FROM $tableName WHERE $columnAccountId = ? ORDER BY domain',
        [accountId],
      );
      final domains = result.map((row) => row['domain'] as String).toList();
      _logger.d(
        'Retrieved ${domains.length} unique domains for account: $accountId',
      );
      return domains;
    } catch (e) {
      _logger.e('Error getting unique domains for account: $e');
      rethrow;
    }
  }

  /// Get emails with pagination
  static Future<List<AccountEmailModel>> getWithPagination(
    Database db,
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final offset = page * pageSize;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnEmail ASC',
        limit: pageSize,
        offset: offset,
      );

      final emails = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${emails.length} emails for account: $accountId (page $page, size $pageSize)',
      );
      return emails;
    } catch (e) {
      _logger.e('Error retrieving emails with pagination: $e');
      rethrow;
    }
  }

  /// Get recent emails for a specific account
  static Future<List<AccountEmailModel>> getRecentEmails(
    Database db,
    String accountId,
    int limit,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnCreatedAt DESC',
        limit: limit,
      );

      final emails = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${emails.length} recent emails for account: $accountId',
      );
      return emails;
    } catch (e) {
      _logger.e('Error retrieving recent emails: $e');
      rethrow;
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Get emails with invalid format
  static Future<List<AccountEmailModel>> getInvalidEmails(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnEmail ASC',
      );

      final invalidEmails = <AccountEmailModel>[];
      for (final map in maps) {
        final email = map[columnEmail] as String;
        if (!isValidEmail(email)) {
          invalidEmails.add(fromMap(map));
        }
      }

      _logger.d(
        'Found ${invalidEmails.length} invalid emails for account: $accountId',
      );
      return invalidEmails;
    } catch (e) {
      _logger.e('Error retrieving invalid emails: $e');
      rethrow;
    }
  }

  /// Get primary email for an account (first email alphabetically)
  static Future<AccountEmailModel?> getPrimaryEmail(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnEmail ASC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Primary email retrieved for account: $accountId');
        return fromMap(maps.first);
      }
      _logger.d('No primary email found for account: $accountId');
      return null;
    } catch (e) {
      _logger.e('Error retrieving primary email: $e');
      rethrow;
    }
  }
}
