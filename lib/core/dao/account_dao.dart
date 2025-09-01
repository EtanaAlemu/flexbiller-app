import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_model.dart';

class AccountDao {
  // Table name constant
  static const String tableName = 'accounts';

  // Column names constants
  static const String columnAccountId = 'accountId';
  static const String columnName = 'name';
  static const String columnFirstNameLength = 'firstNameLength';
  static const String columnExternalKey = 'externalKey';
  static const String columnEmail = 'email';
  static const String columnBillCycleDayLocal = 'billCycleDayLocal';
  static const String columnCurrency = 'currency';
  static const String columnParentAccountId = 'parentAccountId';
  static const String columnIsPaymentDelegatedToParent = 'isPaymentDelegatedToParent';
  static const String columnPaymentMethodId = 'paymentMethodId';
  static const String columnReferenceTime = 'referenceTime';
  static const String columnTimeZone = 'timeZone';
  static const String columnAddress1 = 'address1';
  static const String columnAddress2 = 'address2';
  static const String columnPostalCode = 'postalCode';
  static const String columnCompany = 'company';
  static const String columnCity = 'city';
  static const String columnState = 'state';
  static const String columnCountry = 'country';
  static const String columnLocale = 'locale';
  static const String columnPhone = 'phone';
  static const String columnNotes = 'notes';
  static const String columnIsMigrated = 'isMigrated';
  static const String columnAccountBalance = 'accountBalance';
  static const String columnAccountCBA = 'accountCBA';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnSyncStatus = 'syncStatus';

  // Create table SQL
  static String get createTableSQL => '''
    CREATE TABLE $tableName (
      $columnAccountId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnFirstNameLength INTEGER,
      $columnExternalKey TEXT NOT NULL,
      $columnEmail TEXT NOT NULL,
      $columnBillCycleDayLocal INTEGER NOT NULL,
      $columnCurrency TEXT NOT NULL,
      $columnParentAccountId TEXT,
      $columnIsPaymentDelegatedToParent INTEGER NOT NULL,
      $columnPaymentMethodId TEXT,
      $columnReferenceTime TEXT NOT NULL,
      $columnTimeZone TEXT NOT NULL,
      $columnAddress1 TEXT,
      $columnAddress2 TEXT,
      $columnPostalCode TEXT,
      $columnCompany TEXT,
      $columnCity TEXT,
      $columnState TEXT,
      $columnCountry TEXT,
      $columnLocale TEXT,
      $columnPhone TEXT,
      $columnNotes TEXT,
      $columnIsMigrated INTEGER,
      $columnAccountBalance REAL,
      $columnAccountCBA REAL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL
    )
  ''';

  // Convert AccountModel to database map
  static Map<String, dynamic> toMap(AccountModel account) {
    return {
      columnAccountId: account.accountId,
      columnName: account.name,
      columnFirstNameLength: account.firstNameLength,
      columnExternalKey: account.externalKey,
      columnEmail: account.email,
      columnBillCycleDayLocal: account.billCycleDayLocal,
      columnCurrency: account.currency,
      columnParentAccountId: account.parentAccountId,
      columnIsPaymentDelegatedToParent: account.isPaymentDelegatedToParent ? 1 : 0,
      columnPaymentMethodId: account.paymentMethodId,
      columnReferenceTime: account.referenceTime.toIso8601String(),
      columnTimeZone: account.timeZone,
      columnAddress1: account.address1,
      columnAddress2: account.address2,
      columnPostalCode: account.postalCode,
      columnCompany: account.company,
      columnCity: account.city,
      columnState: account.state,
      columnCountry: account.country,
      columnLocale: account.locale,
      columnPhone: account.phone,
      columnNotes: account.notes,
      columnIsMigrated: account.isMigrated == true ? 1 : 0,
      columnAccountBalance: account.accountBalance,
      columnAccountCBA: account.accountCBA,
      columnCreatedAt: DateTime.now().toIso8601String(),
      columnUpdatedAt: DateTime.now().toIso8601String(),
      columnSyncStatus: 'synced',
    };
  }

  // Convert database map to AccountModel
  static AccountModel fromMap(Map<String, dynamic> map) {
    return AccountModel(
      accountId: map[columnAccountId] as String,
      name: map[columnName] as String,
      firstNameLength: map[columnFirstNameLength] as int?,
      externalKey: map[columnExternalKey] as String,
      email: map[columnEmail] as String,
      billCycleDayLocal: map[columnBillCycleDayLocal] as int,
      currency: map[columnCurrency] as String,
      parentAccountId: map[columnParentAccountId] as String?,
      isPaymentDelegatedToParent: map[columnIsPaymentDelegatedToParent] != null && (map[columnIsPaymentDelegatedToParent] as int) == 1,
      paymentMethodId: map[columnPaymentMethodId] as String?,
      referenceTime: DateTime.parse(map[columnReferenceTime] as String),
      timeZone: map[columnTimeZone] as String,
      address1: map[columnAddress1] as String?,
      address2: map[columnAddress2] as String?,
      postalCode: map[columnPostalCode] as String?,
      company: map[columnCompany] as String?,
      city: map[columnCity] as String?,
      state: map[columnState] as String?,
      country: map[columnCountry] as String?,
      locale: map[columnLocale] as String?,
      phone: map[columnPhone] as String?,
      notes: map[columnNotes] as String?,
      isMigrated: map[columnIsMigrated] != null && (map[columnIsMigrated] as int) == 1,
      accountBalance: (map[columnAccountBalance] as num?)?.toDouble(),
      accountCBA: (map[columnAccountCBA] as num?)?.toDouble(),
      auditLogs: const [], // Audit logs are stored separately
    );
  }

  // Insert or update account with conflict resolution
  static Future<void> insertOrUpdate(Database db, AccountModel account) async {
    final accountData = toMap(account);
    
    try {
      await db.insert(tableName, accountData, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      // If insert fails due to constraint, update instead
      await db.update(
        tableName,
        accountData,
        where: '$columnAccountId = ?',
        whereArgs: [account.accountId],
      );
    }
  }

  // Delete account by ID
  static Future<int> deleteById(Database db, String accountId) async {
    return await db.delete(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
    );
  }

  // Get account by ID
  static Future<AccountModel?> getById(Database db, String accountId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Get all accounts with optional ordering
  static Future<List<AccountModel>> getAll(Database db, {String? orderBy}) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: orderBy ?? '$columnName ASC',
    );
    
    return maps.map((map) => fromMap(map)).toList();
  }

  // Search accounts by multiple fields
  static Future<List<AccountModel>> search(Database db, String searchKey) async {
    final searchPattern = '%$searchKey%';
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnName LIKE ? OR $columnEmail LIKE ? OR $columnCompany LIKE ? OR $columnExternalKey LIKE ?',
      whereArgs: [searchPattern, searchPattern, searchPattern, searchPattern],
      orderBy: '$columnName ASC',
    );
    
    return maps.map((map) => fromMap(map)).toList();
  }

  // Get accounts count
  static Future<int> getCount(Database db) async {
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return result.first['count'] as int;
  }

  // Check if accounts exist
  static Future<bool> hasAccounts(Database db) async {
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    final count = result.first['count'] as int;
    return count > 0;
  }

  // Clear all accounts
  static Future<int> clearAll(Database db) async {
    return await db.delete(tableName);
  }

  // Get accounts with pagination and query parameters
  static Future<List<AccountModel>> getByQuery(
    Database db, {
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: orderBy ?? '$columnName ASC',
      limit: limit,
      offset: offset,
    );
    
    return maps.map((map) => fromMap(map)).toList();
  }
}
