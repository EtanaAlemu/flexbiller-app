import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/plans_repository.dart';
import '../datasources/local/plans_local_data_source.dart';
import '../datasources/remote/plans_remote_data_source.dart';

@LazySingleton(as: PlansRepository)
class PlansRepositoryImpl implements PlansRepository {
  final PlansRemoteDataSource _remoteDataSource;
  final PlansLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  PlansRepositoryImpl({
    required PlansRemoteDataSource remoteDataSource,
    required PlansLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Plan>>> getPlans() async {
    try {
      // First, try to get cached plans immediately (local-first approach)
      final cachedPlans = await _localDataSource.getCachedPlans();
      if (cachedPlans.isNotEmpty) {
        // Return cached data immediately
        final plans = cachedPlans.map((model) => model.toEntity()).toList();

        // Then sync with remote in background if online
        if (await _networkInfo.isConnected) {
          _syncPlansInBackground();
        }

        return Right(plans);
      }

      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePlans = await _remoteDataSource.getPlans();

          // Cache the remote data
          await _localDataSource.cachePlans(remotePlans);

          // Return the data
          final plans = remotePlans.map((model) => model.toEntity()).toList();
          return Right(plans);
        } catch (e) {
          return Left(ServerFailure('Failed to fetch plans: $e'));
        }
      } else {
        return Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e) {
      return Left(CacheFailure('Error accessing local storage: $e'));
    }
  }

  @override
  Future<Either<Failure, Plan>> getPlanById(String planId) async {
    try {
      // First, try to get cached plan immediately (local-first approach)
      final cachedPlan = await _localDataSource.getCachedPlanById(planId);
      if (cachedPlan != null) {
        // Return cached data immediately
        final plan = cachedPlan.toEntity();

        // Then sync with remote in background if online
        if (await _networkInfo.isConnected) {
          _syncPlanByIdInBackground(planId);
        }

        return Right(plan);
      }

      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePlan = await _remoteDataSource.getPlanById(planId);

          // Cache the remote data
          await _localDataSource.cachePlan(remotePlan);

          // Return the data
          final plan = remotePlan.toEntity();
          return Right(plan);
        } catch (e) {
          return Left(ServerFailure('Failed to fetch plan: $e'));
        }
      } else {
        return Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e) {
      return Left(CacheFailure('Error accessing local storage: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Plan>>> getCachedPlans() async {
    try {
      final cachedPlans = await _localDataSource.getCachedPlans();
      final plans = cachedPlans.map((model) => model.toEntity()).toList();
      return Right(plans);
    } catch (e) {
      return Left(CacheFailure('Error retrieving cached plans: $e'));
    }
  }

  @override
  Future<Either<Failure, Plan>> getCachedPlanById(String planId) async {
    try {
      final cachedPlan = await _localDataSource.getCachedPlanById(planId);
      if (cachedPlan != null) {
        final plan = cachedPlan.toEntity();
        return Right(plan);
      } else {
        return Left(CacheFailure('Plan not found in cache'));
      }
    } catch (e) {
      return Left(CacheFailure('Error retrieving cached plan: $e'));
    }
  }

  /// Sync plans with remote server in background
  Future<void> _syncPlansInBackground() async {
    try {
      final remotePlans = await _remoteDataSource.getPlans();
      await _localDataSource.cachePlans(remotePlans);
    } catch (e) {
      // Log error but don't throw - this is background sync
      // In a real app, you might want to use a proper logging service
      // print('Background sync failed: $e');
    }
  }

  /// Sync specific plan with remote server in background
  Future<void> _syncPlanByIdInBackground(String planId) async {
    try {
      final remotePlan = await _remoteDataSource.getPlanById(planId);
      await _localDataSource.cachePlan(remotePlan);
    } catch (e) {
      // Log error but don't throw - this is background sync
      // print('Background sync failed for plan $planId: $e');
    }
  }
}
