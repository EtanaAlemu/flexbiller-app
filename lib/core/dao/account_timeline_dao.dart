import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_timeline_model.dart';

class AccountTimelineDao {
  static final Logger _logger = Logger();
  static const String tableName = 'account_timelines';

  // Column names
  static const String columnId = 'id';
  static const String columnAccountId = 'account_id';
  static const String columnTimelineData = 'timeline_data';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status';

  static String get createTableSQL =>
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnTimelineData TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnSyncStatus TEXT NOT NULL
    )
  ''';

  static Map<String, dynamic> toMap(AccountTimelineModel timeline) {
    return {
      columnId: timeline.account.accountId, // Use account ID as primary key
      columnAccountId: timeline.account.accountId,
      columnTimelineData: jsonEncode(
        timeline.toJson(),
      ), // Store as proper JSON string
      columnCreatedAt: DateTime.now().toIso8601String(),
      columnUpdatedAt: DateTime.now().toIso8601String(),
      columnSyncStatus: 'synced',
    };
  }

  static AccountTimelineModel? fromMap(Map<String, dynamic> map) {
    try {
      // Get the JSON string from the database
      final timelineDataString = map[columnTimelineData] as String?;
      if (timelineDataString == null || timelineDataString.isEmpty) {
        return null;
      }

      // Parse the JSON string back to a Map
      final Map<String, dynamic> timelineData =
          jsonDecode(timelineDataString) as Map<String, dynamic>;

      // Use the fromJson factory to create the AccountTimelineModel
      return AccountTimelineModel.fromJson(timelineData);
    } catch (e) {
      // Log the error for debugging
      _logger.e('Error parsing AccountTimelineModel from database: $e');
      _logger.d('Raw data: ${map[columnTimelineData]}');
      return null;
    }
  }

  // Insert or update timeline
  static Future<void> insertOrUpdate(
    Database db,
    AccountTimelineModel timeline,
  ) async {
    await db.insert(
      tableName,
      toMap(timeline),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Delete timeline by account ID
  static Future<int> deleteByAccountId(Database db, String accountId) async {
    return await db.delete(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
    );
  }

  // Get timeline by account ID
  static Future<Map<String, dynamic>?> getByAccountId(
    Database db,
    String accountId,
  ) async {
    final maps = await db.query(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Get all timelines
  static Future<List<Map<String, dynamic>>> getAll(
    Database db, {
    String? orderBy,
  }) async {
    return await db.query(
      tableName,
      orderBy: orderBy ?? '$columnUpdatedAt DESC',
    );
  }

  // Get count of timelines
  static Future<int> getCount(Database db) async {
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Check if timelines exist
  static Future<bool> hasTimelines(Database db) async {
    final count = await getCount(db);
    return count > 0;
  }

  // Clear all timelines
  static Future<int> clearAll(Database db) async {
    return await db.delete(tableName);
  }

  // Check if timeline exists for account
  static Future<bool> hasTimelineForAccount(
    Database db,
    String accountId,
  ) async {
    final result = await db.query(
      tableName,
      where: '$columnAccountId = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
