import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';

class UserDao {
  static const String tableName = 'users';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnId = 'id';
  static const String columnEmail = 'email';
  static const String columnName = 'name';
  static const String columnRole = 'role';
  static const String columnPhone = 'phone';
  static const String columnTenantId = 'tenant_id';
  static const String columnRoleId = 'role_id';
  static const String columnApiKey = 'api_key';
  static const String columnApiSecret = 'api_secret';
  static const String columnEmailVerified = 'email_verified';
  static const String columnFirstName = 'first_name';
  static const String columnLastName = 'last_name';
  static const String columnCompany = 'company';
  static const String columnDepartment = 'department';
  static const String columnLocation = 'location';
  static const String columnPosition = 'position';
  static const String columnSessionId = 'session_id';
  static const String columnIsAnonymous = 'is_anonymous';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnEmail TEXT UNIQUE NOT NULL,
      $columnName TEXT NOT NULL,
      $columnRole TEXT NOT NULL,
      $columnPhone TEXT,
      $columnTenantId TEXT,
      $columnRoleId TEXT,
      $columnApiKey TEXT,
      $columnApiSecret TEXT,
      $columnEmailVerified INTEGER DEFAULT 0,
      $columnFirstName TEXT,
      $columnLastName TEXT,
      $columnCompany TEXT,
      $columnDepartment TEXT,
      $columnLocation TEXT,
      $columnPosition TEXT,
      $columnSessionId TEXT,
      $columnIsAnonymous INTEGER DEFAULT 0,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  /// Insert or update a user
  static Future<void> insertOrUpdate(
    Database db,
    Map<String, dynamic> userData,
  ) async {
    try {
      await db.insert(
        tableName,
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d('User inserted/updated successfully: ${userData['email']}');
    } catch (e) {
      _logger.e('Error inserting user: $e');
      rethrow;
    }
  }

  /// Update a user
  static Future<void> update(
    Database db,
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      userData[columnUpdatedAt] = DateTime.now().toIso8601String();
      await db.update(
        tableName,
        userData,
        where: '$columnId = ?',
        whereArgs: [userId],
      );
      _logger.d('User updated successfully: $userId');
    } catch (e) {
      _logger.e('Error updating user: $e');
      rethrow;
    }
  }

  /// Get user by ID
  static Future<Map<String, dynamic>?> getById(
    Database db,
    String userId,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnId = ?',
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

  /// Get user by email
  static Future<Map<String, dynamic>?> getByEmail(
    Database db,
    String email,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnEmail = ?',
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

  /// Get all users
  static Future<List<Map<String, dynamic>>> getAll(Database db) async {
    try {
      final results = await db.query(tableName);
      _logger.d('Retrieved ${results.length} users');
      return results;
    } catch (e) {
      _logger.e('Error retrieving all users: $e');
      rethrow;
    }
  }

  /// Delete user by ID
  static Future<void> deleteById(Database db, String userId) async {
    try {
      await db.delete(tableName, where: '$columnId = ?', whereArgs: [userId]);
      _logger.d('User deleted successfully: $userId');
    } catch (e) {
      _logger.e('Error deleting user: $e');
      rethrow;
    }
  }

  /// Delete all users
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All users deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all users: $e');
      rethrow;
    }
  }
}
