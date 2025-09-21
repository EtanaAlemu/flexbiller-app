import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../dao/account_dao.dart';
import '../dao/child_account_dao.dart';
import '../dao/account_timeline_dao.dart';
import '../dao/account_tag_dao.dart';
import '../dao/account_audit_log_dao.dart';
import '../dao/account_blocking_state_dao.dart';
import '../dao/account_custom_field_dao.dart';
import '../dao/account_email_dao.dart';
import '../dao/account_invoice_payment_dao.dart';
import '../dao/account_payment_method_dao.dart';
import '../dao/account_payment_dao.dart';
import '../dao/account_invoices_dao.dart';
import 'package:logger/logger.dart';

@injectable
class DatabaseService {
  static Database? _database;
  static const String _encryptionKey = 'your-secure-encryption-key-here';
  final Logger _logger = Logger();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    // Ensure accounts table exists after database initialization
    await _ensureAccountsTableExists();

    // Ensure child_accounts table exists after database initialization
    await _ensureChildAccountsTableExists();

    // Ensure account_timelines table exists after database initialization
    await _ensureAccountTimelinesTableExists();

    // Ensure account_tags table exists after database initialization
    await _ensureAccountTagsTableExists();

    // Ensure account_audit_logs table exists after database initialization
    await _ensureAccountAuditLogsTableExists();

    // Ensure account_blocking_states table exists after database initialization
    await _ensureAccountBlockingStatesTableExists();

    // Ensure account_custom_fields table exists after database initialization
    await _ensureAccountCustomFieldsTableExists();

    // Ensure account_emails table exists after database initialization
    await _ensureAccountEmailsTableExists();

    // Ensure account_invoice_payments table exists after database initialization
    await _ensureAccountInvoicePaymentsTableExists();

    // Ensure account_payment_methods table exists after database initialization
    await _ensureAccountPaymentMethodsTableExists();

    // Ensure account_payments table exists after database initialization
    await _ensureAccountPaymentsTableExists();

    // Ensure account_invoices table exists after database initialization
    await _ensureAccountInvoicesTableExists();

    // Ensure subscriptions table exists after database initialization
    await _ensureSubscriptionsTableExists();

