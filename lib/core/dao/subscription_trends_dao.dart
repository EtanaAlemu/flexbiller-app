import 'package:sqflite_sqlcipher/sqflite.dart';

class SubscriptionTrendsDao {
  // Table name constant
  static const String tableName = 'subscription_trends';

  // Column names constants
  static const String columnId = 'id';
  static const String columnYear = 'year';
  static const String columnMonth = 'month';
  static const String columnNewSubscriptions = 'new_subscriptions';
  static const String columnChurnedSubscriptions = 'churned_subscriptions';
  static const String columnRevenue = 'revenue';
  static const String columnUpdatedAt = 'updated_at';

  // Create table SQL
  static String get createTableSQL =>
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnYear INTEGER NOT NULL,
      $columnMonth TEXT NOT NULL,
      $columnNewSubscriptions INTEGER NOT NULL DEFAULT 0,
      $columnChurnedSubscriptions INTEGER NOT NULL DEFAULT 0,
      $columnRevenue REAL NOT NULL DEFAULT 0.0,
      $columnUpdatedAt TEXT NOT NULL,
      UNIQUE($columnYear, $columnMonth)
    )
  ''';

  // Convert map to database map
  static Map<String, dynamic> toMap(Map<String, dynamic> trendData) {
    return {
      columnYear: trendData[columnYear],
      columnMonth: trendData[columnMonth],
      columnNewSubscriptions: trendData[columnNewSubscriptions] ?? 0,
      columnChurnedSubscriptions: trendData[columnChurnedSubscriptions] ?? 0,
      columnRevenue: trendData[columnRevenue] ?? 0.0,
      columnUpdatedAt:
          trendData[columnUpdatedAt] ?? DateTime.now().toIso8601String(),
    };
  }

  // Get trends by year
  static Future<List<Map<String, dynamic>>> getByYear(
    Database db,
    int year,
  ) async {
    return await db.query(
      tableName,
      where: '$columnYear = ?',
      whereArgs: [year],
      orderBy: '$columnMonth ASC',
    );
  }

  // Insert or replace trends for a year
  static Future<void> insertOrReplaceForYear(
    Database db,
    int year,
    List<Map<String, dynamic>> trendsData,
  ) async {
    // Delete old data for this year first
    await db.delete(tableName, where: '$columnYear = ?', whereArgs: [year]);

    // Insert new data
    for (final trendData in trendsData) {
      await db.insert(
        tableName,
        toMap(trendData),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Check if table exists
  static Future<bool> tableExists(Database db) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }
}
