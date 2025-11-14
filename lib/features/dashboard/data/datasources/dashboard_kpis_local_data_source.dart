import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_kpi_model.dart';

abstract class DashboardKPIsLocalDataSource {
  Future<DashboardKPIModel> getCachedDashboardKPIs();
  Future<void> cacheDashboardKPIs(DashboardKPIModel kpis);
  Stream<DashboardKPIModel> watchDashboardKPIs();
}

@LazySingleton(as: DashboardKPIsLocalDataSource)
class DashboardKPIsLocalDataSourceImpl implements DashboardKPIsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  // Stream controller for reactive updates
  final StreamController<DashboardKPIModel> _kpisStreamController =
      StreamController<DashboardKPIModel>.broadcast();

  DashboardKPIsLocalDataSourceImpl(this._databaseService);

  @override
  Future<DashboardKPIModel> getCachedDashboardKPIs() async {
    try {
      _logger.d('💾 [Dashboard Local] Getting cached dashboard KPIs');
      final db = await _databaseService.database;

      // Check if dashboard_kpis table exists, if not return default values
      final tableExists = await _tableExists(db, 'dashboard_kpis');
      if (!tableExists) {
        _logger.w(
          '⚠️ [Dashboard Local] dashboard_kpis table does not exist, returning defaults',
        );
        // Return default KPI values if table doesn't exist
        return _getDefaultKPIs();
      }

      _logger.d('✅ [Dashboard Local] dashboard_kpis table exists');
      final result = await db.query(
        'dashboard_kpis',
        orderBy: 'updated_at DESC',
        limit: 1,
      );

      if (result.isEmpty) {
        _logger.w(
          '⚠️ [Dashboard Local] No cached KPIs found, returning defaults',
        );
        return _getDefaultKPIs();
      }

      _logger.d(
        '✅ [Dashboard Local] Found cached KPIs: ${result.length} record(s)',
      );
      final kpiData = result.first;
      _logger.d('📊 [Dashboard Local] Cached KPI data: $kpiData');
      final kpiMap = {
        'activeSubscriptions': {
          'value': kpiData['active_subscriptions_value'] as int? ?? 0,
          'change': kpiData['active_subscriptions_change'] as String? ?? '0.00',
          'changePercent':
              kpiData['active_subscriptions_change_percent'] as String? ??
              '0.00',
        },
        'pendingInvoices': {
          'value': kpiData['pending_invoices_value'] as int? ?? 0,
          'change': kpiData['pending_invoices_change'] as String? ?? '0.00',
          'changePercent':
              kpiData['pending_invoices_change_percent'] as String? ?? '0.00',
        },
        'failedPayments': {
          'value': kpiData['failed_payments_value'] as int? ?? 0,
          'change': kpiData['failed_payments_change'] as String? ?? '0.00',
          'changePercent':
              kpiData['failed_payments_change_percent'] as String? ?? '0.00',
        },
        'monthlyRevenue': {
          'value': kpiData['monthly_revenue_value'] as String? ?? '0.00',
          'change': kpiData['monthly_revenue_change'] as String? ?? '0.00',
          'changePercent':
              kpiData['monthly_revenue_change_percent'] as String? ?? '0.00',
          'currency': kpiData['monthly_revenue_currency'] as String? ?? 'USD',
        },
      };

      final kpiModel = DashboardKPIModel.fromMap(kpiMap);
      _logger.i('✅ [Dashboard Local] Successfully retrieved cached KPIs');
      _logger.d('📊 [Dashboard Local] KPIs: ${kpiModel.toJson()}');
      return kpiModel;
    } catch (e, stackTrace) {
      _logger.e('❌ [Dashboard Local] Error getting cached KPIs: $e');
      _logger.e('📚 [Dashboard Local] Stack trace: $stackTrace');
      // If there's an error, return default KPIs instead of throwing
      _logger.w('⚠️ [Dashboard Local] Returning default KPIs due to error');
      return _getDefaultKPIs();
    }
  }

  @override
  Future<void> cacheDashboardKPIs(DashboardKPIModel kpis) async {
    try {
      _logger.i('💾 [Dashboard Local] Caching dashboard KPIs');
      _logger.d('📊 [Dashboard Local] KPIs to cache: ${kpis.toJson()}');
      final db = await _databaseService.database;

      // Ensure table exists
      _logger.d('🔧 [Dashboard Local] Ensuring dashboard_kpis table exists');
      await _ensureDashboardKPIsTableExists(db);

      // Delete old cached data
      _logger.d('🗑️ [Dashboard Local] Deleting old cached KPIs');
      await db.delete('dashboard_kpis');

      // Insert new KPI data
      final kpiData = {
        'active_subscriptions_value': kpis.activeSubscriptions.value,
        'active_subscriptions_change': kpis.activeSubscriptions.change,
        'active_subscriptions_change_percent':
            kpis.activeSubscriptions.changePercent,
        'pending_invoices_value': kpis.pendingInvoices.value,
        'pending_invoices_change': kpis.pendingInvoices.change,
        'pending_invoices_change_percent': kpis.pendingInvoices.changePercent,
        'failed_payments_value': kpis.failedPayments.value,
        'failed_payments_change': kpis.failedPayments.change,
        'failed_payments_change_percent': kpis.failedPayments.changePercent,
        'monthly_revenue_value': kpis.monthlyRevenue.value,
        'monthly_revenue_change': kpis.monthlyRevenue.change,
        'monthly_revenue_change_percent': kpis.monthlyRevenue.changePercent,
        'monthly_revenue_currency': kpis.monthlyRevenue.currency,
        'updated_at': DateTime.now().toIso8601String(),
      };
      _logger.d('💾 [Dashboard Local] Inserting KPI data: $kpiData');
      await db.insert('dashboard_kpis', kpiData);
      _logger.i('✅ [Dashboard Local] Successfully cached dashboard KPIs');

      // Emit update to stream
      _kpisStreamController.add(kpis);
      _logger.d('📡 [Dashboard Local] Emitted KPIs update to stream');
    } catch (e, stackTrace) {
      _logger.e('❌ [Dashboard Local] Error caching KPIs: $e');
      _logger.e('📚 [Dashboard Local] Stack trace: $stackTrace');
      throw CacheException('Failed to cache dashboard KPIs: $e');
    }
  }

  @override
  Stream<DashboardKPIModel> watchDashboardKPIs() {
    return _kpisStreamController.stream;
  }

  Future<void> _ensureDashboardKPIsTableExists(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dashboard_kpis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        active_subscriptions_value INTEGER NOT NULL DEFAULT 0,
        active_subscriptions_change TEXT NOT NULL DEFAULT '0.00',
        active_subscriptions_change_percent TEXT NOT NULL DEFAULT '0.00',
        pending_invoices_value INTEGER NOT NULL DEFAULT 0,
        pending_invoices_change TEXT NOT NULL DEFAULT '0.00',
        pending_invoices_change_percent TEXT NOT NULL DEFAULT '0.00',
        failed_payments_value INTEGER NOT NULL DEFAULT 0,
        failed_payments_change TEXT NOT NULL DEFAULT '0.00',
        failed_payments_change_percent TEXT NOT NULL DEFAULT '0.00',
        monthly_revenue_value TEXT NOT NULL DEFAULT '0.00',
        monthly_revenue_change TEXT NOT NULL DEFAULT '0.00',
        monthly_revenue_change_percent TEXT NOT NULL DEFAULT '0.00',
        monthly_revenue_currency TEXT NOT NULL DEFAULT 'USD',
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  DashboardKPIModel _getDefaultKPIs() {
    return DashboardKPIModel(
      activeSubscriptions: const KPIMetricModel(
        value: 0,
        change: '0.00',
        changePercent: '0.00',
      ),
      pendingInvoices: const KPIMetricModel(
        value: 0,
        change: '0.00',
        changePercent: '0.00',
      ),
      failedPayments: const KPIMetricModel(
        value: 0,
        change: '0.00',
        changePercent: '0.00',
      ),
      monthlyRevenue: const RevenueKPIMetricModel(
        value: '0.00',
        change: '0.00',
        changePercent: '0.00',
        currency: 'USD',
      ),
    );
  }
}
