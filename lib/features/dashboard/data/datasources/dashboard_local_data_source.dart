import 'package:injectable/injectable.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/services/database_service.dart';
import '../models/dashboard_data_model.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardDataModel> getDashboardData();
  Future<List<AccountChartDataModel>> getAccountChartData();
  Future<List<SubscriptionChartDataModel>> getSubscriptionChartData();
  Future<List<RevenueChartDataModel>> getRevenueChartData();
}

// @LazySingleton(as: DashboardLocalDataSource)
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final DatabaseService _databaseService;

  DashboardLocalDataSourceImpl(this._databaseService);

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      final db = await _databaseService.database;

      // Get total accounts
      final accountsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM accounts',
      );
      final totalAccounts = accountsResult.first['count'] as int;

      // Get active accounts (assuming accounts with balance > 0 are active)
      final activeAccountsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM accounts WHERE account_balance > 0',
      );
      final activeAccounts = activeAccountsResult.first['count'] as int;

      // Get total subscriptions
      final subscriptionsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM subscriptions',
      );
      final totalSubscriptions = subscriptionsResult.first['count'] as int;

      // Get active subscriptions
      final activeSubscriptionsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM subscriptions WHERE state = "ACTIVE"',
      );
      final activeSubscriptions =
          activeSubscriptionsResult.first['count'] as int;

      // Get total revenue (sum of all account balances)
      final revenueResult = await db.rawQuery(
        'SELECT SUM(account_balance) as total FROM accounts WHERE account_balance IS NOT NULL',
      );
      final totalRevenue =
          (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

      // Get monthly revenue (this month's revenue)
      final monthlyRevenueResult = await db.rawQuery(
        'SELECT SUM(account_balance) as monthly FROM accounts WHERE account_balance IS NOT NULL AND strftime("%Y-%m", updated_at) = strftime("%Y-%m", "now")',
      );
      final monthlyRevenue =
          (monthlyRevenueResult.first['monthly'] as num?)?.toDouble() ?? 0.0;

      // Get chart data
      final accountChartData = await getAccountChartData();
      final subscriptionChartData = await getSubscriptionChartData();
      final revenueChartData = await getRevenueChartData();

      // Get status data
      final accountStatusData = await _getAccountStatusData();
      final subscriptionStatusData = await _getSubscriptionStatusData();

      return DashboardDataModel(
        totalAccounts: totalAccounts,
        activeAccounts: activeAccounts,
        totalSubscriptions: totalSubscriptions,
        activeSubscriptions: activeSubscriptions,
        totalRevenue: totalRevenue,
        monthlyRevenue: monthlyRevenue,
        accountChartData: accountChartData,
        subscriptionChartData: subscriptionChartData,
        revenueChartData: revenueChartData,
        accountStatusData: accountStatusData,
        subscriptionStatusData: subscriptionStatusData,
      );
    } catch (e) {
      throw Exception('Failed to get dashboard data: $e');
    }
  }

  @override
  Future<List<AccountChartDataModel>> getAccountChartData() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('''
        SELECT 
          strftime('%Y-%m', created_at) as month,
          COUNT(*) as count
        FROM accounts 
        WHERE created_at >= date('now', '-12 months')
        GROUP BY strftime('%Y-%m', created_at)
        ORDER BY month
      ''');

      return result.map((row) => AccountChartDataModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception('Failed to get account chart data: $e');
    }
  }

  @override
  Future<List<SubscriptionChartDataModel>> getSubscriptionChartData() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('''
        SELECT 
          product_name,
          COUNT(*) as count,
          SUM(price) as revenue
        FROM subscriptions 
        GROUP BY product_name
        ORDER BY count DESC
        LIMIT 10
      ''');

      return result
          .map((row) => SubscriptionChartDataModel.fromMap(row))
          .toList();
    } catch (e) {
      throw Exception('Failed to get subscription chart data: $e');
    }
  }

  @override
  Future<List<RevenueChartDataModel>> getRevenueChartData() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('''
        SELECT 
          strftime('%Y-%m', updated_at) as month,
          SUM(account_balance) as revenue
        FROM accounts 
        WHERE account_balance IS NOT NULL 
          AND updated_at >= date('now', '-12 months')
        GROUP BY strftime('%Y-%m', updated_at)
        ORDER BY month
      ''');

      return result.map((row) => RevenueChartDataModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception('Failed to get revenue chart data: $e');
    }
  }

  Future<List<AccountStatusDataModel>> _getAccountStatusData() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('''
        SELECT 
          CASE 
            WHEN account_balance > 0 THEN 'Active'
            WHEN account_balance = 0 THEN 'Inactive'
            ELSE 'Unknown'
          END as status,
          COUNT(*) as count
        FROM accounts 
        GROUP BY status
      ''');

      final total = result.fold<int>(
        0,
        (sum, row) => sum + (row['count'] as int),
      );

      return result.map((row) {
        final count = row['count'] as int;
        return AccountStatusDataModel(
          status: row['status'] as String,
          count: count,
          percentage: total > 0 ? (count / total) * 100 : 0.0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get account status data: $e');
    }
  }

  Future<List<SubscriptionStatusDataModel>> _getSubscriptionStatusData() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('''
        SELECT 
          state as status,
          COUNT(*) as count
        FROM subscriptions 
        GROUP BY state
      ''');

      final total = result.fold<int>(
        0,
        (sum, row) => sum + (row['count'] as int),
      );

      return result.map((row) {
        final count = row['count'] as int;
        return SubscriptionStatusDataModel(
          status: row['status'] as String,
          count: count,
          percentage: total > 0 ? (count / total) * 100 : 0.0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get subscription status data: $e');
    }
  }
}
