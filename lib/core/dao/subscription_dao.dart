import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/subscriptions/data/models/subscription_model.dart';
import '../../features/subscriptions/data/models/subscription_event_model.dart';

class SubscriptionDao {
  static const String tableName = 'subscriptions';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnSubscriptionId = 'subscription_id';
  static const String columnAccountId = 'account_id';
  static const String columnBundleId = 'bundle_id';
  static const String columnBundleExternalKey = 'bundle_external_key';
  static const String columnExternalKey = 'external_key';
  static const String columnStartDate = 'start_date';
  static const String columnProductName = 'product_name';
  static const String columnProductCategory = 'product_category';
  static const String columnBillingPeriod = 'billing_period';
  static const String columnPhaseType = 'phase_type';
  static const String columnPriceList = 'price_list';
  static const String columnPlanName = 'plan_name';
  static const String columnState = 'state';
  static const String columnSourceType = 'source_type';
  static const String columnCancelledDate = 'cancelled_date';
  static const String columnChargedThroughDate = 'charged_through_date';
  static const String columnBillingStartDate = 'billing_start_date';
  static const String columnBillingEndDate = 'billing_end_date';
  static const String columnBillCycleDayLocal = 'bill_cycle_day_local';
  static const String columnQuantity = 'quantity';
  static const String columnEvents = 'events';
  static const String columnPriceOverrides = 'price_overrides';
  static const String columnPrices = 'prices';
  static const String columnAuditLogs = 'audit_logs';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnSubscriptionId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnBundleId TEXT NOT NULL,
      $columnBundleExternalKey TEXT NOT NULL,
      $columnExternalKey TEXT NOT NULL,
      $columnStartDate TEXT NOT NULL,
      $columnProductName TEXT NOT NULL,
      $columnProductCategory TEXT NOT NULL,
      $columnBillingPeriod TEXT NOT NULL,
      $columnPhaseType TEXT NOT NULL,
      $columnPriceList TEXT NOT NULL,
      $columnPlanName TEXT NOT NULL,
      $columnState TEXT NOT NULL,
      $columnSourceType TEXT NOT NULL,
      $columnCancelledDate TEXT,
      $columnChargedThroughDate TEXT NOT NULL,
      $columnBillingStartDate TEXT NOT NULL,
      $columnBillingEndDate TEXT,
      $columnBillCycleDayLocal INTEGER NOT NULL,
      $columnQuantity INTEGER NOT NULL,
      $columnEvents TEXT NOT NULL,
      $columnPriceOverrides TEXT,
      $columnPrices TEXT NOT NULL,
      $columnAuditLogs TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  /// Insert or update a subscription
  static Future<void> insertOrUpdate(
    Database db,
    SubscriptionModel subscription,
  ) async {
    try {
      final subscriptionData = {
        columnSubscriptionId: subscription.subscriptionId,
        columnAccountId: subscription.accountId,
        columnBundleId: subscription.bundleId,
        columnBundleExternalKey: subscription.bundleExternalKey,
        columnExternalKey: subscription.externalKey,
        columnStartDate: subscription.startDate,
        columnProductName: subscription.productName,
        columnProductCategory: subscription.productCategory,
        columnBillingPeriod: subscription.billingPeriod,
        columnPhaseType: subscription.phaseType,
        columnPriceList: subscription.priceList,
        columnPlanName: subscription.planName,
        columnState: subscription.state,
        columnSourceType: subscription.sourceType,
        columnCancelledDate: subscription.cancelledDate,
        columnChargedThroughDate: subscription.chargedThroughDate,
        columnBillingStartDate: subscription.billingStartDate,
        columnBillingEndDate: subscription.billingEndDate,
        columnBillCycleDayLocal: subscription.billCycleDayLocal,
        columnQuantity: subscription.quantity,
        columnEvents: subscription.events
            .map((e) => e.toJson())
            .toList()
            .toString(),
        columnPriceOverrides: subscription.priceOverrides?.toString(),
        columnPrices: subscription.prices.toString(),
        columnAuditLogs: subscription.auditLogs?.toString(),
        columnCreatedAt: DateTime.now().toIso8601String(),
        columnUpdatedAt: DateTime.now().toIso8601String(),
      };

      await db.insert(
        tableName,
        subscriptionData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.d(
        'Subscription inserted/updated successfully: ${subscription.subscriptionId}',
      );
    } catch (e) {
      _logger.e('Error inserting subscription: $e');
      rethrow;
    }
  }

  /// Update a subscription
  static Future<void> update(
    Database db,
    String subscriptionId,
    Map<String, dynamic> subscriptionData,
  ) async {
    try {
      subscriptionData[columnUpdatedAt] = DateTime.now().toIso8601String();
      await db.update(
        tableName,
        subscriptionData,
        where: '$columnSubscriptionId = ?',
        whereArgs: [subscriptionId],
      );
      _logger.d('Subscription updated successfully: $subscriptionId');
    } catch (e) {
      _logger.e('Error updating subscription: $e');
      rethrow;
    }
  }

  /// Get subscription by ID
  static Future<SubscriptionModel?> getById(
    Database db,
    String subscriptionId,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnSubscriptionId = ?',
        whereArgs: [subscriptionId],
      );

      if (results.isEmpty) {
        _logger.d('Subscription not found: $subscriptionId');
        return null;
      }

      final subscriptionData = results.first;

      // Parse events from JSON string
      List<SubscriptionEventModel> events = [];
      try {
        // Note: This is a simplified approach. In a real app, you'd want proper JSON parsing
        // For now, we'll create empty events list
        events = [];
      } catch (e) {
        _logger.w('Error parsing events: $e');
        events = [];
      }

      final subscription = SubscriptionModel(
        accountId: subscriptionData[columnAccountId] as String,
        bundleId: subscriptionData[columnBundleId] as String,
        bundleExternalKey: subscriptionData[columnBundleExternalKey] as String,
        subscriptionId: subscriptionData[columnSubscriptionId] as String,
        externalKey: subscriptionData[columnExternalKey] as String,
        startDate: subscriptionData[columnStartDate] as String,
        productName: subscriptionData[columnProductName] as String,
        productCategory: subscriptionData[columnProductCategory] as String,
        billingPeriod: subscriptionData[columnBillingPeriod] as String,
        phaseType: subscriptionData[columnPhaseType] as String,
        priceList: subscriptionData[columnPriceList] as String,
        planName: subscriptionData[columnPlanName] as String,
        state: subscriptionData[columnState] as String,
        sourceType: subscriptionData[columnSourceType] as String,
        cancelledDate: subscriptionData[columnCancelledDate] as String?,
        chargedThroughDate:
            subscriptionData[columnChargedThroughDate] as String,
        billingStartDate: subscriptionData[columnBillingStartDate] as String,
        billingEndDate: subscriptionData[columnBillingEndDate] as String?,
        billCycleDayLocal: subscriptionData[columnBillCycleDayLocal] as int,
        quantity: subscriptionData[columnQuantity] as int,
        events: events,
        priceOverrides: subscriptionData[columnPriceOverrides],
        prices: [], // Simplified - would need proper parsing
        auditLogs: subscriptionData[columnAuditLogs] != null
            ? [] // Simplified - would need proper parsing
            : null,
      );

      _logger.d('Subscription retrieved successfully: $subscriptionId');
      return subscription;
    } catch (e) {
      _logger.e('Error retrieving subscription: $e');
      rethrow;
    }
  }

  /// Get all subscriptions
  static Future<List<SubscriptionModel>> getAll(Database db) async {
    try {
      final results = await db.query(
        tableName,
        orderBy: '$columnCreatedAt DESC',
      );
      final subscriptions = <SubscriptionModel>[];

      for (final subscriptionData in results) {
        // Parse events from JSON string
        List<SubscriptionEventModel> events = [];
        try {
          // Note: This is a simplified approach. In a real app, you'd want proper JSON parsing
          events = [];
        } catch (e) {
          _logger.w('Error parsing events: $e');
          events = [];
        }

        final subscription = SubscriptionModel(
          accountId: subscriptionData[columnAccountId] as String,
          bundleId: subscriptionData[columnBundleId] as String,
          bundleExternalKey:
              subscriptionData[columnBundleExternalKey] as String,
          subscriptionId: subscriptionData[columnSubscriptionId] as String,
          externalKey: subscriptionData[columnExternalKey] as String,
          startDate: subscriptionData[columnStartDate] as String,
          productName: subscriptionData[columnProductName] as String,
          productCategory: subscriptionData[columnProductCategory] as String,
          billingPeriod: subscriptionData[columnBillingPeriod] as String,
          phaseType: subscriptionData[columnPhaseType] as String,
          priceList: subscriptionData[columnPriceList] as String,
          planName: subscriptionData[columnPlanName] as String,
          state: subscriptionData[columnState] as String,
          sourceType: subscriptionData[columnSourceType] as String,
          cancelledDate: subscriptionData[columnCancelledDate] as String?,
          chargedThroughDate:
              subscriptionData[columnChargedThroughDate] as String,
          billingStartDate: subscriptionData[columnBillingStartDate] as String,
          billingEndDate: subscriptionData[columnBillingEndDate] as String?,
          billCycleDayLocal: subscriptionData[columnBillCycleDayLocal] as int,
          quantity: subscriptionData[columnQuantity] as int,
          events: events,
          priceOverrides: subscriptionData[columnPriceOverrides],
          prices: [], // Simplified - would need proper parsing
          auditLogs: subscriptionData[columnAuditLogs] != null
              ? [] // Simplified - would need proper parsing
              : null,
        );

        subscriptions.add(subscription);
      }

      _logger.d('Retrieved ${subscriptions.length} subscriptions');
      return subscriptions;
    } catch (e) {
      _logger.e('Error retrieving all subscriptions: $e');
      rethrow;
    }
  }

  /// Get subscriptions by account ID
  static Future<List<SubscriptionModel>> getByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnCreatedAt DESC',
      );

      final subscriptions = <SubscriptionModel>[];

      for (final subscriptionData in results) {
        // Parse events from JSON string
        List<SubscriptionEventModel> events = [];
        try {
          // Note: This is a simplified approach. In a real app, you'd want proper JSON parsing
          events = [];
        } catch (e) {
          _logger.w('Error parsing events: $e');
          events = [];
        }

        final subscription = SubscriptionModel(
          accountId: subscriptionData[columnAccountId] as String,
          bundleId: subscriptionData[columnBundleId] as String,
          bundleExternalKey:
              subscriptionData[columnBundleExternalKey] as String,
          subscriptionId: subscriptionData[columnSubscriptionId] as String,
          externalKey: subscriptionData[columnExternalKey] as String,
          startDate: subscriptionData[columnStartDate] as String,
          productName: subscriptionData[columnProductName] as String,
          productCategory: subscriptionData[columnProductCategory] as String,
          billingPeriod: subscriptionData[columnBillingPeriod] as String,
          phaseType: subscriptionData[columnPhaseType] as String,
          priceList: subscriptionData[columnPriceList] as String,
          planName: subscriptionData[columnPlanName] as String,
          state: subscriptionData[columnState] as String,
          sourceType: subscriptionData[columnSourceType] as String,
          cancelledDate: subscriptionData[columnCancelledDate] as String?,
          chargedThroughDate:
              subscriptionData[columnChargedThroughDate] as String,
          billingStartDate: subscriptionData[columnBillingStartDate] as String,
          billingEndDate: subscriptionData[columnBillingEndDate] as String?,
          billCycleDayLocal: subscriptionData[columnBillCycleDayLocal] as int,
          quantity: subscriptionData[columnQuantity] as int,
          events: events,
          priceOverrides: subscriptionData[columnPriceOverrides],
          prices: [], // Simplified - would need proper parsing
          auditLogs: subscriptionData[columnAuditLogs] != null
              ? [] // Simplified - would need proper parsing
              : null,
        );

        subscriptions.add(subscription);
      }

      _logger.d(
        'Retrieved ${subscriptions.length} subscriptions for account: $accountId',
      );
      return subscriptions;
    } catch (e) {
      _logger.e('Error retrieving subscriptions by account ID: $e');
      rethrow;
    }
  }

  /// Search subscriptions by product name or plan name
  static Future<List<SubscriptionModel>> search(
    Database db,
    String searchQuery,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnProductName LIKE ? OR $columnPlanName LIKE ?',
        whereArgs: ['%$searchQuery%', '%$searchQuery%'],
        orderBy: '$columnCreatedAt DESC',
      );

      final subscriptions = <SubscriptionModel>[];

      for (final subscriptionData in results) {
        // Parse events from JSON string
        List<SubscriptionEventModel> events = [];
        try {
          // Note: This is a simplified approach. In a real app, you'd want proper JSON parsing
          events = [];
        } catch (e) {
          _logger.w('Error parsing events: $e');
          events = [];
        }

        final subscription = SubscriptionModel(
          accountId: subscriptionData[columnAccountId] as String,
          bundleId: subscriptionData[columnBundleId] as String,
          bundleExternalKey:
              subscriptionData[columnBundleExternalKey] as String,
          subscriptionId: subscriptionData[columnSubscriptionId] as String,
          externalKey: subscriptionData[columnExternalKey] as String,
          startDate: subscriptionData[columnStartDate] as String,
          productName: subscriptionData[columnProductName] as String,
          productCategory: subscriptionData[columnProductCategory] as String,
          billingPeriod: subscriptionData[columnBillingPeriod] as String,
          phaseType: subscriptionData[columnPhaseType] as String,
          priceList: subscriptionData[columnPriceList] as String,
          planName: subscriptionData[columnPlanName] as String,
          state: subscriptionData[columnState] as String,
          sourceType: subscriptionData[columnSourceType] as String,
          cancelledDate: subscriptionData[columnCancelledDate] as String?,
          chargedThroughDate:
              subscriptionData[columnChargedThroughDate] as String,
          billingStartDate: subscriptionData[columnBillingStartDate] as String,
          billingEndDate: subscriptionData[columnBillingEndDate] as String?,
          billCycleDayLocal: subscriptionData[columnBillCycleDayLocal] as int,
          quantity: subscriptionData[columnQuantity] as int,
          events: events,
          priceOverrides: subscriptionData[columnPriceOverrides],
          prices: [], // Simplified - would need proper parsing
          auditLogs: subscriptionData[columnAuditLogs] != null
              ? [] // Simplified - would need proper parsing
              : null,
        );

        subscriptions.add(subscription);
      }

      _logger.d(
        'Found ${subscriptions.length} subscriptions matching "$searchQuery"',
      );
      return subscriptions;
    } catch (e) {
      _logger.e('Error searching subscriptions: $e');
      rethrow;
    }
  }

  /// Delete subscription by ID
  static Future<void> deleteById(Database db, String subscriptionId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnSubscriptionId = ?',
        whereArgs: [subscriptionId],
      );

      _logger.d('Subscription deleted successfully: $subscriptionId');
    } catch (e) {
      _logger.e('Error deleting subscription: $e');
      rethrow;
    }
  }

  /// Delete all subscriptions
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All subscriptions deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all subscriptions: $e');
      rethrow;
    }
  }

  /// Get subscription count
  static Future<int> getCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = result.first['count'] as int;
      _logger.d('Subscription count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting subscription count: $e');
      rethrow;
    }
  }

  /// Check if subscription exists
  static Future<bool> exists(Database db, String subscriptionId) async {
    try {
      final result = await db.rawQuery(
        'SELECT 1 FROM $tableName WHERE $columnSubscriptionId = ?',
        [subscriptionId],
      );
      return result.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking if subscription exists: $e');
      rethrow;
    }
  }
}
