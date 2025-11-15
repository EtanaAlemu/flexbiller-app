import 'package:sqflite_sqlcipher/sqflite.dart';

class DashboardKPIsDao {
  // Table name constant
  static const String tableName = 'dashboard_kpis';

  // Column names constants
  static const String columnId = 'id';
  static const String columnActiveSubscriptionsValue =
      'active_subscriptions_value';
  static const String columnActiveSubscriptionsChange =
      'active_subscriptions_change';
  static const String columnActiveSubscriptionsChangePercent =
      'active_subscriptions_change_percent';
  static const String columnPendingInvoicesValue = 'pending_invoices_value';
  static const String columnPendingInvoicesChange = 'pending_invoices_change';
  static const String columnPendingInvoicesChangePercent =
      'pending_invoices_change_percent';
  static const String columnFailedPaymentsValue = 'failed_payments_value';
  static const String columnFailedPaymentsChange = 'failed_payments_change';
  static const String columnFailedPaymentsChangePercent =
      'failed_payments_change_percent';
  static const String columnMonthlyRevenueValue = 'monthly_revenue_value';
  static const String columnMonthlyRevenueChange = 'monthly_revenue_change';
  static const String columnMonthlyRevenueChangePercent =
      'monthly_revenue_change_percent';
  static const String columnMonthlyRevenueCurrency = 'monthly_revenue_currency';
  static const String columnUpdatedAt = 'updated_at';

  // Create table SQL
  static String get createTableSQL =>
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnActiveSubscriptionsValue INTEGER NOT NULL DEFAULT 0,
      $columnActiveSubscriptionsChange TEXT NOT NULL DEFAULT '0.00',
      $columnActiveSubscriptionsChangePercent TEXT NOT NULL DEFAULT '0.00',
      $columnPendingInvoicesValue INTEGER NOT NULL DEFAULT 0,
      $columnPendingInvoicesChange TEXT NOT NULL DEFAULT '0.00',
      $columnPendingInvoicesChangePercent TEXT NOT NULL DEFAULT '0.00',
      $columnFailedPaymentsValue INTEGER NOT NULL DEFAULT 0,
      $columnFailedPaymentsChange TEXT NOT NULL DEFAULT '0.00',
      $columnFailedPaymentsChangePercent TEXT NOT NULL DEFAULT '0.00',
      $columnMonthlyRevenueValue TEXT NOT NULL DEFAULT '0.00',
      $columnMonthlyRevenueChange TEXT NOT NULL DEFAULT '0.00',
      $columnMonthlyRevenueChangePercent TEXT NOT NULL DEFAULT '0.00',
      $columnMonthlyRevenueCurrency TEXT NOT NULL DEFAULT 'USD',
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  // Convert map to database map
  static Map<String, dynamic> toMap(Map<String, dynamic> kpiData) {
    return {
      columnActiveSubscriptionsValue:
          kpiData[columnActiveSubscriptionsValue] ?? 0,
      columnActiveSubscriptionsChange:
          kpiData[columnActiveSubscriptionsChange] ?? '0.00',
      columnActiveSubscriptionsChangePercent:
          kpiData[columnActiveSubscriptionsChangePercent] ?? '0.00',
      columnPendingInvoicesValue: kpiData[columnPendingInvoicesValue] ?? 0,
      columnPendingInvoicesChange:
          kpiData[columnPendingInvoicesChange] ?? '0.00',
      columnPendingInvoicesChangePercent:
          kpiData[columnPendingInvoicesChangePercent] ?? '0.00',
      columnFailedPaymentsValue: kpiData[columnFailedPaymentsValue] ?? 0,
      columnFailedPaymentsChange: kpiData[columnFailedPaymentsChange] ?? '0.00',
      columnFailedPaymentsChangePercent:
          kpiData[columnFailedPaymentsChangePercent] ?? '0.00',
      columnMonthlyRevenueValue: kpiData[columnMonthlyRevenueValue] ?? '0.00',
      columnMonthlyRevenueChange: kpiData[columnMonthlyRevenueChange] ?? '0.00',
      columnMonthlyRevenueChangePercent:
          kpiData[columnMonthlyRevenueChangePercent] ?? '0.00',
      columnMonthlyRevenueCurrency:
          kpiData[columnMonthlyRevenueCurrency] ?? 'USD',
      columnUpdatedAt:
          kpiData[columnUpdatedAt] ?? DateTime.now().toIso8601String(),
    };
  }

  // Get latest KPIs
  static Future<Map<String, dynamic>?> getLatest(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: '$columnUpdatedAt DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return maps.first;
  }

  // Insert or replace KPIs
  static Future<void> insertOrReplace(
    Database db,
    Map<String, dynamic> kpiData,
  ) async {
    // Delete old data first
    await db.delete(tableName);

    // Insert new data
    await db.insert(tableName, toMap(kpiData));
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
