import 'package:sqflite_sqlcipher/sqflite.dart';

class PaymentStatusOverviewDao {
  // Table name constant
  static const String tableName = 'payment_status_overview';

  // Column names constants
  static const String columnId = 'id';
  static const String columnYear = 'year';
  static const String columnMonth = 'month';
  static const String columnPaidInvoices = 'paid_invoices';
  static const String columnUnpaidInvoices = 'unpaid_invoices';
  static const String columnUpdatedAt = 'updated_at';

  // Create table SQL
  static String get createTableSQL =>
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnYear INTEGER NOT NULL,
      $columnMonth TEXT NOT NULL,
      $columnPaidInvoices INTEGER NOT NULL DEFAULT 0,
      $columnUnpaidInvoices INTEGER NOT NULL DEFAULT 0,
      $columnUpdatedAt TEXT NOT NULL,
      UNIQUE($columnYear, $columnMonth)
    )
  ''';

  // Convert map to database map
  static Map<String, dynamic> toMap(Map<String, dynamic> overviewData) {
    return {
      columnYear: overviewData[columnYear],
      columnMonth: overviewData[columnMonth],
      columnPaidInvoices: overviewData[columnPaidInvoices] ?? 0,
      columnUnpaidInvoices: overviewData[columnUnpaidInvoices] ?? 0,
      columnUpdatedAt:
          overviewData[columnUpdatedAt] ?? DateTime.now().toIso8601String(),
    };
  }

  // Get overview by year
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

  // Insert or replace overview for a year
  static Future<void> insertOrReplaceForYear(
    Database db,
    int year,
    List<Map<String, dynamic>> overviewsData,
  ) async {
    // Delete old data for this year first
    await db.delete(tableName, where: '$columnYear = ?', whereArgs: [year]);

    // Insert new data
    for (final overviewData in overviewsData) {
      await db.insert(
        tableName,
        toMap(overviewData),
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
