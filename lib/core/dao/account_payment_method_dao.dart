import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_payment_method_model.dart';

class AccountPaymentMethodDao {
  static const String tableName = 'account_payment_methods';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      accountId TEXT NOT NULL,
      externalKey TEXT,
      pluginName TEXT,
      pluginInfo TEXT,
      isDefault INTEGER NOT NULL,
      auditLogs TEXT,
      paymentMethodType TEXT,
      paymentMethodName TEXT,
      cardLastFourDigits TEXT,
      cardBrand TEXT,
      cardExpiryMonth TEXT,
      cardExpiryYear TEXT,
      bankName TEXT,
      bankAccountLastFourDigits TEXT,
      bankAccountType TEXT,
      paypalEmail TEXT,
      isActive INTEGER,
      createdAt TEXT,
      updatedAt TEXT,
      metadata TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static Map<String, dynamic> toMap(AccountPaymentMethodModel paymentMethod) {
    final now = DateTime.now().toIso8601String();
    return {
      'id': paymentMethod.id,
      'accountId': paymentMethod.accountId,
      'externalKey': paymentMethod.externalKey,
      'pluginName': paymentMethod.pluginName,
      'pluginInfo': paymentMethod.pluginInfo != null
          ? jsonEncode(paymentMethod.pluginInfo)
          : null,
      'isDefault': paymentMethod.isDefault ? 1 : 0,
      'auditLogs': paymentMethod.auditLogs != null
          ? jsonEncode(paymentMethod.auditLogs)
          : null,
      'paymentMethodType': paymentMethod.paymentMethodType,
      'paymentMethodName': paymentMethod.paymentMethodName,
      'cardLastFourDigits': paymentMethod.cardLastFourDigits,
      'cardBrand': paymentMethod.cardBrand,
      'cardExpiryMonth': paymentMethod.cardExpiryMonth,
      'cardExpiryYear': paymentMethod.cardExpiryYear,
      'bankName': paymentMethod.bankName,
      'bankAccountLastFourDigits': paymentMethod.bankAccountLastFourDigits,
      'bankAccountType': paymentMethod.bankAccountType,
      'paypalEmail': paymentMethod.paypalEmail,
      'isActive': paymentMethod.isActive != null
          ? (paymentMethod.isActive! ? 1 : 0)
          : null,
      'createdAt': paymentMethod.createdAt?.toIso8601String(),
      'updatedAt': paymentMethod.updatedAt?.toIso8601String(),
      'metadata': paymentMethod.metadata != null
          ? jsonEncode(paymentMethod.metadata)
          : null,
      'created_at': now,
      'updated_at': now,
    };
  }

