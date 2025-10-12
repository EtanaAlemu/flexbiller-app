import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/services/database_service.dart';
import '../../domain/entities/bundle.dart';
import '../../domain/entities/bundle_subscription.dart';
import '../../domain/entities/bundle_event.dart';
import '../../domain/entities/bundle_timeline.dart';

abstract class BundlesLocalDataSource {
  Future<List<Bundle>> getCachedBundles();
  Future<List<Bundle>> getCachedBundlesForAccount(String accountId);
  Future<Bundle?> getCachedBundleById(String bundleId);
  Future<void> cacheBundles(List<Bundle> bundles);
  Future<void> cacheBundle(Bundle bundle);
  Future<void> clearCachedBundles();
  Future<void> clearCachedBundlesForAccount(String accountId);
  Future<void> deleteCachedBundle(String bundleId);
  Future<bool> hasCachedBundles();
  Future<bool> hasCachedBundlesForAccount(String accountId);
  Future<DateTime?> getLastSyncTime();
  Future<void> updateLastSyncTime();
}

@LazySingleton(as: BundlesLocalDataSource)
class BundlesLocalDataSourceImpl implements BundlesLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger;

  BundlesLocalDataSourceImpl(this._databaseService, this._logger);

  @override
  Future<List<Bundle>> getCachedBundles() async {
    try {
      _logger.d('Getting cached bundles from local database');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'bundles',
        orderBy: 'created_at DESC',
      );

      final bundles = <Bundle>[];
      for (final map in maps) {
        final bundle = await _mapToBundle(db, map);
        if (bundle != null) {
          bundles.add(bundle);
        }
      }

      _logger.d('Retrieved ${bundles.length} cached bundles');
      return bundles;
    } catch (e) {
      _logger.e('Error getting cached bundles: $e');
      return [];
    }
  }

  @override
  Future<List<Bundle>> getCachedBundlesForAccount(String accountId) async {
    try {
      _logger.d('Getting cached bundles for account: $accountId');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'bundles',
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'created_at DESC',
      );

      final bundles = <Bundle>[];
      for (final map in maps) {
        final bundle = await _mapToBundle(db, map);
        if (bundle != null) {
          bundles.add(bundle);
        }
      }

      _logger.d(
        'Retrieved ${bundles.length} cached bundles for account $accountId',
      );
      return bundles;
    } catch (e) {
      _logger.e('Error getting cached bundles for account $accountId: $e');
      return [];
    }
  }

  @override
  Future<Bundle?> getCachedBundleById(String bundleId) async {
    try {
      _logger.d('Getting cached bundle by ID: $bundleId');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'bundles',
        where: 'bundle_id = ?',
        whereArgs: [bundleId],
        limit: 1,
      );

      if (maps.isEmpty) {
        _logger.d('No cached bundle found for ID: $bundleId');
        return null;
      }

      final bundle = await _mapToBundle(db, maps.first);
      _logger.d('Retrieved cached bundle: ${bundle?.bundleId}');
      return bundle;
    } catch (e) {
      _logger.e('Error getting cached bundle by ID $bundleId: $e');
      return null;
    }
  }

  @override
  Future<void> cacheBundles(List<Bundle> bundles) async {
    try {
      _logger.d('Caching ${bundles.length} bundles to local database');

      final db = await _databaseService.database;

      // Clear existing bundles first
      await db.delete('bundles');

      // Insert new bundles
      for (final bundle in bundles) {
        await _insertBundle(db, bundle);
      }

      await updateLastSyncTime();
      _logger.d('Successfully cached ${bundles.length} bundles');
    } catch (e) {
      _logger.e('Error caching bundles: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheBundle(Bundle bundle) async {
    try {
      _logger.d('Caching bundle: ${bundle.bundleId}');

      final db = await _databaseService.database;
      await _insertBundle(db, bundle);

      _logger.d('Successfully cached bundle: ${bundle.bundleId}');
    } catch (e) {
      _logger.e('Error caching bundle ${bundle.bundleId}: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCachedBundles() async {
    try {
      _logger.d('Clearing all cached bundles');

      final db = await _databaseService.database;
      await db.delete('bundles');

      _logger.d('Successfully cleared all cached bundles');
    } catch (e) {
      _logger.e('Error clearing cached bundles: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCachedBundlesForAccount(String accountId) async {
    try {
      _logger.d('Clearing cached bundles for account: $accountId');

      final db = await _databaseService.database;
      await db.delete(
        'bundles',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      _logger.d('Successfully cleared cached bundles for account $accountId');
    } catch (e) {
      _logger.e('Error clearing cached bundles for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedBundle(String bundleId) async {
    try {
      _logger.d('Deleting cached bundle: $bundleId');

      final db = await _databaseService.database;
      await db.delete('bundles', where: 'bundle_id = ?', whereArgs: [bundleId]);

      _logger.d('Successfully deleted cached bundle: $bundleId');
    } catch (e) {
      _logger.e('Error deleting cached bundle $bundleId: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedBundles() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM bundles');
      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      _logger.e('Error checking cached bundles: $e');
      return false;
    }
  }

  @override
  Future<bool> hasCachedBundlesForAccount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM bundles WHERE account_id = ?',
        [accountId],
      );
      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      _logger.e('Error checking cached bundles for account $accountId: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(
        'sync_metadata',
        where: 'table_name = ?',
        whereArgs: ['bundles'],
        limit: 1,
      );

      if (result.isEmpty) return null;

      final lastSync = result.first['last_sync'] as String?;
      return lastSync != null ? DateTime.parse(lastSync) : null;
    } catch (e) {
      _logger.e('Error getting last sync time: $e');
      return null;
    }
  }

  @override
  Future<void> updateLastSyncTime() async {
    try {
      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();

      await db.insert('sync_metadata', {
        'table_name': 'bundles',
        'last_sync': now,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      _logger.d('Updated last sync time for bundles');
    } catch (e) {
      _logger.e('Error updating last sync time: $e');
      rethrow;
    }
  }

  Future<void> _insertBundle(dynamic db, Bundle bundle) async {
    await db.insert('bundles', {
      'bundle_id': bundle.bundleId,
      'account_id': bundle.accountId,
      'external_key': bundle.externalKey,
      'subscriptions': jsonEncode(
        bundle.subscriptions.map((s) => _subscriptionToMap(s)).toList(),
      ),
      'timeline': jsonEncode(_timelineToMap(bundle.timeline)),
      'audit_logs': bundle.auditLogs != null
          ? jsonEncode(bundle.auditLogs)
          : null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Bundle?> _mapToBundle(dynamic db, Map<String, dynamic> map) async {
    try {
      final subscriptions = _parseSubscriptions(
        map['subscriptions'] as String?,
      );
      final timeline = _parseTimeline(map['timeline'] as String?);

      return Bundle(
        accountId: map['account_id'] as String,
        bundleId: map['bundle_id'] as String,
        externalKey: map['external_key'] as String,
        subscriptions: subscriptions,
        timeline: timeline,
        auditLogs: map['audit_logs'] != null
            ? List<Map<String, dynamic>>.from(
                jsonDecode(map['audit_logs'] as String),
              )
            : null,
      );
    } catch (e) {
      _logger.e('Error mapping bundle: $e');
      return null;
    }
  }

  List<BundleSubscription> _parseSubscriptions(String? subscriptionsJson) {
    if (subscriptionsJson == null || subscriptionsJson.isEmpty) return [];

    try {
      final List<dynamic> subscriptionsList = jsonDecode(subscriptionsJson);
      return subscriptionsList
          .map((subMap) => _mapToSubscription(subMap))
          .toList();
    } catch (e) {
      _logger.e('Error parsing subscriptions: $e');
      return [];
    }
  }

  BundleTimeline _parseTimeline(String? timelineJson) {
    if (timelineJson == null || timelineJson.isEmpty) {
      return BundleTimeline(
        accountId: '',
        bundleId: '',
        externalKey: '',
        events: [],
        auditLogs: [],
      );
    }

    try {
      final Map<String, dynamic> timelineMap = jsonDecode(timelineJson);
      return _mapToTimeline(timelineMap);
    } catch (e) {
      _logger.e('Error parsing timeline: $e');
      return BundleTimeline(
        accountId: '',
        bundleId: '',
        externalKey: '',
        events: [],
        auditLogs: [],
      );
    }
  }

  BundleSubscription _mapToSubscription(Map<String, dynamic> subMap) {
    return BundleSubscription(
      accountId: subMap['accountId'] as String? ?? '',
      bundleId: subMap['bundleId'] as String? ?? '',
      bundleExternalKey: subMap['bundleExternalKey'] as String? ?? '',
      subscriptionId: subMap['subscriptionId'] as String? ?? '',
      externalKey: subMap['externalKey'] as String? ?? '',
      startDate: DateTime.parse(subMap['startDate'] as String),
      productName: subMap['productName'] as String? ?? '',
      productCategory: subMap['productCategory'] as String? ?? '',
      billingPeriod: subMap['billingPeriod'] as String? ?? '',
      phaseType: subMap['phaseType'] as String? ?? '',
      priceList: subMap['priceList'] as String? ?? '',
      planName: subMap['planName'] as String? ?? '',
      state: subMap['state'] as String? ?? '',
      sourceType: subMap['sourceType'] as String? ?? '',
      cancelledDate: subMap['cancelledDate'] != null
          ? DateTime.parse(subMap['cancelledDate'] as String)
          : null,
      chargedThroughDate: subMap['chargedThroughDate'] as String? ?? '',
      billingStartDate: DateTime.parse(subMap['billingStartDate'] as String),
      billingEndDate: subMap['billingEndDate'] != null
          ? DateTime.parse(subMap['billingEndDate'] as String)
          : null,
      billCycleDayLocal: subMap['billCycleDayLocal'] as int? ?? 0,
      quantity: subMap['quantity'] as int? ?? 0,
      events: _parseEvents(subMap['events'] as List?),
      priceOverrides: subMap['priceOverrides'],
      prices: subMap['prices'] as List? ?? [],
      auditLogs: subMap['auditLogs'] != null
          ? List<Map<String, dynamic>>.from(subMap['auditLogs'] as List)
          : null,
    );
  }

  BundleTimeline _mapToTimeline(Map<String, dynamic> timelineMap) {
    return BundleTimeline(
      accountId: timelineMap['accountId'] as String? ?? '',
      bundleId: timelineMap['bundleId'] as String? ?? '',
      externalKey: timelineMap['externalKey'] as String? ?? '',
      events: _parseEvents(timelineMap['events'] as List?),
      auditLogs: timelineMap['auditLogs'] != null
          ? List<Map<String, dynamic>>.from(timelineMap['auditLogs'] as List)
          : [],
    );
  }

  List<BundleEvent> _parseEvents(List? eventsList) {
    if (eventsList == null || eventsList.isEmpty) return [];

    try {
      return eventsList.map((eventMap) => _mapToEvent(eventMap)).toList();
    } catch (e) {
      _logger.e('Error parsing events: $e');
      return [];
    }
  }

  BundleEvent _mapToEvent(Map<String, dynamic> eventMap) {
    return BundleEvent(
      eventId: eventMap['eventId'] as String? ?? '',
      billingPeriod: eventMap['billingPeriod'] as String? ?? '',
      effectiveDate: DateTime.parse(eventMap['effectiveDate'] as String),
      catalogEffectiveDate: DateTime.parse(
        eventMap['catalogEffectiveDate'] as String,
      ),
      plan: eventMap['plan'] as String? ?? '',
      product: eventMap['product'] as String? ?? '',
      priceList: eventMap['priceList'] as String? ?? '',
      eventType: eventMap['eventType'] as String? ?? '',
      isBlockedBilling: eventMap['isBlockedBilling'] as bool? ?? false,
      isBlockedEntitlement: eventMap['isBlockedEntitlement'] as bool? ?? false,
      serviceName: eventMap['serviceName'] as String? ?? '',
      serviceStateName: eventMap['serviceStateName'] as String? ?? '',
      phase: eventMap['phase'] as String? ?? '',
      auditLogs: eventMap['auditLogs'] != null
          ? List<Map<String, dynamic>>.from(eventMap['auditLogs'] as List)
          : [],
    );
  }

  Map<String, dynamic> _subscriptionToMap(BundleSubscription subscription) {
    return {
      'accountId': subscription.accountId,
      'bundleId': subscription.bundleId,
      'bundleExternalKey': subscription.bundleExternalKey,
      'subscriptionId': subscription.subscriptionId,
      'externalKey': subscription.externalKey,
      'startDate': subscription.startDate.toIso8601String(),
      'productName': subscription.productName,
      'productCategory': subscription.productCategory,
      'billingPeriod': subscription.billingPeriod,
      'phaseType': subscription.phaseType,
      'priceList': subscription.priceList,
      'planName': subscription.planName,
      'state': subscription.state,
      'sourceType': subscription.sourceType,
      'cancelledDate': subscription.cancelledDate?.toIso8601String(),
      'chargedThroughDate': subscription.chargedThroughDate,
      'billingStartDate': subscription.billingStartDate.toIso8601String(),
      'billingEndDate': subscription.billingEndDate?.toIso8601String(),
      'billCycleDayLocal': subscription.billCycleDayLocal,
      'quantity': subscription.quantity,
      'events': subscription.events.map((e) => _eventToMap(e)).toList(),
      'priceOverrides': subscription.priceOverrides,
      'prices': subscription.prices,
      'auditLogs': subscription.auditLogs,
    };
  }

  Map<String, dynamic> _timelineToMap(BundleTimeline timeline) {
    return {
      'accountId': timeline.accountId,
      'bundleId': timeline.bundleId,
      'externalKey': timeline.externalKey,
      'events': timeline.events.map((e) => _eventToMap(e)).toList(),
      'auditLogs': timeline.auditLogs,
    };
  }

  Map<String, dynamic> _eventToMap(BundleEvent event) {
    return {
      'eventId': event.eventId,
      'billingPeriod': event.billingPeriod,
      'effectiveDate': event.effectiveDate.toIso8601String(),
      'catalogEffectiveDate': event.catalogEffectiveDate.toIso8601String(),
      'plan': event.plan,
      'product': event.product,
      'priceList': event.priceList,
      'eventType': event.eventType,
      'isBlockedBilling': event.isBlockedBilling,
      'isBlockedEntitlement': event.isBlockedEntitlement,
      'serviceName': event.serviceName,
      'serviceStateName': event.serviceStateName,
      'phase': event.phase,
      'auditLogs': event.auditLogs,
    };
  }
}