    // Ensure sync_metadata table exists after database initialization
    await _ensureSyncMetadataTableExists();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConstants.databaseName);

      _logger.d('Initializing database at: $path');

      // Check if database exists
      final exists = await databaseExists(path);

      if (!exists) {
        _logger.d('Creating new database...');
        // Create database
        return await openDatabase(
          path,
          version: AppConstants.databaseVersion,
          onCreate: _onCreate,
          password: _encryptionKey,
        );
      } else {
        _logger.d('Opening existing database...');
        // Open existing database
        return await openDatabase(
          path,
          version: AppConstants.databaseVersion,
          onUpgrade: _onUpgrade,
          password: _encryptionKey,
        );
      }
    } catch (e) {
      _logger.e('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      _logger.d('Creating database tables...');

      // Create users table with comprehensive fields
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          phone TEXT,
          tenant_id TEXT,
          role_id TEXT,
          api_key TEXT,
          api_secret TEXT,
          email_verified INTEGER DEFAULT 0,
          first_name TEXT,
          last_name TEXT,
          company TEXT,
          department TEXT,
          location TEXT,
          position TEXT,
          session_id TEXT,
          is_anonymous INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Create auth_tokens table
      await db.execute('''
        CREATE TABLE auth_tokens (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          access_token TEXT NOT NULL,
          refresh_token TEXT NOT NULL,
          expires_at TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // Create billing_records table
      await db.execute('''
        CREATE TABLE billing_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          amount REAL NOT NULL,
          description TEXT,
          due_date TEXT,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // Create accounts table
      await db.execute(AccountDao.createTableSQL);

      // Create child_accounts table
      await db.execute(ChildAccountDao.createTableSQL);

      // Create account_timelines table
      await db.execute(AccountTimelineDao.createTableSQL);

      // Create account_tags table
      await db.execute(AccountTagDao.createTableSQL);

      // Create account_audit_logs table
      await db.execute(AccountAuditLogDao.createTableSQL);

      // Create account_blocking_states table
      await db.execute(AccountBlockingStateDao.createTableSQL);

      // Create account_custom_fields table
      await db.execute(AccountCustomFieldDao.createTableSQL);

      // Create account_emails table
      await db.execute(AccountEmailDao.createTableSQL);

      // Create account_invoice_payments table
      await db.execute(AccountInvoicePaymentDao.createTableSQL);

      // Create account_payment_methods table
      await db.execute(AccountPaymentMethodDao.createTableSQL);

      // Create account_payments table
      await db.execute(AccountPaymentDao.createTableSQL);

      // Create account_invoices table
      await db.execute(AccountInvoicesDao.createTableSQL);

      _logger.d('Database tables created successfully');
    } catch (e) {
      _logger.e('Error creating database tables: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.d('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      // Create child_accounts table
      await db.execute(ChildAccountDao.createTableSQL);
      _logger.d('Created child_accounts table');
    }

    if (oldVersion < 3) {
      // Create account_timeline table
      await db.execute(AccountTimelineDao.createTableSQL);
      _logger.d('Created account_timeline table');
    }

    if (oldVersion < 4) {
      // Create account_tags table
      await db.execute(AccountTagDao.createTableSQL);
      _logger.d('Created account_tags table');
    }

    if (oldVersion < 5) {
      // Create account_audit_logs table
      await db.execute(AccountAuditLogDao.createTableSQL);
      _logger.d('Created account_audit_logs table');
    }

    if (oldVersion < 6) {
      // Create account_audit_logs table (if not already created)
      await _ensureAccountAuditLogsTableExists();
      _logger.d('Ensured account_audit_logs table exists');
    }

    if (oldVersion < 7) {
      // Create account_blocking_states table
      await db.execute(AccountBlockingStateDao.createTableSQL);
      _logger.d('Created account_blocking_states table');
    }

    if (oldVersion < 8) {
      // Create account_custom_fields table
      await db.execute(AccountCustomFieldDao.createTableSQL);
      _logger.d('Created account_custom_fields table');
    }

    if (oldVersion < 9) {
      // Create account_emails table
      await db.execute(AccountEmailDao.createTableSQL);
      _logger.d('Created account_emails table');
    }

    if (oldVersion < 10) {
      // Create account_invoice_payments table
      await db.execute(AccountInvoicePaymentDao.createTableSQL);
      _logger.d('Created account_invoice_payments table');
    }

    if (oldVersion < 11) {
      // Create account_payment_methods table
      await db.execute(AccountPaymentMethodDao.createTableSQL);
      _logger.d('Created account_payment_methods table');
    }

    if (oldVersion < 12) {
      // Create account_payments table
      await db.execute(AccountPaymentDao.createTableSQL);
      _logger.d('Created account_payments table');
    }

    if (oldVersion < 13) {
      // Create account_invoices table
      await db.execute(AccountInvoicesDao.createTableSQL);
      _logger.d('Created account_invoices table');
    }

    if (oldVersion < 14) {
      // Create account_invoices table (if not already created)
      await _ensureAccountInvoicesTableExists();
      _logger.d('Ensured account_invoices table exists');

      // Add user_id column to all tables for user-specific data isolation
      await _addUserIdColumnToAllTables(db);
      _logger.d('Added user_id column to all tables');
    }

    _logger.d('Database upgrade completed successfully');
  }

  // Add user_id column to all tables for user-specific data isolation
  Future<void> _addUserIdColumnToAllTables(Database db) async {
    try {
      // List of all tables that need user_id column
      final tables = [
        'accounts',
        'child_accounts',
        'account_audit_logs',
        'account_blocking_states',
        'account_custom_fields',
        'account_emails',
        'account_invoice_payments',
        'account_invoices',
        'account_payment_methods',
        'account_payments',
        'account_tags',
        'account_timelines',
      ];

      for (final tableName in tables) {
        await _addUserIdColumnToTable(db, tableName);
      }
    } catch (e) {
      _logger.e('Error adding user_id column to all tables: $e');
      rethrow;
    }
  }

  // Add user_id column to a specific table
  Future<void> _addUserIdColumnToTable(Database db, String tableName) async {
    try {
      // Check if table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );

      if (tables.isEmpty) {
        _logger.d('Table $tableName does not exist, skipping...');
        return;
      }

      // Check if user_id column already exists
      final columns = await db.rawQuery('PRAGMA table_info($tableName)');
      final hasUserIdColumn = columns.any(
        (column) => column['name'] == 'user_id',
      );

      if (!hasUserIdColumn) {
        _logger.d('Adding user_id column to $tableName table...');

        // Add user_id column
        await db.execute('ALTER TABLE $tableName ADD COLUMN user_id TEXT');

        _logger.d('user_id column added to $tableName table successfully');
      } else {
        _logger.d('user_id column already exists in $tableName table');
      }
    } catch (e) {
      _logger.e('Error adding user_id column to $tableName table: $e');
      // Don't rethrow - continue with other tables
    }
  }

  // Check and create accounts table if it doesn't exist
  Future<void> _ensureAccountsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'accounts'],
      );

      if (tables.isEmpty) {
        _logger.d('Accounts table does not exist, creating it...');
        await db.execute(AccountDao.createTableSQL);
        _logger.d('Accounts table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring accounts table exists: $e');
      rethrow;
    }
  }

  // Check and create account_invoices table if it doesn't exist
  Future<void> _ensureAccountInvoicesTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_invoices'],
      );

      if (tables.isEmpty) {
        _logger.d('Account_invoices table does not exist, creating it...');
        await db.execute(AccountInvoicesDao.createTableSQL);
        _logger.d('Account_invoices table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account_invoices table exists: $e');
      rethrow;
    }
  }

  // Check and create child_accounts table if it doesn't exist
  Future<void> _ensureChildAccountsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'child_accounts'],
      );

      if (tables.isEmpty) {
        _logger.d('Child accounts table does not exist, creating it...');
        await db.execute(ChildAccountDao.createTableSQL);
        _logger.d('Child accounts table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring child accounts table exists: $e');
      rethrow;
    }
  }

  // Check and create account_timelines table if it doesn't exist
  Future<void> _ensureAccountTimelinesTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_timelines'],
      );

      if (tables.isEmpty) {
        _logger.d('Account timelines table does not exist, creating it...');
        await db.execute(AccountTimelineDao.createTableSQL);
        _logger.d('Account timelines table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account timelines table exists: $e');
      rethrow;
    }
  }

  // Check and create account_tags table if it doesn't exist
  Future<void> _ensureAccountTagsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_tags'],
      );

      if (tables.isEmpty) {
        _logger.d('Account tags table does not exist, creating it...');
        await db.execute(AccountTagDao.createTableSQL);
        _logger.d('Account tags table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account tags table exists: $e');
      rethrow;
    }
  }

  // Check and create account_audit_logs table if it doesn't exist
  Future<void> _ensureAccountAuditLogsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_audit_logs'],
      );

      if (tables.isEmpty) {
        _logger.d('Account audit logs table does not exist, creating it...');
        await db.execute(AccountAuditLogDao.createTableSQL);
        _logger.d('Account audit logs table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account audit logs table exists: $e');
      rethrow;
    }
  }

  Future<void> _ensureAccountBlockingStatesTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_blocking_states'],
      );

      if (tables.isEmpty) {
        _logger.d(
          'Account blocking states table does not exist, creating it...',
        );
        await db.execute(AccountBlockingStateDao.createTableSQL);
        _logger.d('Account blocking states table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account blocking states table exists: $e');
      rethrow;
    }
  }

  Future<void> _ensureAccountCustomFieldsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_custom_fields'],
      );

      if (tables.isEmpty) {
        _logger.d('Account custom fields table does not exist, creating it...');
        await db.execute(AccountCustomFieldDao.createTableSQL);
        _logger.d('Account custom fields table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account custom fields table exists: $e');
      rethrow;
    }
  }

  Future<void> _ensureAccountEmailsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_emails'],
      );

      if (tables.isEmpty) {
        _logger.d('Account emails table does not exist, creating it...');
        await db.execute(AccountEmailDao.createTableSQL);
        _logger.d('Account emails table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account emails table exists: $e');
      rethrow;
    }
  }

  // Check and create account_invoice_payments table if it doesn't exist
  Future<void> _ensureAccountInvoicePaymentsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_invoice_payments'],
      );

      if (tables.isEmpty) {
        _logger.d(
          'Account invoice payments table does not exist, creating it...',
        );
        await db.execute(AccountInvoicePaymentDao.createTableSQL);
        _logger.d('Account invoice payments table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account invoice payments table exists: $e');
      rethrow;
    }
  }

  // Check and create account_payment_methods table if it doesn't exist
  Future<void> _ensureAccountPaymentMethodsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_payment_methods'],
      );

      if (tables.isEmpty) {
        _logger.d(
          'Account payment methods table does not exist, creating it...',
        );
        await db.execute(AccountPaymentMethodDao.createTableSQL);
        _logger.d('Account payment methods table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring account payment methods table exists: $e');
      rethrow;
    }
  }

  // Check and create account_payments table if it doesn't exist
  Future<void> _ensureAccountPaymentsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'account_payments'],
      );

      if (tables.isEmpty) {
        _logger.d('Account payments table does not exist, creating it...');
        await db.execute(AccountPaymentDao.createTableSQL);
        _logger.d('Account payments table created successfully');
      } else {
        // Table exists, check if we need to migrate schema
        await _migrateAccountPaymentsTable(db);
      }
    } catch (e) {
      _logger.e('Error ensuring account payments table exists: $e');
      rethrow;
    }
  }

  Future<void> _migrateAccountPaymentsTable(Database db) async {
    try {
      // Check current table structure
      final columns = await db.rawQuery('PRAGMA table_info(account_payments)');
      final columnNames = columns.map((col) => col['name'] as String).toList();
      _logger.d('Current account_payments columns: $columnNames');

      // List of required columns for the new schema
      final requiredColumns = [
        'paymentNumber',
        'paymentExternalKey',
        'authAmount',
        'capturedAmount',
        'purchasedAmount',
        'refundedAmount',
        'creditedAmount',
        'transactions',
        'paymentAttempts',
        'auditLogs',
      ];

      // Check which columns are missing
      final missingColumns = requiredColumns
          .where((col) => !columnNames.contains(col))
          .toList();

      if (missingColumns.isNotEmpty) {
        _logger.d(
          'Migrating account_payments table to add missing columns: $missingColumns',
        );

        // Add missing columns one by one
        for (final column in missingColumns) {
          try {
            String alterStatement;
            switch (column) {
              case 'paymentNumber':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN paymentNumber TEXT';
                break;
              case 'paymentExternalKey':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN paymentExternalKey TEXT';
                break;
              case 'authAmount':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN authAmount REAL NOT NULL DEFAULT 0';
                break;
              case 'capturedAmount':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN capturedAmount REAL NOT NULL DEFAULT 0';
                break;
              case 'purchasedAmount':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN purchasedAmount REAL NOT NULL DEFAULT 0';
                break;
              case 'refundedAmount':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN refundedAmount REAL NOT NULL DEFAULT 0';
                break;
              case 'creditedAmount':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN creditedAmount REAL NOT NULL DEFAULT 0';
                break;
              case 'transactions':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN transactions TEXT NOT NULL DEFAULT "[]"';
                break;
              case 'paymentAttempts':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN paymentAttempts TEXT';
                break;
              case 'auditLogs':
                alterStatement =
                    'ALTER TABLE account_payments ADD COLUMN auditLogs TEXT';
                break;
              default:
                _logger.w('Unknown column for migration: $column');
                continue;
            }

            _logger.d('Adding column: $column');
            await db.execute(alterStatement);
            _logger.d('Successfully added column: $column');
          } catch (e) {
            _logger.e('Error adding column $column: $e');
            // Continue with other columns even if one fails
          }
        }

        _logger.d('Account payments table migration completed');
      } else {
        _logger.d('Account payments table is already up to date');
      }
    } catch (e) {
      _logger.e('Error migrating account_payments table: $e');
      // Don't rethrow - migration errors shouldn't break the app
    }
  }

  // User CRUD operations
  Future<void> insertUser(Map<String, dynamic> userData) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d('User inserted/updated successfully: ${userData['email']}');
    } catch (e) {
      _logger.e('Error inserting user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final db = await database;
      userData['updated_at'] = DateTime.now().toIso8601String();
      await db.update('users', userData, where: 'id = ?', whereArgs: [userId]);
      _logger.d('User updated successfully: $userId');
    } catch (e) {
      _logger.e('Error updating user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (results.isNotEmpty) {
        _logger.d('User retrieved successfully: $userId');
        return results.first;
      }

      _logger.d('User not found: $userId');
      return null;
    } catch (e) {
      _logger.e('Error retrieving user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isNotEmpty) {
        _logger.d('User retrieved by email successfully: $email');
        return results.first;
      }

      _logger.d('User not found by email: $email');
      return null;
    } catch (e) {
      _logger.e('Error retrieving user by email: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = await database;
      final results = await db.query('users');
      _logger.d('Retrieved ${results.length} users');
      return results;
    } catch (e) {
      _logger.e('Error retrieving all users: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final db = await database;
      await db.delete('users', where: 'id = ?', whereArgs: [userId]);
      _logger.d('User deleted successfully: $userId');
    } catch (e) {
      _logger.e('Error deleting user: $e');
      rethrow;
    }
  }

  Future<void> deleteAllUsers() async {
    try {
      final db = await database;
      await db.delete('users');
      _logger.d('All users deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all users: $e');
      rethrow;
    }
  }

  // Auth token operations
  Future<void> insertAuthToken(Map<String, dynamic> tokenData) async {
    try {
      final db = await database;
      await db.insert(
        'auth_tokens',
        tokenData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d(
        'Auth token inserted/updated successfully for user: ${tokenData['user_id']}',
      );
    } catch (e) {
      _logger.e('Error inserting auth token: $e');
      rethrow;
    }
  }

  Future<void> updateAuthToken(
    String userId,
    Map<String, dynamic> tokenData,
  ) async {
    try {
      final db = await database;
      await db.update(
        'auth_tokens',
        tokenData,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      _logger.d('Auth token updated successfully for user: $userId');
    } catch (e) {
      _logger.e('Error updating auth token: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getAuthTokenByUserId(String userId) async {
    try {
      final db = await database;
      final results = await db.query(
        'auth_tokens',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (results.isNotEmpty) {
        _logger.d('Auth token retrieved successfully for user: $userId');
        return results.first;
      }

      _logger.d('Auth token not found for user: $userId');
      return null;
    } catch (e) {
      _logger.e('Error retrieving auth token: $e');
      rethrow;
    }
  }

  Future<void> deleteAuthToken(String userId) async {
    try {
      final db = await database;
      await db.delete('auth_tokens', where: 'user_id = ?', whereArgs: [userId]);
      _logger.d('Auth token deleted successfully for user: $userId');
    } catch (e) {
      _logger.e('Error deleting auth token: $e');
      rethrow;
    }
  }

  Future<void> deleteAllAuthTokens() async {
    try {
      final db = await database;
      await db.delete('auth_tokens');
      _logger.d('All auth tokens deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all auth tokens: $e');
      rethrow;
    }
  }

  /// Clear all data from the database
  Future<void> clearAllData() async {
    try {
      final db = await database;

      // Clear all tables
      await db.delete('users');
      await db.delete('auth_tokens');

      _logger.d('All data cleared from database');
    } catch (e) {
      _logger.e('Error clearing all data: $e');
      rethrow;
    }
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.d('Database closed');
    }
  }

  // Delete database
  Future<void> deleteDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConstants.databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      _logger.d('Database deleted successfully');
    } catch (e) {
      _logger.e('Error deleting database: $e');
      rethrow;
    }
  }

  // Helper method to execute raw SQL
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object>? arguments,
  ]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      _logger.e('Error executing raw query: $e');
      rethrow;
    }
  }

  // Helper method to execute raw SQL without returning results
  Future<void> rawExecute(String sql, [List<Object>? arguments]) async {
    try {
      final db = await database;
      await db.execute(sql, arguments);
      _logger.d('Raw SQL executed successfully');
    } catch (e) {
      _logger.e('Error executing raw SQL: $e');
      rethrow;
    }
  }

  // Check if database is empty
  Future<bool> isDatabaseEmpty() async {
    try {
      final users = await getAllUsers();
      return users.isEmpty;
    } catch (e) {
      _logger.e('Error checking if database is empty: $e');
      return true;
    }
  }

  // Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final db = await database;
      final userCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM users'),
          ) ??
          0;

      final tokenCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM auth_tokens'),
          ) ??
          0;

      final billingCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM billing_records'),
          ) ??
          0;

      return {
        'users': userCount,
        'auth_tokens': tokenCount,
        'billing_records': billingCount,
      };
    } catch (e) {
      _logger.e('Error getting database stats: $e');
      return {'users': 0, 'auth_tokens': 0, 'billing_records': 0};
    }
  }

  // Ensure subscriptions table exists
  Future<void> _ensureSubscriptionsTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'subscriptions'],
      );

      if (tables.isEmpty) {
        _logger.d('Subscriptions table does not exist, creating it...');
        await db.execute('''
          CREATE TABLE subscriptions (
            subscription_id TEXT PRIMARY KEY,
            account_id TEXT NOT NULL,
            bundle_id TEXT NOT NULL,
            bundle_external_key TEXT NOT NULL,
            external_key TEXT NOT NULL,
            start_date TEXT NOT NULL,
            product_name TEXT NOT NULL,
            product_category TEXT NOT NULL,
            billing_period TEXT NOT NULL,
            phase_type TEXT NOT NULL,
            price_list TEXT NOT NULL,
            plan_name TEXT NOT NULL,
            state TEXT NOT NULL,
            source_type TEXT NOT NULL,
            cancelled_date TEXT,
            charged_through_date TEXT NOT NULL,
            billing_start_date TEXT NOT NULL,
            billing_end_date TEXT,
            bill_cycle_day_local INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            events TEXT NOT NULL,
            price_overrides TEXT,
            prices TEXT NOT NULL,
            audit_logs TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        _logger.d('Subscriptions table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring subscriptions table exists: $e');
      rethrow;
    }
  }

  // Ensure sync_metadata table exists
  Future<void> _ensureSyncMetadataTableExists() async {
    try {
      final db = await database;
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'sync_metadata'],
      );

      if (tables.isEmpty) {
        _logger.d('Sync_metadata table does not exist, creating it...');
        await db.execute('''
          CREATE TABLE sync_metadata (
            table_name TEXT PRIMARY KEY,
            last_sync TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        _logger.d('Sync_metadata table created successfully');
      }
    } catch (e) {
      _logger.e('Error ensuring sync_metadata table exists: $e');
      rethrow;
    }
  }
}
