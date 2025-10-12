import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/accounts/data/models/account_payment_method_model.dart';

class AccountPaymentMethodDao {
  static const String tableName = 'account_payment_methods';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnId = 'id';
  static const String columnAccountId = 'accountId';
  static const String columnExternalKey = 'externalKey';
  static const String columnPluginName = 'pluginName';
  static const String columnPluginInfo = 'pluginInfo';
  static const String columnIsDefault = 'isDefault';
  static const String columnAuditLogs = 'auditLogs';
  static const String columnPaymentMethodType = 'paymentMethodType';
  static const String columnPaymentMethodName = 'paymentMethodName';
  static const String columnCardLastFourDigits = 'cardLastFourDigits';
  static const String columnCardBrand = 'cardBrand';
  static const String columnCardExpiryMonth = 'cardExpiryMonth';
  static const String columnCardExpiryYear = 'cardExpiryYear';
  static const String columnBankName = 'bankName';
  static const String columnBankAccountLastFourDigits = 'bankAccountLastFourDigits';
  static const String columnBankAccountType = 'bankAccountType';
  static const String columnPaypalEmail = 'paypalEmail';
  static const String columnIsActive = 'isActive';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnMetadata = 'metadata';
  static const String columnCreatedAtDb = 'created_at';
  static const String columnUpdatedAtDb = 'updated_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnExternalKey TEXT,
      $columnPluginName TEXT,
      $columnPluginInfo TEXT,
      $columnIsDefault INTEGER NOT NULL,
      $columnAuditLogs TEXT,
      $columnPaymentMethodType TEXT,
      $columnPaymentMethodName TEXT,
      $columnCardLastFourDigits TEXT,
      $columnCardBrand TEXT,
      $columnCardExpiryMonth TEXT,
      $columnCardExpiryYear TEXT,
      $columnBankName TEXT,
      $columnBankAccountLastFourDigits TEXT,
      $columnBankAccountType TEXT,
      $columnPaypalEmail TEXT,
      $columnIsActive INTEGER,
      $columnCreatedAt TEXT,
      $columnUpdatedAt TEXT,
      $columnMetadata TEXT,
      $columnCreatedAtDb TEXT NOT NULL,
      $columnUpdatedAtDb TEXT NOT NULL
    )
  ''';

  static Map<String, dynamic> toMap(AccountPaymentMethodModel paymentMethod) {
    final now = DateTime.now().toIso8601String();
    return {
      columnId: paymentMethod.id,
      columnAccountId: paymentMethod.accountId,
      columnExternalKey: paymentMethod.externalKey,
      columnPluginName: paymentMethod.pluginName,
      columnPluginInfo: paymentMethod.pluginInfo != null
          ? jsonEncode(paymentMethod.pluginInfo)
          : null,
      columnIsDefault: paymentMethod.isDefault ? 1 : 0,
      columnAuditLogs: paymentMethod.auditLogs != null
          ? jsonEncode(paymentMethod.auditLogs)
          : null,
      columnPaymentMethodType: paymentMethod.paymentMethodType,
      columnPaymentMethodName: paymentMethod.paymentMethodName,
      columnCardLastFourDigits: paymentMethod.cardLastFourDigits,
      columnCardBrand: paymentMethod.cardBrand,
      columnCardExpiryMonth: paymentMethod.cardExpiryMonth,
      columnCardExpiryYear: paymentMethod.cardExpiryYear,
      columnBankName: paymentMethod.bankName,
      columnBankAccountLastFourDigits: paymentMethod.bankAccountLastFourDigits,
      columnBankAccountType: paymentMethod.bankAccountType,
      columnPaypalEmail: paymentMethod.paypalEmail,
      columnIsActive: paymentMethod.isActive != null
          ? (paymentMethod.isActive! ? 1 : 0)
          : null,
      columnCreatedAt: paymentMethod.createdAt?.toIso8601String(),
      columnUpdatedAt: paymentMethod.updatedAt?.toIso8601String(),
      columnMetadata: paymentMethod.metadata != null
          ? jsonEncode(paymentMethod.metadata)
          : null,
      columnCreatedAtDb: now,
      columnUpdatedAtDb: now,
    };
  }

  static AccountPaymentMethodModel fromMap(Map<String, dynamic> map) {
    return AccountPaymentMethodModel(
      id: map[columnId] as String,
      accountId: map[columnAccountId] as String,
      externalKey: map[columnExternalKey] as String?,
      pluginName: map[columnPluginName] as String?,
      pluginInfo: map[columnPluginInfo] != null
          ? jsonDecode(map[columnPluginInfo] as String) as Map<String, dynamic>
          : null,
      isDefault: (map[columnIsDefault] as int) == 1,
      auditLogs: map[columnAuditLogs] != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(
                map[columnAuditLogs] as String,
              ).map((x) => x as Map<String, dynamic>),
            )
          : null,
      paymentMethodType: map[columnPaymentMethodType] as String?,
      paymentMethodName: map[columnPaymentMethodName] as String?,
      cardLastFourDigits: map[columnCardLastFourDigits] as String?,
      cardBrand: map[columnCardBrand] as String?,
      cardExpiryMonth: map[columnCardExpiryMonth] as String?,
      cardExpiryYear: map[columnCardExpiryYear] as String?,
      bankName: map[columnBankName] as String?,
      bankAccountLastFourDigits: map[columnBankAccountLastFourDigits] as String?,
      bankAccountType: map[columnBankAccountType] as String?,
      paypalEmail: map[columnPaypalEmail] as String?,
      isActive: map[columnIsActive] != null ? (map[columnIsActive] as int) == 1 : null,
      createdAt: map[columnCreatedAt] != null
          ? DateTime.parse(map[columnCreatedAt] as String)
          : null,
      updatedAt: map[columnUpdatedAt] != null
          ? DateTime.parse(map[columnUpdatedAt] as String)
          : null,
      metadata: map[columnMetadata] != null
          ? jsonDecode(map[columnMetadata] as String) as Map<String, dynamic>
          : null,
    );
  }

  /// Insert or update a payment method
  static Future<void> insertOrUpdate(
    Database db,
    AccountPaymentMethodModel paymentMethod,
  ) async {
    try {
      final map = toMap(paymentMethod);
      await db.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d('Payment method inserted/updated successfully: ${paymentMethod.id}');
    } catch (e) {
      _logger.e('Error inserting payment method: $e');
      rethrow;
    }
  }

  /// Insert multiple payment methods
  static Future<void> insertMultiple(
    Database db,
    List<AccountPaymentMethodModel> paymentMethods,
  ) async {
    try {
      await db.transaction((txn) async {
        for (final paymentMethod in paymentMethods) {
          final map = toMap(paymentMethod);
          await txn.insert(
            tableName,
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      _logger.d('Inserted ${paymentMethods.length} payment methods successfully');
    } catch (e) {
      _logger.e('Error inserting multiple payment methods: $e');
      rethrow;
    }
  }

  /// Get all payment methods for a specific account
  static Future<List<AccountPaymentMethodModel>> getByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} payment methods for account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving payment methods by account ID: $e');
      rethrow;
    }
  }

  /// Get a specific payment method by ID
  static Future<AccountPaymentMethodModel?> getById(
    Database db,
    String id,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Payment method retrieved successfully: $id');
        return fromMap(maps.first);
      }
      _logger.d('Payment method not found: $id');
      return null;
    } catch (e) {
      _logger.e('Error retrieving payment method by ID: $e');
      rethrow;
    }
  }

  /// Get default payment method for an account
  static Future<AccountPaymentMethodModel?> getDefaultByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnIsDefault = 1',
        whereArgs: [accountId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Default payment method retrieved for account: $accountId');
        return fromMap(maps.first);
      }
      _logger.d('No default payment method found for account: $accountId');
      return null;
    } catch (e) {
      _logger.e('Error retrieving default payment method: $e');
      rethrow;
    }
  }

  /// Get active payment methods for an account
  static Future<List<AccountPaymentMethodModel>> getActiveByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnIsActive = 1',
        whereArgs: [accountId],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} active payment methods for account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving active payment methods: $e');
      rethrow;
    }
  }

  /// Get payment methods by type for an account
  static Future<List<AccountPaymentMethodModel>> getByType(
    Database db,
    String accountId,
    String paymentMethodType,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentMethodType = ?',
        whereArgs: [accountId, paymentMethodType],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} payment methods of type $paymentMethodType for account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving payment methods by type: $e');
      rethrow;
    }
  }

  /// Get payment methods by plugin name
  static Future<List<AccountPaymentMethodModel>> getByPluginName(
    Database db,
    String accountId,
    String pluginName,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPluginName = ?',
        whereArgs: [accountId, pluginName],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} payment methods for plugin $pluginName and account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving payment methods by plugin name: $e');
      rethrow;
    }
  }

  /// Get payment methods with pagination
  static Future<List<AccountPaymentMethodModel>> getWithPagination(
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
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
        limit: pageSize,
        offset: offset,
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} payment methods for account: $accountId (page $page, size $pageSize)');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving payment methods with pagination: $e');
      rethrow;
    }
  }

  /// Get all payment methods
  static Future<List<AccountPaymentMethodModel>> getAll(Database db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: '$columnAccountId, $columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} payment methods');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving all payment methods: $e');
      rethrow;
    }
  }

  /// Update a payment method
  static Future<void> update(
    Database db,
    AccountPaymentMethodModel paymentMethod,
  ) async {
    try {
      final map = toMap(paymentMethod);
      map[columnUpdatedAtDb] = DateTime.now().toIso8601String();

      await db.update(
        tableName,
        map,
        where: '$columnId = ?',
        whereArgs: [paymentMethod.id],
      );
      _logger.d('Payment method updated successfully: ${paymentMethod.id}');
    } catch (e) {
      _logger.e('Error updating payment method: $e');
      rethrow;
    }
  }

  /// Set default payment method (unset others for the same account)
  static Future<void> setDefault(
    Database db,
    String accountId,
    String paymentMethodId,
  ) async {
    try {
      await db.transaction((txn) async {
        // Unset all other default payment methods for this account
        await txn.update(
          tableName,
          {columnIsDefault: 0, columnUpdatedAtDb: DateTime.now().toIso8601String()},
          where: '$columnAccountId = ? AND $columnIsDefault = 1',
          whereArgs: [accountId],
        );

        // Set the specified payment method as default
        await txn.update(
          tableName,
          {columnIsDefault: 1, columnUpdatedAtDb: DateTime.now().toIso8601String()},
          where: '$columnId = ?',
          whereArgs: [paymentMethodId],
        );
      });
      _logger.d('Payment method set as default successfully: $paymentMethodId for account: $accountId');
    } catch (e) {
      _logger.e('Error setting default payment method: $e');
      rethrow;
    }
  }

  /// Delete a payment method
  static Future<void> delete(Database db, String id) async {
    try {
      await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
      _logger.d('Payment method deleted successfully: $id');
    } catch (e) {
      _logger.e('Error deleting payment method: $e');
      rethrow;
    }
  }

  /// Delete payment methods by account ID
  static Future<void> deleteByAccountId(Database db, String accountId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
      );
      _logger.d('Payment methods deleted successfully for account: $accountId');
    } catch (e) {
      _logger.e('Error deleting payment methods by account ID: $e');
      rethrow;
    }
  }

  /// Delete all payment methods
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All payment methods deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all payment methods: $e');
      rethrow;
    }
  }

  /// Get count of payment methods for a specific account
  static Future<int> getCountByAccountId(Database db, String accountId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Payment method count for account $accountId: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting payment method count by account ID: $e');
      rethrow;
    }
  }

  /// Get count by type for a specific account
  static Future<int> getCountByType(
    Database db,
    String accountId,
    String paymentMethodType,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ? AND $columnPaymentMethodType = ?',
        [accountId, paymentMethodType],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Payment method count for account $accountId and type $paymentMethodType: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting payment method count by type: $e');
      rethrow;
    }
  }

  /// Get count of active payment methods for a specific account
  static Future<int> getActiveCountByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ? AND $columnIsActive = 1',
        [accountId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Active payment method count for account $accountId: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting active payment method count: $e');
      rethrow;
    }
  }

  /// Get total count of all payment methods
  static Future<int> getTotalCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Total payment method count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting total payment method count: $e');
      rethrow;
    }
  }

  /// Check if a payment method exists
  static Future<bool> exists(Database db, String id) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnId = ?',
        [id],
      );
      final exists = (Sqflite.firstIntValue(result) ?? 0) > 0;
      _logger.d('Payment method exists check for $id: $exists');
      return exists;
    } catch (e) {
      _logger.e('Error checking if payment method exists: $e');
      rethrow;
    }
  }

  /// Check if account has default payment method
  static Future<bool> hasDefaultPaymentMethod(
    Database db,
    String accountId,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ? AND $columnIsDefault = 1',
        [accountId],
      );
      final hasDefault = (Sqflite.firstIntValue(result) ?? 0) > 0;
      _logger.d('Account $accountId has default payment method: $hasDefault');
      return hasDefault;
    } catch (e) {
      _logger.e('Error checking if account has default payment method: $e');
      rethrow;
    }
  }

  /// Search payment methods by name
  static Future<List<AccountPaymentMethodModel>> searchByName(
    Database db,
    String accountId,
    String searchTerm,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentMethodName LIKE ?',
        whereArgs: [accountId, '%$searchTerm%'],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Found ${paymentMethods.length} payment methods matching "$searchTerm" for account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error searching payment methods by name: $e');
      rethrow;
    }
  }

  /// Get payment methods by external key
  static Future<AccountPaymentMethodModel?> getByExternalKey(
    Database db,
    String externalKey,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnExternalKey = ?',
        whereArgs: [externalKey],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Payment method retrieved by external key: $externalKey');
        return fromMap(maps.first);
      }
      _logger.d('Payment method not found by external key: $externalKey');
      return null;
    } catch (e) {
      _logger.e('Error retrieving payment method by external key: $e');
      rethrow;
    }
  }

  /// Get payment methods by card brand
  static Future<List<AccountPaymentMethodModel>> getByCardBrand(
    Database db,
    String accountId,
    String cardBrand,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnCardBrand = ?',
        whereArgs: [accountId, cardBrand],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} payment methods for card brand $cardBrand and account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving payment methods by card brand: $e');
      rethrow;
    }
  }

  /// Get payment methods by bank name
  static Future<List<AccountPaymentMethodModel>> getByBankName(
    Database db,
    String accountId,
    String bankName,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnBankName = ?',
        whereArgs: [accountId, bankName],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} payment methods for bank $bankName and account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving payment methods by bank name: $e');
      rethrow;
    }
  }

  /// Search payment methods by multiple criteria
  static Future<List<AccountPaymentMethodModel>> search(
    Database db,
    String accountId,
    String searchQuery,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND ($columnPaymentMethodName LIKE ? OR $columnCardBrand LIKE ? OR $columnBankName LIKE ?)',
        whereArgs: [accountId, '%$searchQuery%', '%$searchQuery%', '%$searchQuery%'],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Found ${paymentMethods.length} payment methods matching "$searchQuery" for account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error searching payment methods: $e');
      rethrow;
    }
  }

  /// Get payment methods by PayPal email
  static Future<List<AccountPaymentMethodModel>> getByPaypalEmail(
    Database db,
    String accountId,
    String paypalEmail,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaypalEmail = ?',
        whereArgs: [accountId, paypalEmail],
        orderBy: '$columnIsDefault DESC, $columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} payment methods for PayPal email $paypalEmail and account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving payment methods by PayPal email: $e');
      rethrow;
    }
  }

  /// Get expired card payment methods
  static Future<List<AccountPaymentMethodModel>> getExpiredCards(
    Database db,
    String accountId,
  ) async {
    try {
      final currentYear = DateTime.now().year;
      final currentMonth = DateTime.now().month;
      
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnCardBrand IS NOT NULL AND ($columnCardExpiryYear < ? OR ($columnCardExpiryYear = ? AND $columnCardExpiryMonth < ?))',
        whereArgs: [accountId, currentYear.toString(), currentYear.toString(), currentMonth.toString().padLeft(2, '0')],
        orderBy: '$columnCreatedAt DESC',
      );

      final paymentMethods = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${paymentMethods.length} expired card payment methods for account: $accountId');
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving expired card payment methods: $e');
      rethrow;
    }
  }
}