import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/bundles/data/models/bundle_model.dart';
import '../../features/bundles/data/models/bundle_subscription_model.dart';
import '../../features/bundles/data/models/bundle_timeline_model.dart';

class BundlesDao {
  static const String tableName = 'bundles';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnBundleId = 'bundle_id';
  static const String columnAccountId = 'account_id';
  static const String columnExternalKey = 'external_key';
  static const String columnSubscriptions = 'subscriptions';
  static const String columnTimeline = 'timeline';
  static const String columnAuditLogs = 'audit_logs';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnBundleId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnExternalKey TEXT NOT NULL,
      $columnSubscriptions TEXT NOT NULL,
      $columnTimeline TEXT NOT NULL,
      $columnAuditLogs TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  static const String createIndexesSQL =
      '''
    CREATE INDEX idx_bundles_account_id ON $tableName($columnAccountId);
    CREATE INDEX idx_bundles_external_key ON $tableName($columnExternalKey);
    CREATE INDEX idx_bundles_created_at ON $tableName($columnCreatedAt);
  ''';

  /// Insert or update a bundle
  static Future<void> insertOrUpdate(Database db, BundleModel bundle) async {
    try {
      final bundleData = {
        columnBundleId: bundle.bundleId,
        columnAccountId: bundle.accountId,
        columnExternalKey: bundle.externalKey,
        columnSubscriptions: bundle.subscriptions
            .map((s) => s.toJson())
            .toList()
            .toString(),
        columnTimeline: bundle.timeline.toJson().toString(),
        columnAuditLogs: bundle.auditLogs?.toString(),
        columnCreatedAt: DateTime.now().toIso8601String(),
        columnUpdatedAt: DateTime.now().toIso8601String(),
      };

      await db.insert(
        tableName,
        bundleData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.d('Bundle inserted/updated successfully: ${bundle.bundleId}');
    } catch (e) {
      _logger.e('Error inserting bundle: $e');
      rethrow;
    }
  }

  /// Update a bundle
  static Future<void> update(
    Database db,
    String bundleId,
    Map<String, dynamic> bundleData,
  ) async {
    try {
      bundleData[columnUpdatedAt] = DateTime.now().toIso8601String();
      await db.update(
        tableName,
        bundleData,
        where: '$columnBundleId = ?',
        whereArgs: [bundleId],
      );
      _logger.d('Bundle updated successfully: $bundleId');
    } catch (e) {
      _logger.e('Error updating bundle: $e');
      rethrow;
    }
  }

  /// Get bundle by ID
  static Future<BundleModel?> getById(Database db, String bundleId) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnBundleId = ?',
        whereArgs: [bundleId],
      );

      if (results.isEmpty) {
        _logger.d('Bundle not found: $bundleId');
        return null;
      }

      final bundleData = results.first;
      final bundle = _mapToBundleModel(bundleData);

