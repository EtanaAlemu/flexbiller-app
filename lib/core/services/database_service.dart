import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import 'database_table_manager.dart';
import 'database_table_config.dart';
import 'package:logger/logger.dart';

@injectable
class DatabaseService {
  static Database? _database;
  static const String _encryptionKey = 'your-secure-encryption-key-here';
  final Logger _logger = Logger();
  final DatabaseTableManager _tableManager = DatabaseTableManager();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = join(await getDatabasesPath(), AppConstants.databaseName);

      _logger.d('Initializing database at: $dbPath');

      final database = await openDatabase(
        dbPath,
        version: AppConstants.databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        password: _encryptionKey,
      );

      _logger.d('Database initialized successfully');
      return database;
    } catch (e) {
      _logger.e('Error initializing database: $e');
      rethrow;
    }
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
      await _database!.close();
      _database = null;
      _logger.d('Database connection closed');
    }
  }
}
