import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/plans/data/models/plan_model.dart';
import '../../features/plans/data/models/plan_feature_model.dart';

class PlanDao {
  static const String tableName = 'plans';
  static const String featuresTableName = 'plan_features';
  static final Logger _logger = Logger();

  // Column names constants for plans table
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnPrice = 'price';
  static const String columnBillingCycle = 'billing_cycle';
  static const String columnTrialDays = 'trial_days';
  static const String columnIsActive = 'is_active';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Column names constants for plan_features table
  static const String columnFeatureId = 'id';
  static const String columnPlanId = 'plan_id';
  static const String columnFeatureName = 'feature_name';
  static const String columnFeatureValue = 'feature_value';
  static const String columnFeatureCreatedAt = 'created_at';

  static const String createTableSQL = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnDescription TEXT NOT NULL,
      $columnPrice REAL NOT NULL,
      $columnBillingCycle TEXT NOT NULL,
      $columnTrialDays INTEGER NOT NULL,
      $columnIsActive INTEGER NOT NULL DEFAULT 1,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  static const String createPlanFeaturesTableSQL = '''
    CREATE TABLE $featuresTableName (
      $columnFeatureId TEXT PRIMARY KEY,
      $columnPlanId TEXT NOT NULL,
      $columnFeatureName TEXT NOT NULL,
      $columnFeatureValue TEXT NOT NULL,
      $columnFeatureCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($columnPlanId) REFERENCES $tableName ($columnId) ON DELETE CASCADE
    )
  ''';

  /// Insert or update a plan
  static Future<void> insertOrUpdate(
    Database db,
    PlanModel plan,
  ) async {
    try {
      // Insert/update plan
      final planData = {
        columnId: plan.id,
        columnName: plan.name,
        columnDescription: plan.description,
        columnPrice: plan.price,
        columnBillingCycle: plan.billingCycle,
        columnTrialDays: plan.trialDays,
        columnIsActive: plan.isActive ? 1 : 0,
        columnCreatedAt: plan.createdAt.toIso8601String(),
        columnUpdatedAt: plan.updatedAt.toIso8601String(),
      };

      await db.insert(
        tableName,
        planData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert/update plan features
      for (final feature in plan.flexbillPlanFeatures) {
        final featureData = {
          columnFeatureId: feature.id,
          columnPlanId: plan.id,
          columnFeatureName: feature.featureName,
          columnFeatureValue: feature.featureValue,
          columnFeatureCreatedAt: feature.createdAt.toIso8601String(),
        };

        await db.insert(
          featuresTableName,
          featureData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      _logger.d('Plan inserted/updated successfully: ${plan.name}');
    } catch (e) {
      _logger.e('Error inserting plan: $e');
      rethrow;
    }
  }

  /// Update a plan
  static Future<void> update(
    Database db,
    String planId,
    Map<String, dynamic> planData,
  ) async {
    try {
      planData[columnUpdatedAt] = DateTime.now().toIso8601String();
      await db.update(
        tableName,
        planData,
        where: '$columnId = ?',
        whereArgs: [planId],
      );
      _logger.d('Plan updated successfully: $planId');
    } catch (e) {
      _logger.e('Error updating plan: $e');
      rethrow;
    }
  }

  /// Get plan by ID
  static Future<PlanModel?> getById(
    Database db,
    String planId,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [planId],
      );

      if (results.isEmpty) {
        _logger.d('Plan not found: $planId');
        return null;
      }

      final planData = results.first;
      
      // Get plan features
      final featuresResults = await db.query(
        featuresTableName,
        where: '$columnPlanId = ?',
        whereArgs: [planId],
      );

      final features = featuresResults.map((featureData) {
        return PlanFeatureModel(
          id: featureData[columnFeatureId] as String,
          planId: planId,
          featureName: featureData[columnFeatureName] as String,
          featureValue: featureData[columnFeatureValue] as String,
          createdAt: DateTime.parse(featureData[columnFeatureCreatedAt] as String),
        );
      }).toList();

      final plan = PlanModel(
        id: planData[columnId] as String,
        name: planData[columnName] as String,
        description: planData[columnDescription] as String,
        price: planData[columnPrice] as double,
        billingCycle: planData[columnBillingCycle] as String,
        trialDays: planData[columnTrialDays] as int,
        isActive: (planData[columnIsActive] as int) == 1,
        createdAt: DateTime.parse(planData[columnCreatedAt] as String),
        updatedAt: DateTime.parse(planData[columnUpdatedAt] as String),
        flexbillPlanFeatures: features,
      );

      _logger.d('Plan retrieved successfully: $planId');
      return plan;
    } catch (e) {
      _logger.e('Error retrieving plan: $e');
      rethrow;
    }
  }

  /// Get all plans
  static Future<List<PlanModel>> getAll(Database db) async {
    try {
      final results = await db.query(tableName, orderBy: '$columnName ASC');
      final plans = <PlanModel>[];

      for (final planData in results) {
        final planId = planData[columnId] as String;
        
        // Get plan features for each plan
        final featuresResults = await db.query(
          featuresTableName,
          where: '$columnPlanId = ?',
          whereArgs: [planId],
        );

        final features = featuresResults.map((featureData) {
          return PlanFeatureModel(
            id: featureData[columnFeatureId] as String,
            planId: planId,
            featureName: featureData[columnFeatureName] as String,
            featureValue: featureData[columnFeatureValue] as String,
            createdAt: DateTime.parse(featureData[columnFeatureCreatedAt] as String),
          );
        }).toList();

        final plan = PlanModel(
          id: planData[columnId] as String,
          name: planData[columnName] as String,
          description: planData[columnDescription] as String,
          price: planData[columnPrice] as double,
          billingCycle: planData[columnBillingCycle] as String,
          trialDays: planData[columnTrialDays] as int,
          isActive: (planData[columnIsActive] as int) == 1,
          createdAt: DateTime.parse(planData[columnCreatedAt] as String),
          updatedAt: DateTime.parse(planData[columnUpdatedAt] as String),
          flexbillPlanFeatures: features,
        );

        plans.add(plan);
      }

      _logger.d('Retrieved ${plans.length} plans');
      return plans;
    } catch (e) {
      _logger.e('Error retrieving all plans: $e');
      rethrow;
    }
  }

  /// Get active plans only
  static Future<List<PlanModel>> getActivePlans(Database db) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnIsActive = ?',
        whereArgs: [1],
        orderBy: '$columnName ASC',
      );
      
