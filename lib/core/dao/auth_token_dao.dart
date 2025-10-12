import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';

class AuthTokenDao {
  static const String tableName = 'auth_tokens';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnAccessToken = 'access_token';
  static const String columnRefreshToken = 'refresh_token';
  static const String columnExpiresAt = 'expires_at';
  static const String columnCreatedAt = 'created_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnUserId TEXT NOT NULL,
      $columnAccessToken TEXT NOT NULL,
      $columnRefreshToken TEXT NOT NULL,
      $columnExpiresAt TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES users (id) ON DELETE CASCADE
    )
  ''';

  /// Insert or update auth token
  static Future<void> insertOrUpdate(
    Database db,
    Map<String, dynamic> tokenData,
  ) async {
    try {
      await db.insert(
        tableName,
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

  /// Update auth token
  static Future<void> update(
    Database db,
    String userId,
    Map<String, dynamic> tokenData,
  ) async {
    try {
      await db.update(
        tableName,
        tokenData,
        where: '$columnUserId = ?',
        whereArgs: [userId],
      );
      _logger.d('Auth token updated successfully for user: $userId');
    } catch (e) {
      _logger.e('Error updating auth token: $e');
      rethrow;
    }
  }

  /// Get auth token by user ID
  static Future<Map<String, dynamic>?> getByUserId(
    Database db,
    String userId,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnUserId = ?',
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

  /// Delete auth token by user ID
  static Future<void> deleteByUserId(Database db, String userId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnUserId = ?',
        whereArgs: [userId],
      );
      _logger.d('Auth token deleted successfully for user: $userId');
    } catch (e) {
      _logger.e('Error deleting auth token: $e');
      rethrow;
    }
  }

  /// Delete all auth tokens
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All auth tokens deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all auth tokens: $e');
      rethrow;
    }
  }
}
