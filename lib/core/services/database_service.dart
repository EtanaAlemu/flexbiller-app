import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import 'database_table_manager.dart';
import 'database_table_config.dart';
import 'secure_storage_service.dart';
import 'package:logger/logger.dart';

@injectable
class DatabaseService {
  static Database? _database;
  static bool _isInitializing = false;
  final Logger _logger = Logger();
  final DatabaseTableManager _tableManager = DatabaseTableManager();
  final SecureStorageService _secureStorage;

  DatabaseService(this._secureStorage);

  Future<Database> get database async {
    if (_database != null) {
      // Verify database is still valid
      try {
        await _database!.rawQuery('SELECT 1');
        return _database!;
      } catch (e) {
        _logger.w('Database connection invalid, reinitializing...');
        _database = null;
      }
    }

    // Prevent concurrent initialization
    while (_isInitializing) {
      _logger.d('Database initialization already in progress, waiting...');
      // Wait a bit and check again
      await Future.delayed(const Duration(milliseconds: 100));
      // Check if another thread completed initialization
      if (_database != null) {
        try {
          await _database!.rawQuery('SELECT 1');
          return _database!;
        } catch (_) {
          // Database is invalid, continue with initialization
          _database = null;
        }
      }
    }

    _isInitializing = true;
    try {
      _database = await _initDatabase();
      return _database!;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = join(await getDatabasesPath(), AppConstants.databaseName);
    final dbFile = File(dbPath);
    final dbExists = await dbFile.exists();

    _logger.d('Initializing database at: $dbPath');

    // Get or generate encryption key securely
    final encryptionKey = await _getOrGenerateEncryptionKey();

    try {
      final database = await openDatabase(
        dbPath,
        version: AppConstants.databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        password: encryptionKey,
      );

      // Verify database is accessible by running a simple query
      try {
        await database.rawQuery('SELECT 1');
        _logger.d('Database initialized and verified successfully');
        return database;
      } catch (verifyError) {
        _logger.e('Database verification failed: $verifyError');
        try {
          await database.close();
        } catch (_) {
          // Ignore close errors
        }
        _database = null;
        rethrow;
      }
    } catch (e) {
      _logger.e('Error initializing database: $e');

      // Check if this is a database corruption/encryption error
      final errorMessage = e.toString().toLowerCase();
      final isCorruptionError =
          errorMessage.contains('sql logic error') ||
          errorMessage.contains('file is encrypted') ||
          errorMessage.contains('database disk image is malformed') ||
          errorMessage.contains('not a database');

      if (isCorruptionError && dbExists) {
        _logger.w(
          'Database appears to be corrupted or encrypted with wrong key. Attempting recovery...',
        );
        return await _recoverFromCorruption(dbPath, encryptionKey);
      }

      // If database doesn't exist and we still get an error, try to create it
      if (!dbExists) {
        _logger.w(
          'Database file does not exist, attempting to create new database...',
        );
        return await _createNewDatabase(dbPath, encryptionKey);
      }

      rethrow;
    }
  }

  /// Recover from database corruption by deleting and recreating
  Future<Database> _recoverFromCorruption(
    String dbPath,
    String encryptionKey,
  ) async {
    try {
      _logger.w('Deleting corrupted database file...');
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
        _logger.i('Corrupted database file deleted');
      }

      // Also delete any associated files (journal, wal, etc.)
      final dbDir = dbFile.parent;
      final dbNameWithoutExt = dbPath.split('/').last.split('.').first;
      final dbFiles = await dbDir.list().toList();
      for (final file in dbFiles) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          if (fileName.startsWith(dbNameWithoutExt)) {
            try {
              await file.delete();
              _logger.d('Deleted associated database file: $fileName');
            } catch (e) {
              _logger.w('Could not delete file $fileName: $e');
            }
          }
        }
      }

