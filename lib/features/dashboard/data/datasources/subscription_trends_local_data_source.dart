import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/database_service.dart';
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
      final tableExists = await _tableExists(db, 'subscription_trends');
      if (!tableExists) {
        _logger.w(
          '⚠️ [Subscription Trends Local] subscription_trends table does not exist, returning defaults',
        );
        return _getDefaultTrends(year);
      }

      _logger.d(
        '✅ [Subscription Trends Local] subscription_trends table exists',
      );
      final result = await db.query(
        'subscription_trends',
        where: 'year = ?',
        whereArgs: [year],
        orderBy: 'month ASC',
      );

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
          'month': row['month'] as String,
          'newSubscriptions': row['new_subscriptions'] as int? ?? 0,
          'churnedSubscriptions': row['churned_subscriptions'] as int? ?? 0,
          'revenue': (row['revenue'] as num?)?.toDouble() ?? 0.0,
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
      await _ensureSubscriptionTrendsTableExists(db);

      // Delete old cached data for this year
      _logger.d(
        '🗑️ [Subscription Trends Local] Deleting old cached trends for year ${trends.year}',
      );
      await db.delete(
        'subscription_trends',
        where: 'year = ?',
        whereArgs: [trends.year],
      );

      // Insert new trends data
      for (final trend in trends.trends) {
        final trendData = {
          'year': trends.year,
          'month': trend.month,
          'new_subscriptions': trend.newSubscriptions,
          'churned_subscriptions': trend.churnedSubscriptions,
          'revenue': trend.revenue,
          'updated_at': DateTime.now().toIso8601String(),
        };
        _logger.d(
          '💾 [Subscription Trends Local] Inserting trend data: $trendData',
        );
        await db.insert('subscription_trends', trendData);
      }
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

  Future<void> _ensureSubscriptionTrendsTableExists(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscription_trends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        month TEXT NOT NULL,
        new_subscriptions INTEGER NOT NULL DEFAULT 0,
        churned_subscriptions INTEGER NOT NULL DEFAULT 0,
        revenue REAL NOT NULL DEFAULT 0.0,
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
