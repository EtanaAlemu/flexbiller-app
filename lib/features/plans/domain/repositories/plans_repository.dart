import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/plan.dart';

abstract class PlansRepository {
  /// Get all available plans
  /// Returns cached plans immediately, then syncs with remote in background
  Future<Either<Failure, List<Plan>>> getPlans();

  /// Get a specific plan by ID
  /// Returns cached plan immediately, then syncs with remote in background
  Future<Either<Failure, Plan>> getPlanById(String planId);

  /// Get cached plans from local storage
  Future<Either<Failure, List<Plan>>> getCachedPlans();

  /// Get cached plan by ID from local storage
  Future<Either<Failure, Plan>> getCachedPlanById(String planId);
}
