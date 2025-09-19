import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/services/database_service.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_event.dart';

abstract class SubscriptionsLocalDataSource {
  Future<List<Subscription>> getCachedSubscriptions();
  Future<List<Subscription>> getCachedSubscriptionsForAccount(String accountId);
  Future<Subscription?> getCachedSubscriptionById(String subscriptionId);
  Future<void> cacheSubscriptions(List<Subscription> subscriptions);
  Future<void> cacheSubscription(Subscription subscription);
  Future<void> clearCachedSubscriptions();
  Future<void> clearCachedSubscriptionsForAccount(String accountId);
  Future<void> deleteCachedSubscription(String subscriptionId);
  Future<bool> hasCachedSubscriptions();
  Future<bool> hasCachedSubscriptionsForAccount(String accountId);
  Future<DateTime?> getLastSyncTime();
  Future<void> updateLastSyncTime();
}

@LazySingleton(as: SubscriptionsLocalDataSource)
class SubscriptionsLocalDataSourceImpl implements SubscriptionsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger;

  SubscriptionsLocalDataSourceImpl(this._databaseService, this._logger);

  @override
  Future<List<Subscription>> getCachedSubscriptions() async {
    try {
      _logger.d('Getting cached subscriptions from local database');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'subscriptions',
        orderBy: 'start_date DESC',
      );

      final subscriptions = maps.map((map) => _mapToSubscription(map)).toList();

      _logger.d('Retrieved ${subscriptions.length} cached subscriptions');
      return subscriptions;
    } catch (e) {
      _logger.e('Error getting cached subscriptions: $e');
      return [];
    }
  }

  @override
  Future<List<Subscription>> getCachedSubscriptionsForAccount(
    String accountId,
  ) async {
    try {
      _logger.d('Getting cached subscriptions for account: $accountId');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'subscriptions',
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'start_date DESC',
      );

      final subscriptions = maps.map((map) => _mapToSubscription(map)).toList();

      _logger.d(
        'Retrieved ${subscriptions.length} cached subscriptions for account $accountId',
      );
      return subscriptions;
    } catch (e) {
      _logger.e(
        'Error getting cached subscriptions for account $accountId: $e',
      );
      return [];
    }
  }

  @override
  Future<Subscription?> getCachedSubscriptionById(String subscriptionId) async {
    try {
      _logger.d('Getting cached subscription by ID: $subscriptionId');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'subscriptions',
        where: 'subscription_id = ?',
        whereArgs: [subscriptionId],
        limit: 1,
      );

      if (maps.isEmpty) {
        _logger.d('No cached subscription found for ID: $subscriptionId');
        return null;
      }

      final subscription = _mapToSubscription(maps.first);
      _logger.d('Retrieved cached subscription: ${subscription.productName}');
      return subscription;
    } catch (e) {
      _logger.e('Error getting cached subscription by ID $subscriptionId: $e');
      return null;
    }
  }

  @override
  Future<void> cacheSubscriptions(List<Subscription> subscriptions) async {
    try {
      _logger.d(
        'Caching ${subscriptions.length} subscriptions to local database',
      );

      final db = await _databaseService.database;

      // Clear existing subscriptions first
      await db.delete('subscriptions');

      // Insert new subscriptions
      for (final subscription in subscriptions) {
        await _insertSubscription(db, subscription);
      }

      await updateLastSyncTime();
      _logger.d('Successfully cached ${subscriptions.length} subscriptions');
    } catch (e) {
      _logger.e('Error caching subscriptions: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheSubscription(Subscription subscription) async {
    try {
      _logger.d('Caching subscription: ${subscription.subscriptionId}');

      final db = await _databaseService.database;
      await _insertSubscription(db, subscription);

      _logger.d(
        'Successfully cached subscription: ${subscription.productName}',
      );
    } catch (e) {
      _logger.e(
        'Error caching subscription ${subscription.subscriptionId}: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearCachedSubscriptions() async {
    try {
      _logger.d('Clearing all cached subscriptions');

      final db = await _databaseService.database;
      await db.delete('subscriptions');

      _logger.d('Successfully cleared all cached subscriptions');
    } catch (e) {
      _logger.e('Error clearing cached subscriptions: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCachedSubscriptionsForAccount(String accountId) async {
    try {
      _logger.d('Clearing cached subscriptions for account: $accountId');

      final db = await _databaseService.database;
      await db.delete(
        'subscriptions',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      _logger.d(
        'Successfully cleared cached subscriptions for account $accountId',
      );
    } catch (e) {
      _logger.e(
        'Error clearing cached subscriptions for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedSubscription(String subscriptionId) async {
    try {
      _logger.d('Deleting cached subscription: $subscriptionId');

      final db = await _databaseService.database;
      await db.delete(
        'subscriptions',
        where: 'subscription_id = ?',
        whereArgs: [subscriptionId],
      );

      _logger.d('Successfully deleted cached subscription: $subscriptionId');
    } catch (e) {
      _logger.e('Error deleting cached subscription $subscriptionId: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedSubscriptions() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM subscriptions',
      );
      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      _logger.e('Error checking cached subscriptions: $e');
      return false;
    }
  }

  @override
  Future<bool> hasCachedSubscriptionsForAccount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM subscriptions WHERE account_id = ?',
        [accountId],
      );
      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      _logger.e(
        'Error checking cached subscriptions for account $accountId: $e',
      );
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
        whereArgs: ['subscriptions'],
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
        'table_name': 'subscriptions',
        'last_sync': now,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      _logger.d('Updated last sync time for subscriptions');
    } catch (e) {
      _logger.e('Error updating last sync time: $e');
      rethrow;
    }
  }

  Future<void> _insertSubscription(
    dynamic db,
    Subscription subscription,
  ) async {
    await db.insert('subscriptions', {
      'subscription_id': subscription.subscriptionId,
      'account_id': subscription.accountId,
      'bundle_id': subscription.bundleId,
      'bundle_external_key': subscription.bundleExternalKey,
      'external_key': subscription.externalKey,
      'start_date': subscription.startDate.toIso8601String(),
      'product_name': subscription.productName,
      'product_category': subscription.productCategory,
      'billing_period': subscription.billingPeriod,
      'phase_type': subscription.phaseType,
      'price_list': subscription.priceList,
      'plan_name': subscription.planName,
      'state': subscription.state,
      'source_type': subscription.sourceType,
      'cancelled_date': subscription.cancelledDate?.toIso8601String(),
      'charged_through_date': subscription.chargedThroughDate,
      'billing_start_date': subscription.billingStartDate.toIso8601String(),
      'billing_end_date': subscription.billingEndDate?.toIso8601String(),
      'bill_cycle_day_local': subscription.billCycleDayLocal,
      'quantity': subscription.quantity,
      'events': jsonEncode(
        subscription.events.map((e) => _eventToMap(e)).toList(),
      ),
      'price_overrides': subscription.priceOverrides != null
          ? jsonEncode(subscription.priceOverrides)
          : null,
      'prices': jsonEncode(subscription.prices),
      'audit_logs': subscription.auditLogs != null
          ? jsonEncode(subscription.auditLogs)
          : null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Subscription _mapToSubscription(Map<String, dynamic> map) {
    return Subscription(
      accountId: map['account_id'] as String,
      bundleId: map['bundle_id'] as String,
      bundleExternalKey: map['bundle_external_key'] as String,
      subscriptionId: map['subscription_id'] as String,
      externalKey: map['external_key'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      productName: map['product_name'] as String,
      productCategory: map['product_category'] as String,
      billingPeriod: map['billing_period'] as String,
      phaseType: map['phase_type'] as String,
      priceList: map['price_list'] as String,
      planName: map['plan_name'] as String,
      state: map['state'] as String,
      sourceType: map['source_type'] as String,
      cancelledDate: map['cancelled_date'] != null
          ? DateTime.parse(map['cancelled_date'] as String)
          : null,
      chargedThroughDate: map['charged_through_date'] as String,
      billingStartDate: DateTime.parse(map['billing_start_date'] as String),
      billingEndDate: map['billing_end_date'] != null
          ? DateTime.parse(map['billing_end_date'] as String)
          : null,
      billCycleDayLocal: map['bill_cycle_day_local'] as int,
      quantity: map['quantity'] as int,
      events: _parseEvents(map['events'] as String?),
      priceOverrides: map['price_overrides'] != null
          ? jsonDecode(map['price_overrides'] as String)
          : null,
      prices: jsonDecode(map['prices'] as String? ?? '[]'),
      auditLogs: map['audit_logs'] != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(map['audit_logs'] as String),
            )
          : null,
    );
  }

  List<SubscriptionEvent> _parseEvents(String? eventsJson) {
    if (eventsJson == null || eventsJson.isEmpty) return [];

    try {
      final List<dynamic> eventsList = jsonDecode(eventsJson);
      return eventsList.map((eventMap) => _mapToEvent(eventMap)).toList();
    } catch (e) {
      _logger.e('Error parsing events: $e');
      return [];
    }
  }

  SubscriptionEvent _mapToEvent(Map<String, dynamic> eventMap) {
    return SubscriptionEvent(
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
          : null,
    );
  }

  Map<String, dynamic> _eventToMap(SubscriptionEvent event) {
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
