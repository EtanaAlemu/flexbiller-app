import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../../core/services/database_service.dart';
import '../../models/plan_model.dart';
import '../../models/plan_feature_model.dart';

abstract class PlansLocalDataSource {
  Future<void> cachePlans(List<PlanModel> plans);
  Future<List<PlanModel>> getCachedPlans();
  Future<void> cachePlan(PlanModel plan);
  Future<PlanModel?> getCachedPlanById(String planId);
  Future<void> clearCachedPlans();
}

@LazySingleton(as: PlansLocalDataSource)
class PlansLocalDataSourceImpl implements PlansLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger;

  PlansLocalDataSourceImpl(this._databaseService, this._logger);

  @override
  Future<void> cachePlans(List<PlanModel> plans) async {
    try {
      _logger.d('Caching ${plans.length} plans to local storage');

      // Clear existing plans first
      await clearCachedPlans();

      // Insert new plans
      for (final plan in plans) {
        await _cachePlan(plan);
      }

      _logger.d('Successfully cached ${plans.length} plans');
    } catch (e) {
      _logger.e('Error caching plans: $e');
      rethrow;
    }
  }

  @override
  Future<List<PlanModel>> getCachedPlans() async {
    try {
      _logger.d('Retrieving cached plans from local storage');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> plansData = await db.query(
        'plans',
        orderBy: 'created_at DESC',
      );

      final List<PlanModel> plans = [];
      for (final planData in plansData) {
        final planId = planData['id'] as String;

        // Get plan features
        final List<Map<String, dynamic>> featuresData = await db.query(
          'plan_features',
          where: 'plan_id = ?',
          whereArgs: [planId],
        );

        final planFeatures = featuresData
            .map(
              (featureData) => {
                'id': featureData['id'] as String,
                'planId': featureData['plan_id'] as String,
                'featureName': featureData['feature_name'] as String,
                'featureValue': featureData['feature_value'] as String,
                'createdAt': featureData['created_at'] as String,
              },
            )
            .toList();

        final planModel = PlanModel(
          id: planData['id'] as String,
          name: planData['name'] as String,
          description: planData['description'] as String,
          price: (planData['price'] as num).toDouble(),
          billingCycle: planData['billing_cycle'] as String,
          trialDays: planData['trial_days'] as int,
          isActive: (planData['is_active'] as int) == 1,
          createdAt: DateTime.parse(planData['created_at'] as String),
          updatedAt: DateTime.parse(planData['updated_at'] as String),
          flexbillPlanFeatures: planFeatures
              .map((feature) => PlanFeatureModel.fromJson(feature))
              .toList(),
        );

        plans.add(planModel);
      }

      _logger.d('Retrieved ${plans.length} cached plans');
      return plans;
    } catch (e) {
      _logger.e('Error retrieving cached plans: $e');
      rethrow;
    }
  }

  @override
  Future<void> cachePlan(PlanModel plan) async {
    try {
      _logger.d('Caching plan: ${plan.id}');
      await _cachePlan(plan);
      _logger.d('Successfully cached plan: ${plan.id}');
    } catch (e) {
      _logger.e('Error caching plan ${plan.id}: $e');
      rethrow;
    }
  }

  @override
  Future<PlanModel?> getCachedPlanById(String planId) async {
    try {
      _logger.d('Retrieving cached plan by ID: $planId');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> plansData = await db.query(
        'plans',
        where: 'id = ?',
        whereArgs: [planId],
        limit: 1,
      );

      if (plansData.isEmpty) {
        _logger.d('No cached plan found for ID: $planId');
        return null;
      }

      final planData = plansData.first;

      // Get plan features
      final List<Map<String, dynamic>> featuresData = await db.query(
        'plan_features',
        where: 'plan_id = ?',
        whereArgs: [planId],
      );

      final planFeatures = featuresData
          .map(
            (featureData) => {
              'id': featureData['id'] as String,
              'planId': featureData['plan_id'] as String,
              'featureName': featureData['feature_name'] as String,
              'featureValue': featureData['feature_value'] as String,
              'createdAt': featureData['created_at'] as String,
            },
          )
          .toList();

      final planModel = PlanModel(
        id: planData['id'] as String,
        name: planData['name'] as String,
        description: planData['description'] as String,
        price: (planData['price'] as num).toDouble(),
        billingCycle: planData['billing_cycle'] as String,
        trialDays: planData['trial_days'] as int,
        isActive: (planData['is_active'] as int) == 1,
        createdAt: DateTime.parse(planData['created_at'] as String),
        updatedAt: DateTime.parse(planData['updated_at'] as String),
        flexbillPlanFeatures: planFeatures
            .map((feature) => PlanFeatureModel.fromJson(feature))
            .toList(),
      );

      _logger.d('Retrieved cached plan: ${planModel.id}');
      return planModel;
    } catch (e) {
      _logger.e('Error retrieving cached plan $planId: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCachedPlans() async {
    try {
      _logger.d('Clearing cached plans from local storage');

      final db = await _databaseService.database;
      await db.delete('plan_features');
      await db.delete('plans');

      _logger.d('Successfully cleared cached plans');
    } catch (e) {
      _logger.e('Error clearing cached plans: $e');
      rethrow;
    }
  }

  Future<void> _cachePlan(PlanModel plan) async {
    final db = await _databaseService.database;

    // Insert or replace plan
    await db.insert('plans', {
      'id': plan.id,
      'name': plan.name,
      'description': plan.description,
      'price': plan.price,
      'billing_cycle': plan.billingCycle,
      'trial_days': plan.trialDays,
      'is_active': plan.isActive ? 1 : 0,
      'created_at': plan.createdAt.toIso8601String(),
      'updated_at': plan.updatedAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Delete existing plan features first
    await db.delete(
      'plan_features',
      where: 'plan_id = ?',
      whereArgs: [plan.id],
    );

    // Insert plan features
    for (final feature in plan.flexbillPlanFeatures) {
      await db.insert('plan_features', {
        'id': feature.id,
        'plan_id': feature.planId,
        'feature_name': feature.featureName,
        'feature_value': feature.featureValue,
        'created_at': feature.createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
