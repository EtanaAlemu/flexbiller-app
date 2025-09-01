import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../dao/account_dao.dart';
import 'package:logger/logger.dart';

@injectable
class DatabaseService {
  static Database? _database;
  static const String _encryptionKey = 'your-secure-encryption-key-here';
  final Logger _logger = Logger();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
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

      _logger.d('Database tables created successfully');
    } catch (e) {
      _logger.e('Error creating database tables: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      _logger.d('Upgrading database from version $oldVersion to $newVersion');

      if (oldVersion < 2) {
        // Add new columns or tables for version 2
        // await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
      }

      _logger.d('Database upgrade completed');
    } catch (e) {
      _logger.e('Error upgrading database: $e');
      rethrow;
    }
  }

  // User CRUD operations
  Future<void> insertUser(Map<String, dynamic> userData) async {
    try {
      final db = await database;
      await db.insert('users', userData);
      _logger.d('User inserted successfully: ${userData['email']}');
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
      await db.insert('auth_tokens', tokenData);
      _logger.d(
        'Auth token inserted successfully for user: ${tokenData['user_id']}',
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
}