      _logger.i('Creating new database after corruption recovery...');
      return await _createNewDatabase(dbPath, encryptionKey);
    } catch (e) {
      _logger.e('Error during database recovery: $e');
      rethrow;
    }
  }

  /// Create a new database from scratch
  Future<Database> _createNewDatabase(
    String dbPath,
    String encryptionKey,
  ) async {
    try {
      _logger.d('Creating new database at: $dbPath');

      final database = await openDatabase(
        dbPath,
        version: AppConstants.databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        password: encryptionKey,
      );

      // Verify the new database
      await database.rawQuery('SELECT 1');
      _logger.i('New database created and verified successfully');
      return database;
    } catch (e) {
      _logger.e('Error creating new database: $e');
      rethrow;
    }
  }

  /// Get encryption key from secure storage, or generate a new one if it doesn't exist
  Future<String> _getOrGenerateEncryptionKey() async {
    try {
      // Try to retrieve existing key from secure storage
      final existingKey = await _secureStorage.read(
        AppConstants.databaseEncryptionKey,
      );

      if (existingKey != null && existingKey.isNotEmpty) {
        _logger.d(
          'Retrieved existing database encryption key from secure storage',
        );
        return existingKey;
      }

      // Generate a new secure encryption key
      _logger.d('Generating new database encryption key');
      final newKey = _generateEncryptionKey();

      // Store the new key in secure storage
      await _secureStorage.write(AppConstants.databaseEncryptionKey, newKey);

      _logger.i('Generated and stored new database encryption key');
      return newKey;
    } catch (e) {
      _logger.e('Error getting/generating encryption key: $e');
      // Fallback to a default key (not ideal, but better than crashing)
      // In production, this should never happen, but we need a fallback
      _logger.w(
        'Using fallback encryption key - this should not happen in production',
      );
      return _generateEncryptionKey();
    }
  }

  /// Generate a secure random encryption key
  /// Uses a combination of random bytes and base64 encoding for a strong key
  String _generateEncryptionKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    final key = base64Encode(keyBytes);
    return key;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      _logger.d('Creating database tables...');

      // Register all table configurations
      DatabaseTableConfig.registerAllTables();

      // Create all tables
      await _tableManager.ensureAllTablesExist(db);

      _logger.d('Database tables created successfully');
    } catch (e) {
      _logger.e('Error creating database tables: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      _logger.d('Upgrading database from version $oldVersion to $newVersion');

      // Register all table configurations
      DatabaseTableConfig.registerAllTables();

      // Ensure all tables exist (handles new tables)
      await _tableManager.ensureAllTablesExist(db);

      // Handle specific migrations based on version
      await _handleVersionMigrations(db, oldVersion, newVersion);

      _logger.d('Database upgrade completed successfully');
    } catch (e) {
      _logger.e('Error upgrading database: $e');
      rethrow;
    }
  }

  Future<void> _handleVersionMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Add user_id column to existing tables if needed
    if (oldVersion < 2) {
      await _addUserIdColumnToAllTables(db);
    }

    // Add invoice tables in version 15
    if (oldVersion < 15) {
      await _addInvoiceTables(db);
    }

    // Add more migrations as needed based on version numbers
    // if (oldVersion < 3) {
    //   await _migrateToVersion3(db);
    // }
  }

  Future<void> _addInvoiceTables(Database db) async {
    try {
      _logger.d(
        'Invoice tables migration for version 15 - tables already created by DatabaseTableManager',
      );
      _logger.d('Invoice tables migration completed successfully');
    } catch (e) {
      _logger.e('Error in invoice tables migration: $e');
      rethrow;
    }
  }

  Future<void> _addUserIdColumnToAllTables(Database db) async {
    try {
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
        'invoices',
        'invoice_audit_logs',
      ];

      for (final tableName in tables) {
        await _addUserIdColumnToTable(db, tableName);
      }
    } catch (e) {
      _logger.e('Error adding user_id column to all tables: $e');
      rethrow;
    }
  }

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

  /// Ensure a specific table exists (public method for external use)
  Future<void> ensureTableExists(String tableName) async {
    final db = await database;
    await _tableManager.ensureTableExists(db, tableName);
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;
      final tables = await _tableManager.getExistingTables(db);

      final stats = <String, dynamic>{
        'total_tables': tables.length,
        'tables': tables,
        'database_path': db.path,
        'database_version': await db.getVersion(),
      };

      return stats;
    } catch (e) {
      _logger.e('Error getting database stats: $e');
      rethrow;
    }
  }

  /// Check if database is empty
  Future<bool> isDatabaseEmpty() async {
    try {
      final db = await database;
      final tables = await _tableManager.getExistingTables(db);
      return tables.isEmpty;
    } catch (e) {
      _logger.e('Error checking if database is empty: $e');
      return true;
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      try {
        await _database!.close();
      } catch (e) {
        _logger.w('Error closing database: $e');
      } finally {
        _database = null;
        _isInitializing = false;
        _logger.d('Database connection closed');
      }
    }
  }
}
