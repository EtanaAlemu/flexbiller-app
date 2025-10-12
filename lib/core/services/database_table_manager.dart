import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';

/// Configuration for database tables
class TableConfig {
  final String tableName;
  final String createTableSQL;
  final String? createIndexesSQL;
  final List<String>? dependencies;

  const TableConfig({
    required this.tableName,
    required this.createTableSQL,
    this.createIndexesSQL,
    this.dependencies,
  });
}

/// Registry of all database tables and their configurations
class DatabaseTableRegistry {
  static final Map<String, TableConfig> _tables = {};

  static void registerTable(TableConfig config) {
    _tables[config.tableName] = config;
  }

  static Map<String, TableConfig> get allTables => Map.unmodifiable(_tables);

  static List<String> get tableNames => _tables.keys.toList();

  static TableConfig? getTableConfig(String tableName) => _tables[tableName];
}

/// Generic table manager that handles all table operations
class DatabaseTableManager {
  final Logger _logger = Logger();

  /// Ensure a specific table exists
  Future<void> ensureTableExists(Database db, String tableName) async {
    try {
      final config = DatabaseTableRegistry.getTableConfig(tableName);
      if (config == null) {
        _logger.w('Table configuration not found for: $tableName');
        return;
      }

      final exists = await _tableExists(db, tableName);
      if (!exists) {
        _logger.d('Creating table: $tableName');
        await db.execute(config.createTableSQL);

        if (config.createIndexesSQL != null) {
          await db.execute(config.createIndexesSQL!);
        }

        _logger.d('Table created successfully: $tableName');
      }
    } catch (e) {
      _logger.e('Error ensuring table exists ($tableName): $e');
      rethrow;
    }
  }

  /// Ensure all registered tables exist
  Future<void> ensureAllTablesExist(Database db) async {
    final tableNames = DatabaseTableRegistry.tableNames;

    for (final tableName in tableNames) {
      await ensureTableExists(db, tableName);
    }
  }

  /// Check if a table exists
  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Get all existing tables
  Future<List<String>> getExistingTables(Database db) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    return result.map((row) => row['name'] as String).toList();
  }
}
