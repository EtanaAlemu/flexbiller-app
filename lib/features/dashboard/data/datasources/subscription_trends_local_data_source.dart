import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/dao/subscription_trends_dao.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/subscription_trend_model.dart';

abstract class SubscriptionTrendsLocalDataSource {
  Future<SubscriptionTrendsModel> getCachedSubscriptionTrends(int year);
  Future<void> cacheSubscriptionTrends(SubscriptionTrendsModel trends);
  Stream<SubscriptionTrendsModel> watchSubscriptionTrends(int year);
}

@LazySingleton(as: SubscriptionTrendsLocalDataSource)
class SubscriptionTrendsLocalDataSourceImpl
    implements SubscriptionTrendsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  // Stream controllers for reactive updates (keyed by year)
  final Map<int, StreamController<SubscriptionTrendsModel>>
  _trendsStreamControllers = {};

  SubscriptionTrendsLocalDataSourceImpl(this._databaseService);

  @override
  Future<SubscriptionTrendsModel> getCachedSubscriptionTrends(int year) async {
    try {
      _logger.d(
        '💾 [Subscription Trends Local] Getting cached trends for year: $year',
      );
      final db = await _databaseService.database;

      // Check if subscription_trends table exists
      final tableExists = await SubscriptionTrendsDao.tableExists(db);
      if (!tableExists) {
        _logger.w(
          '⚠️ [Subscription Trends Local] subscription_trends table does not exist, returning defaults',
        );
        return _getDefaultTrends(year);
      }

      _logger.d(
        '✅ [Subscription Trends Local] subscription_trends table exists',
      );
      final result = await SubscriptionTrendsDao.getByYear(db, year);

      if (result.isEmpty) {
        _logger.w(
          '⚠️ [Subscription Trends Local] No cached trends found for year $year, returning defaults',
        );
        return _getDefaultTrends(year);
      }

      _logger.d(
        '✅ [Subscription Trends Local] Found cached trends: ${result.length} record(s) for year $year',
      );

      final trends = result.map((row) {
        return SubscriptionTrendModel.fromMap({
          'month': row[SubscriptionTrendsDao.columnMonth] as String,
          'newSubscriptions':
              row[SubscriptionTrendsDao.columnNewSubscriptions] as int? ?? 0,
          'churnedSubscriptions':
              row[SubscriptionTrendsDao.columnChurnedSubscriptions] as int? ??
              0,
          'revenue':
              (row[SubscriptionTrendsDao.columnRevenue] as num?)?.toDouble() ??
              0.0,
        });
      }).toList();

      final trendsModel = SubscriptionTrendsModel(trends: trends, year: year);
      _logger.i(
        '✅ [Subscription Trends Local] Successfully retrieved cached trends',
      );
      _logger.d(
        '📊 [Subscription Trends Local] Trends: ${trendsModel.trends.length} months',
      );
      return trendsModel;
    } catch (e, stackTrace) {
      _logger.e(
        '❌ [Subscription Trends Local] Error getting cached trends: $e',
      );
      _logger.e('📚 [Subscription Trends Local] Stack trace: $stackTrace');
      // If there's an error, return default trends instead of throwing
      _logger.w(
        '⚠️ [Subscription Trends Local] Returning default trends due to error',
      );
      return _getDefaultTrends(year);
    }
  }

  @override
  Future<void> cacheSubscriptionTrends(SubscriptionTrendsModel trends) async {
    try {
      _logger.i(
        '💾 [Subscription Trends Local] Caching subscription trends for year: ${trends.year}',
      );
      _logger.d(
        '📊 [Subscription Trends Local] Trends to cache: ${trends.trends.length} months',
      );
      final db = await _databaseService.database;

      // Ensure table exists
      _logger.d(
        '🔧 [Subscription Trends Local] Ensuring subscription_trends table exists',
      );
      await db.execute(SubscriptionTrendsDao.createTableSQL);

      // Prepare trends data for DAO
      final trendsData = trends.trends.map((trend) {
        return {
          SubscriptionTrendsDao.columnYear: trends.year,
          SubscriptionTrendsDao.columnMonth: trend.month,
          SubscriptionTrendsDao.columnNewSubscriptions: trend.newSubscriptions,
          SubscriptionTrendsDao.columnChurnedSubscriptions:
              trend.churnedSubscriptions,
          SubscriptionTrendsDao.columnRevenue: trend.revenue,
          SubscriptionTrendsDao.columnUpdatedAt: DateTime.now()
              .toIso8601String(),
        };
      }).toList();

      _logger.d(
        '💾 [Subscription Trends Local] Inserting ${trendsData.length} trends via DAO',
      );
      await SubscriptionTrendsDao.insertOrReplaceForYear(
        db,
        trends.year,
        trendsData,
      );
      _logger.i(
        '✅ [Subscription Trends Local] Successfully cached subscription trends',
      );

      // Emit update to stream
      _getOrCreateStreamController(trends.year).add(trends);
      _logger.d(
        '📡 [Subscription Trends Local] Emitted trends update to stream for year ${trends.year}',
      );
    } catch (e, stackTrace) {
      _logger.e('❌ [Subscription Trends Local] Error caching trends: $e');
      _logger.e('📚 [Subscription Trends Local] Stack trace: $stackTrace');
      throw CacheException('Failed to cache subscription trends: $e');
    }
  }

  @override
  Stream<SubscriptionTrendsModel> watchSubscriptionTrends(int year) {
    return _getOrCreateStreamController(year).stream;
  }

  StreamController<SubscriptionTrendsModel> _getOrCreateStreamController(
    int year,
  ) {
    if (!_trendsStreamControllers.containsKey(year)) {
      _trendsStreamControllers[year] =
          StreamController<SubscriptionTrendsModel>.broadcast();
    }
    return _trendsStreamControllers[year]!;
  }

  /// Dispose resources and close all stream controllers
  void dispose() {
    for (final controller in _trendsStreamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _trendsStreamControllers.clear();
    _logger.d('✅ [Subscription Trends Local] All StreamControllers closed');
  }

  SubscriptionTrendsModel _getDefaultTrends(int year) {
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
    final trends = months.map((month) {
      return SubscriptionTrendModel(
        month: month,
        newSubscriptions: 0,
        churnedSubscriptions: 0,
        revenue: 0.0,
      );
    }).toList();
    return SubscriptionTrendsModel(trends: trends, year: year);
  }
}
