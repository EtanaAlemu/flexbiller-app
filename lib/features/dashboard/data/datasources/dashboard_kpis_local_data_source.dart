import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/dao/dashboard_kpis_dao.dart';
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
      final tableExists = await DashboardKPIsDao.tableExists(db);
      if (!tableExists) {
        _logger.w(
          '⚠️ [Dashboard Local] dashboard_kpis table does not exist, returning defaults',
        );
        // Return default KPI values if table doesn't exist
        return _getDefaultKPIs();
      }

      _logger.d('✅ [Dashboard Local] dashboard_kpis table exists');
      final kpiData = await DashboardKPIsDao.getLatest(db);

      if (kpiData == null) {
        _logger.w(
          '⚠️ [Dashboard Local] No cached KPIs found, returning defaults',
        );
        return _getDefaultKPIs();
      }

      _logger.d('✅ [Dashboard Local] Found cached KPIs');
      _logger.d('📊 [Dashboard Local] Cached KPI data: $kpiData');
      final kpiMap = {
        'activeSubscriptions': {
          'value':
              kpiData[DashboardKPIsDao.columnActiveSubscriptionsValue]
                  as int? ??
              0,
          'change':
              kpiData[DashboardKPIsDao.columnActiveSubscriptionsChange]
                  as String? ??
              '0.00',
          'changePercent':
              kpiData[DashboardKPIsDao.columnActiveSubscriptionsChangePercent]
                  as String? ??
              '0.00',
        },
        'pendingInvoices': {
          'value':
              kpiData[DashboardKPIsDao.columnPendingInvoicesValue] as int? ?? 0,
          'change':
              kpiData[DashboardKPIsDao.columnPendingInvoicesChange]
                  as String? ??
              '0.00',
          'changePercent':
              kpiData[DashboardKPIsDao.columnPendingInvoicesChangePercent]
                  as String? ??
              '0.00',
        },
        'failedPayments': {
          'value':
              kpiData[DashboardKPIsDao.columnFailedPaymentsValue] as int? ?? 0,
          'change':
              kpiData[DashboardKPIsDao.columnFailedPaymentsChange] as String? ??
              '0.00',
          'changePercent':
              kpiData[DashboardKPIsDao.columnFailedPaymentsChangePercent]
                  as String? ??
              '0.00',
        },
        'monthlyRevenue': {
          'value':
              kpiData[DashboardKPIsDao.columnMonthlyRevenueValue] as String? ??
              '0.00',
          'change':
              kpiData[DashboardKPIsDao.columnMonthlyRevenueChange] as String? ??
              '0.00',
          'changePercent':
              kpiData[DashboardKPIsDao.columnMonthlyRevenueChangePercent]
                  as String? ??
              '0.00',
          'currency':
              kpiData[DashboardKPIsDao.columnMonthlyRevenueCurrency]
                  as String? ??
              'USD',
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
      await db.execute(DashboardKPIsDao.createTableSQL);

      // Prepare KPI data for DAO
      final kpiData = {
        DashboardKPIsDao.columnActiveSubscriptionsValue:
            kpis.activeSubscriptions.value,
        DashboardKPIsDao.columnActiveSubscriptionsChange:
            kpis.activeSubscriptions.change,
        DashboardKPIsDao.columnActiveSubscriptionsChangePercent:
            kpis.activeSubscriptions.changePercent,
        DashboardKPIsDao.columnPendingInvoicesValue: kpis.pendingInvoices.value,
        DashboardKPIsDao.columnPendingInvoicesChange:
            kpis.pendingInvoices.change,
        DashboardKPIsDao.columnPendingInvoicesChangePercent:
            kpis.pendingInvoices.changePercent,
        DashboardKPIsDao.columnFailedPaymentsValue: kpis.failedPayments.value,
        DashboardKPIsDao.columnFailedPaymentsChange: kpis.failedPayments.change,
        DashboardKPIsDao.columnFailedPaymentsChangePercent:
            kpis.failedPayments.changePercent,
        DashboardKPIsDao.columnMonthlyRevenueValue: kpis.monthlyRevenue.value,
        DashboardKPIsDao.columnMonthlyRevenueChange: kpis.monthlyRevenue.change,
        DashboardKPIsDao.columnMonthlyRevenueChangePercent:
            kpis.monthlyRevenue.changePercent,
        DashboardKPIsDao.columnMonthlyRevenueCurrency:
            kpis.monthlyRevenue.currency,
        DashboardKPIsDao.columnUpdatedAt: DateTime.now().toIso8601String(),
      };
      _logger.d('💾 [Dashboard Local] Inserting KPI data via DAO');
      await DashboardKPIsDao.insertOrReplace(db, kpiData);
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