      final plans = <PlanModel>[];

      for (final planData in results) {
        final planId = planData[columnId] as String;
        
        // Get plan features for each plan
        final featuresResults = await db.query(
          featuresTableName,
          where: '$columnPlanId = ?',
          whereArgs: [planId],
        );

        final features = featuresResults.map((featureData) {
          return PlanFeatureModel(
            id: featureData[columnFeatureId] as String,
            planId: planId,
            featureName: featureData[columnFeatureName] as String,
            featureValue: featureData[columnFeatureValue] as String,
            createdAt: DateTime.parse(featureData[columnFeatureCreatedAt] as String),
          );
        }).toList();

        final plan = PlanModel(
          id: planData[columnId] as String,
          name: planData[columnName] as String,
          description: planData[columnDescription] as String,
          price: planData[columnPrice] as double,
          billingCycle: planData[columnBillingCycle] as String,
          trialDays: planData[columnTrialDays] as int,
          isActive: true,
          createdAt: DateTime.parse(planData[columnCreatedAt] as String),
          updatedAt: DateTime.parse(planData[columnUpdatedAt] as String),
          flexbillPlanFeatures: features,
        );

        plans.add(plan);
      }

      _logger.d('Retrieved ${plans.length} active plans');
      return plans;
    } catch (e) {
      _logger.e('Error retrieving active plans: $e');
      rethrow;
    }
  }

  /// Search plans by name or description
  static Future<List<PlanModel>> search(
    Database db,
    String searchQuery,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnName LIKE ? OR $columnDescription LIKE ?',
        whereArgs: ['%$searchQuery%', '%$searchQuery%'],
        orderBy: '$columnName ASC',
      );
      
      final plans = <PlanModel>[];

      for (final planData in results) {
        final planId = planData[columnId] as String;
        
        // Get plan features for each plan
        final featuresResults = await db.query(
          featuresTableName,
          where: '$columnPlanId = ?',
          whereArgs: [planId],
        );

        final features = featuresResults.map((featureData) {
          return PlanFeatureModel(
            id: featureData[columnFeatureId] as String,
            planId: planId,
            featureName: featureData[columnFeatureName] as String,
            featureValue: featureData[columnFeatureValue] as String,
            createdAt: DateTime.parse(featureData[columnFeatureCreatedAt] as String),
          );
        }).toList();

        final plan = PlanModel(
          id: planData[columnId] as String,
          name: planData[columnName] as String,
          description: planData[columnDescription] as String,
          price: planData[columnPrice] as double,
          billingCycle: planData[columnBillingCycle] as String,
          trialDays: planData[columnTrialDays] as int,
          isActive: (planData[columnIsActive] as int) == 1,
          createdAt: DateTime.parse(planData[columnCreatedAt] as String),
          updatedAt: DateTime.parse(planData[columnUpdatedAt] as String),
          flexbillPlanFeatures: features,
        );

        plans.add(plan);
      }

      _logger.d('Found ${plans.length} plans matching "$searchQuery"');
      return plans;
    } catch (e) {
      _logger.e('Error searching plans: $e');
      rethrow;
    }
  }

  /// Delete plan by ID
  static Future<void> deleteById(Database db, String planId) async {
    try {
      // Delete plan features first (due to foreign key constraint)
      await db.delete(
        featuresTableName,
        where: '$columnPlanId = ?',
        whereArgs: [planId],
      );

      // Delete plan
      await db.delete(
        tableName,
        where: '$columnId = ?',
        whereArgs: [planId],
      );

      _logger.d('Plan deleted successfully: $planId');
    } catch (e) {
      _logger.e('Error deleting plan: $e');
      rethrow;
    }
  }

  /// Delete all plans
  static Future<void> deleteAll(Database db) async {
    try {
      // Delete all plan features first
      await db.delete(featuresTableName);
      
      // Delete all plans
      await db.delete(tableName);
      
      _logger.d('All plans deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all plans: $e');
      rethrow;
    }
  }

  /// Get plan count
  static Future<int> getCount(Database db) async {
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = result.first['count'] as int;
      _logger.d('Plan count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting plan count: $e');
      rethrow;
    }
  }

  /// Check if plan exists
  static Future<bool> exists(Database db, String planId) async {
    try {
      final result = await db.rawQuery(
        'SELECT 1 FROM $tableName WHERE $columnId = ?',
        [planId],
      );
      return result.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking if plan exists: $e');
      rethrow;
    }
  }
}