import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/database_service.dart';
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
      final tableExists = await _tableExists(db, 'payment_status_overview');
      if (!tableExists) {
        _logger.w(
          '⚠️ [Payment Status Overview Local] payment_status_overview table does not exist, returning defaults',
        );
        return _getDefaultOverview(year);
      }

      _logger.d(
        '✅ [Payment Status Overview Local] payment_status_overview table exists',
      );
      final result = await db.query(
        'payment_status_overview',
        where: 'year = ?',
        whereArgs: [year],
        orderBy: 'month ASC',
      );

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
          'month': row['month'] as String,
          'paidInvoices': row['paid_invoices'] as int? ?? 0,
          'unpaidInvoices': row['unpaid_invoices'] as int? ?? 0,
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
      await _ensurePaymentStatusOverviewTableExists(db);

      // Delete old cached data for this year
      _logger.d(
        '🗑️ [Payment Status Overview Local] Deleting old cached overview for year ${overview.year}',
      );
      await db.delete(
        'payment_status_overview',
        where: 'year = ?',
        whereArgs: [overview.year],
      );

      // Insert new overview data
      for (final overviewItem in overview.overviews) {
        final overviewData = {
          'year': overview.year,
          'month': overviewItem.month,
          'paid_invoices': overviewItem.paidInvoices,
          'unpaid_invoices': overviewItem.unpaidInvoices,
          'updated_at': DateTime.now().toIso8601String(),
        };
        _logger.d(
          '💾 [Payment Status Overview Local] Inserting overview data: $overviewData',
        );
        await db.insert('payment_status_overview', overviewData);
      }
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

  Future<void> _ensurePaymentStatusOverviewTableExists(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_status_overview (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        month TEXT NOT NULL,
        paid_invoices INTEGER NOT NULL DEFAULT 0,
        unpaid_invoices INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE(year, month)
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
