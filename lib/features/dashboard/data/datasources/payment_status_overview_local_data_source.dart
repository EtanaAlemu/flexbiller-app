import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/dao/payment_status_overview_dao.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/payment_status_overview_model.dart';

abstract class PaymentStatusOverviewLocalDataSource {
  Future<PaymentStatusOverviewsModel> getCachedPaymentStatusOverview(int year);
  Future<void> cachePaymentStatusOverview(PaymentStatusOverviewsModel overview);
  Stream<PaymentStatusOverviewsModel> watchPaymentStatusOverview(int year);
}

@LazySingleton(as: PaymentStatusOverviewLocalDataSource)
class PaymentStatusOverviewLocalDataSourceImpl
    implements PaymentStatusOverviewLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  // Stream controllers for reactive updates (keyed by year)
  final Map<int, StreamController<PaymentStatusOverviewsModel>>
  _overviewStreamControllers = {};

  PaymentStatusOverviewLocalDataSourceImpl(this._databaseService);

  @override
  Future<PaymentStatusOverviewsModel> getCachedPaymentStatusOverview(
    int year,
  ) async {
    try {
      _logger.d(
        '💾 [Payment Status Overview Local] Getting cached overview for year: $year',
      );
      final db = await _databaseService.database;

      // Check if payment_status_overview table exists
      final tableExists = await PaymentStatusOverviewDao.tableExists(db);
      if (!tableExists) {
        _logger.w(
          '⚠️ [Payment Status Overview Local] payment_status_overview table does not exist, returning defaults',
        );
        return _getDefaultOverview(year);
      }

      _logger.d(
        '✅ [Payment Status Overview Local] payment_status_overview table exists',
      );
      final result = await PaymentStatusOverviewDao.getByYear(db, year);

      if (result.isEmpty) {
        _logger.w(
          '⚠️ [Payment Status Overview Local] No cached overview found for year $year, returning defaults',
        );
        return _getDefaultOverview(year);
      }

      _logger.d(
        '✅ [Payment Status Overview Local] Found cached overview: ${result.length} record(s) for year $year',
      );

      final overviews = result.map((row) {
        return PaymentStatusOverviewModel.fromMap({
          'month': row[PaymentStatusOverviewDao.columnMonth] as String,
          'paidInvoices':
              row[PaymentStatusOverviewDao.columnPaidInvoices] as int? ?? 0,
          'unpaidInvoices':
              row[PaymentStatusOverviewDao.columnUnpaidInvoices] as int? ?? 0,
        });
      }).toList();

      final overviewModel = PaymentStatusOverviewsModel(
        overviews: overviews,
        year: year,
      );
      _logger.i(
        '✅ [Payment Status Overview Local] Successfully retrieved cached overview',
      );
      _logger.d(
        '📊 [Payment Status Overview Local] Overview: ${overviewModel.overviews.length} months',
      );
      return overviewModel;
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [Payment Status Overview Local] Error getting cached overview: $e',
      );
      _logger.e('📚 [Payment Status Overview Local] Stack trace: $stackTrace');
      // If there's an error, return default overview instead of throwing
      _logger.w(
        '⚠️ [Payment Status Overview Local] Returning default overview due to error',
      );
      return _getDefaultOverview(year);
    }
  }

  @override
  Future<void> cachePaymentStatusOverview(
    PaymentStatusOverviewsModel overview,
  ) async {
    try {
      _logger.i(
        '💾 [Payment Status Overview Local] Caching payment status overview for year: ${overview.year}',
      );
      _logger.d(
        '📊 [Payment Status Overview Local] Overview to cache: ${overview.overviews.length} months',
      );
      final db = await _databaseService.database;

      // Ensure table exists
      _logger.d(
        '🔧 [Payment Status Overview Local] Ensuring payment_status_overview table exists',
      );
      await db.execute(PaymentStatusOverviewDao.createTableSQL);

      // Prepare overview data for DAO
      final overviewsData = overview.overviews.map((overviewItem) {
        return {
          PaymentStatusOverviewDao.columnYear: overview.year,
          PaymentStatusOverviewDao.columnMonth: overviewItem.month,
          PaymentStatusOverviewDao.columnPaidInvoices:
              overviewItem.paidInvoices,
          PaymentStatusOverviewDao.columnUnpaidInvoices:
              overviewItem.unpaidInvoices,
          PaymentStatusOverviewDao.columnUpdatedAt: DateTime.now()
              .toIso8601String(),
        };
      }).toList();

      _logger.d(
        '💾 [Payment Status Overview Local] Inserting ${overviewsData.length} overview items via DAO',
      );
      await PaymentStatusOverviewDao.insertOrReplaceForYear(
        db,
        overview.year,
        overviewsData,
      );
      _logger.i(
        '✅ [Payment Status Overview Local] Successfully cached payment status overview',
      );

      // Emit update to stream
      _getOrCreateStreamController(overview.year).add(overview);
      _logger.d(
        '📡 [Payment Status Overview Local] Emitted overview update to stream for year ${overview.year}',
      );
    } catch (e, stackTrace) {
      _logger.e('❌ [Payment Status Overview Local] Error caching overview: $e');
      _logger.e('📚 [Payment Status Overview Local] Stack trace: $stackTrace');
      throw CacheException('Failed to cache payment status overview: $e');
    }
  }

  @override
  Stream<PaymentStatusOverviewsModel> watchPaymentStatusOverview(int year) {
    return _getOrCreateStreamController(year).stream;
  }

  StreamController<PaymentStatusOverviewsModel> _getOrCreateStreamController(
    int year,
  ) {
    if (!_overviewStreamControllers.containsKey(year)) {
      _overviewStreamControllers[year] =
          StreamController<PaymentStatusOverviewsModel>.broadcast();
    }
    return _overviewStreamControllers[year]!;
  }

  /// Dispose resources and close all stream controllers
  void dispose() {
    for (final controller in _overviewStreamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _overviewStreamControllers.clear();
    _logger.d('✅ [Payment Status Overview Local] All StreamControllers closed');
  }

  PaymentStatusOverviewsModel _getDefaultOverview(int year) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final overviews = months.map((month) {
      return PaymentStatusOverviewModel(
        month: month,
        paidInvoices: 0,
        unpaidInvoices: 0,
      );
    }).toList();
    return PaymentStatusOverviewsModel(overviews: overviews, year: year);
  }
}