      _logger.d('Bundle retrieved successfully: $bundleId');
      return bundle;
    } catch (e) {
      _logger.e('Error retrieving bundle: $e');
      rethrow;
    }
  }

  /// Get all bundles
  static Future<List<BundleModel>> getAll(Database db) async {
    try {
      final results = await db.query(
        tableName,
        orderBy: '$columnCreatedAt DESC',
      );
      final bundles = <BundleModel>[];

      for (final bundleData in results) {
        final bundle = _mapToBundleModel(bundleData);
        bundles.add(bundle);
      }

      _logger.d('Retrieved ${bundles.length} bundles');
      return bundles;
    } catch (e) {
      _logger.e('Error retrieving all bundles: $e');
      rethrow;
    }
  }

  /// Get bundles by account ID
  static Future<List<BundleModel>> getByAccountId(
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

      final bundles = <BundleModel>[];

      for (final bundleData in results) {
        final bundle = _mapToBundleModel(bundleData);
        bundles.add(bundle);
      }

      _logger.d('Retrieved ${bundles.length} bundles for account: $accountId');
      return bundles;
    } catch (e) {
      _logger.e('Error retrieving bundles by account ID: $e');
      rethrow;
    }
  }

  /// Search bundles by external key
  static Future<List<BundleModel>> search(
    Database db,
    String searchQuery,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnExternalKey LIKE ?',
        whereArgs: ['%$searchQuery%'],
        orderBy: '$columnCreatedAt DESC',
      );

      final bundles = <BundleModel>[];

      for (final bundleData in results) {
        final bundle = _mapToBundleModel(bundleData);
        bundles.add(bundle);
      }

      _logger.d('Found ${bundles.length} bundles matching "$searchQuery"');
      return bundles;
    } catch (e) {
      _logger.e('Error searching bundles: $e');
      rethrow;
    }
  }

  /// Delete bundle by ID
  static Future<void> deleteById(Database db, String bundleId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnBundleId = ?',
        whereArgs: [bundleId],
      );

      _logger.d('Bundle deleted successfully: $bundleId');
    } catch (e) {
      _logger.e('Error deleting bundle: $e');
      rethrow;
    }
  }

  /// Delete all bundles
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All bundles deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all bundles: $e');
      rethrow;
    }
  }

  /// Get bundle count
  static Future<int> getCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = result.first['count'] as int;
      _logger.d('Bundle count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting bundle count: $e');
      rethrow;
    }
  }

  /// Get bundle count by account ID
  static Future<int> getCountByAccountId(Database db, String accountId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final count = result.first['count'] as int;
      _logger.d('Bundle count for account $accountId: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting bundle count by account ID: $e');
      rethrow;
    }
  }

  /// Check if bundle exists
  static Future<bool> exists(Database db, String bundleId) async {
    try {
      final result = await db.rawQuery(
        'SELECT 1 FROM $tableName WHERE $columnBundleId = ?',
        [bundleId],
      );
      return result.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking if bundle exists: $e');
      rethrow;
    }
  }

  /// Check if bundles exist for account
  static Future<bool> hasBundlesForAccount(
    Database db,
    String accountId,
  ) async {
    try {
      final count = await getCountByAccountId(db, accountId);
      return count > 0;
    } catch (e) {
      _logger.e('Error checking if bundles exist for account: $e');
      rethrow;
    }
  }

  /// Get bundles with pagination
  static Future<List<BundleModel>> getByQuery(
    Database db, {
    int? limit,
    int? offset,
    String? orderBy,
    String? accountId,
  }) async {
    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (accountId != null) {
        whereClause = 'WHERE $columnAccountId = ?';
        whereArgs.add(accountId);
      }

      String limitClause = '';
      if (limit != null) {
        limitClause = 'LIMIT $limit';
        if (offset != null) {
          limitClause += ' OFFSET $offset';
        }
      }

      final String query =
          '''
        SELECT * FROM $tableName 
        $whereClause
        ${orderBy != null ? 'ORDER BY $orderBy' : 'ORDER BY $columnCreatedAt DESC'}
        $limitClause
      ''';

      final List<Map<String, dynamic>> results = await db.rawQuery(
        query,
        whereArgs,
      );

      final bundles = <BundleModel>[];
      for (final bundleData in results) {
        final bundle = _mapToBundleModel(bundleData);
        bundles.add(bundle);
      }

      _logger.d('Retrieved ${bundles.length} bundles with query');
      return bundles;
    } catch (e) {
      _logger.e('Error getting bundles by query: $e');
      rethrow;
    }
  }

  /// Maps database row to BundleModel
  static BundleModel _mapToBundleModel(Map<String, dynamic> map) {
    // Parse subscriptions from JSON string
    List<BundleSubscriptionModel> subscriptions = [];
    try {
      // Note: This is a simplified approach. In a real app, you'd want proper JSON parsing
      // For now, we'll create empty subscriptions list
      subscriptions = [];
    } catch (e) {
      _logger.w('Error parsing subscriptions: $e');
      subscriptions = [];
    }

    // Parse timeline from JSON string
    BundleTimelineModel timeline;
    try {
      // Note: This is a simplified approach. In a real app, you'd want proper JSON parsing
      // For now, we'll create a default timeline
      timeline = BundleTimelineModel(
        bundleId: map[columnBundleId] as String,
        accountId: map[columnAccountId] as String,
        externalKey: map[columnExternalKey] as String,
        events: [],
        auditLogs: [],
      );
    } catch (e) {
      _logger.w('Error parsing timeline: $e');
      timeline = BundleTimelineModel(
        bundleId: map[columnBundleId] as String,
        accountId: map[columnAccountId] as String,
        externalKey: map[columnExternalKey] as String,
        events: [],
        auditLogs: [],
      );
    }

    return BundleModel(
      bundleId: map[columnBundleId] as String,
      accountId: map[columnAccountId] as String,
      externalKey: map[columnExternalKey] as String,
      subscriptions: subscriptions,
      timeline: timeline,
      auditLogs: map[columnAuditLogs] != null ? [] : null, // Simplified
    );
  }
}