  static AccountPaymentMethodModel fromMap(Map<String, dynamic> map) {
    return AccountPaymentMethodModel(
      id: map['id'] as String,
      accountId: map['accountId'] as String,
      externalKey: map['externalKey'] as String?,
      pluginName: map['pluginName'] as String?,
      pluginInfo: map['pluginInfo'] != null
          ? jsonDecode(map['pluginInfo'] as String) as Map<String, dynamic>
          : null,
      isDefault: (map['isDefault'] as int) == 1,
      auditLogs: map['auditLogs'] != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(
                map['auditLogs'] as String,
              ).map((x) => x as Map<String, dynamic>),
            )
          : null,
      paymentMethodType: map['paymentMethodType'] as String?,
      paymentMethodName: map['paymentMethodName'] as String?,
      cardLastFourDigits: map['cardLastFourDigits'] as String?,
      cardBrand: map['cardBrand'] as String?,
      cardExpiryMonth: map['cardExpiryMonth'] as String?,
      cardExpiryYear: map['cardExpiryYear'] as String?,
      bankName: map['bankName'] as String?,
      bankAccountLastFourDigits: map['bankAccountLastFourDigits'] as String?,
      bankAccountType: map['bankAccountType'] as String?,
      paypalEmail: map['paypalEmail'] as String?,
      isActive: map['isActive'] != null ? (map['isActive'] as int) == 1 : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  // Insert or update a payment method
  static Future<void> insertOrUpdate(
    dynamic db,
    AccountPaymentMethodModel paymentMethod,
  ) async {
    final map = toMap(paymentMethod);
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple payment methods
  static Future<void> insertMultiple(
    dynamic db,
    List<AccountPaymentMethodModel> paymentMethods,
  ) async {
    await db.transaction((txn) async {
      for (final paymentMethod in paymentMethods) {
        await insertOrUpdate(txn, paymentMethod);
      }
    });
  }

  // Get all payment methods for a specific account
  static Future<List<AccountPaymentMethodModel>> getByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'isDefault DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get a specific payment method by ID
  static Future<AccountPaymentMethodModel?> getById(
    dynamic db,
    String id,
  ) async {
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

  // Get default payment method for an account
  static Future<AccountPaymentMethodModel?> getDefaultByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND isDefault = 1',
      whereArgs: [accountId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Get active payment methods for an account
  static Future<List<AccountPaymentMethodModel>> getActiveByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND isActive = 1',
      whereArgs: [accountId],
      orderBy: 'isDefault DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payment methods by type for an account
  static Future<List<AccountPaymentMethodModel>> getByType(
    dynamic db,
    String accountId,
    String paymentMethodType,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentMethodType = ?',
      whereArgs: [accountId, paymentMethodType],
      orderBy: 'isDefault DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payment methods by plugin name
  static Future<List<AccountPaymentMethodModel>> getByPluginName(
    dynamic db,
    String accountId,
    String pluginName,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND pluginName = ?',
      whereArgs: [accountId, pluginName],
      orderBy: 'isDefault DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payment methods with pagination
  static Future<List<AccountPaymentMethodModel>> getWithPagination(
    dynamic db,
    String accountId,
    int page,
    int pageSize,
  ) async {
    final offset = page * pageSize;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'isDefault DESC, createdAt DESC',
      limit: pageSize,
      offset: offset,
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get all payment methods
  static Future<List<AccountPaymentMethodModel>> getAll(dynamic db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'accountId, isDefault DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Update a payment method
  static Future<int> update(
    dynamic db,
    AccountPaymentMethodModel paymentMethod,
  ) async {
    final map = toMap(paymentMethod);
    map['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      tableName,
      map,
      where: 'id = ?',
      whereArgs: [paymentMethod.id],
    );
  }

  // Set default payment method (unset others for the same account)
  static Future<void> setDefault(
    dynamic db,
    String accountId,
    String paymentMethodId,
  ) async {
    await db.transaction((txn) async {
      // Unset all other default payment methods for this account
      await txn.update(
        tableName,
        {'isDefault': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'accountId = ? AND isDefault = 1',
        whereArgs: [accountId],
      );

      // Set the specified payment method as default
      await txn.update(
        tableName,
        {'isDefault': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [paymentMethodId],
      );
    });
  }

  // Delete a payment method
  static Future<int> delete(dynamic db, String id) async {
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Delete payment methods by account ID
  static Future<int> deleteByAccountId(dynamic db, String accountId) async {
    return await db.delete(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
  }

  // Delete all payment methods
  static Future<int> deleteAll(dynamic db) async {
    return await db.delete(tableName);
  }

  // Get count of payment methods for a specific account
  static Future<int> getCountByAccountId(dynamic db, String accountId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count by type for a specific account
  static Future<int> getCountByType(
    dynamic db,
    String accountId,
    String paymentMethodType,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ? AND paymentMethodType = ?',
      [accountId, paymentMethodType],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count of active payment methods for a specific account
  static Future<int> getActiveCountByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ? AND isActive = 1',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total count of all payment methods
  static Future<int> getTotalCount(dynamic db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Check if a payment method exists
  static Future<bool> exists(dynamic db, String id) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE id = ?',
      [id],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  // Check if account has default payment method
  static Future<bool> hasDefaultPaymentMethod(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ? AND isDefault = 1',
      [accountId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  // Search payment methods by name
  static Future<List<AccountPaymentMethodModel>> searchByName(
    dynamic db,
    String accountId,
    String searchTerm,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentMethodName LIKE ?',
      whereArgs: [accountId, '%$searchTerm%'],
      orderBy: 'isDefault DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payment methods by external key
  static Future<AccountPaymentMethodModel?> getByExternalKey(
    dynamic db,
    String externalKey,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'externalKey = ?',
      whereArgs: [externalKey],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Get payment methods by card brand
  static Future<List<AccountPaymentMethodModel>> getByCardBrand(
    dynamic db,
    String accountId,
    String cardBrand,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND cardBrand = ?',
      whereArgs: [accountId, cardBrand],
      orderBy: 'isDefault DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payment methods by bank name
  static Future<List<AccountPaymentMethodModel>> getByBankName(
    dynamic db,
    String accountId,
    String bankName,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND bankName = ?',
      whereArgs: [accountId, bankName],
      orderBy: 'isDefault DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}
