import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/bundle.dart';
import '../../domain/repositories/bundles_repository.dart';
import '../datasources/bundles_local_data_source.dart';
import '../datasources/bundles_remote_data_source.dart';

@LazySingleton(as: BundlesRepository)
class BundlesRepositoryImpl implements BundlesRepository {
  final BundlesRemoteDataSource _remoteDataSource;
  final BundlesLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  BundlesRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<List<Bundle>> getAllBundles() async {
    try {
      // Check if device is online
      if (await _networkInfo.isConnected) {
        try {
          // 1. Call Remote API
          final bundleModels = await _remoteDataSource.getAllBundles();
          final bundles = bundleModels
              .map((model) => model.toEntity())
              .toList();

          // 2. IMMEDIATELY Cache the received data Locally (Single Source of Truth)
          await _localDataSource.cacheBundles(bundles);

          // 3. Return the data from the local cache to ensure consistency
          final cachedBundles = await _localDataSource.getCachedBundles();
          return cachedBundles;
        } on ServerException catch (e) {
          // If server fails, try to return cached data
          final cachedBundles = await _localDataSource.getCachedBundles();
          if (cachedBundles.isNotEmpty) {
            return cachedBundles;
          }
          throw ServerFailure(e.message);
        }
      } else {
        // Handle offline case: return cached data
        final cachedBundles = await _localDataSource.getCachedBundles();
        if (cachedBundles.isNotEmpty) {
          return cachedBundles;
        }
        throw const NetworkFailure('No internet connection and no cached data');
      }
    } catch (e) {
      if (e is ServerFailure || e is NetworkFailure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<Bundle> getBundleById(String bundleId) async {
    try {
      // Check if device is online
      if (await _networkInfo.isConnected) {
        try {
          // 1. Call Remote API
          final bundleModel = await _remoteDataSource.getBundleById(bundleId);
          final bundle = bundleModel.toEntity();

          // 2. IMMEDIATELY Cache the received data Locally
          await _localDataSource.cacheBundle(bundle);

          // 3. Return the data from the local cache to ensure consistency
          final cachedBundle = await _localDataSource.getCachedBundleById(
            bundleId,
          );
          if (cachedBundle != null) {
            return cachedBundle;
          }
          return bundle;
        } on ServerException catch (e) {
          // If server fails, try to return cached data
          final cachedBundle = await _localDataSource.getCachedBundleById(
            bundleId,
          );
          if (cachedBundle != null) {
            return cachedBundle;
          }
          throw ServerFailure(e.message);
        }
      } else {
        // Handle offline case: return cached data
        final cachedBundle = await _localDataSource.getCachedBundleById(
          bundleId,
        );
        if (cachedBundle != null) {
          return cachedBundle;
        }
        throw const NetworkFailure('No internet connection and no cached data');
      }
    } catch (e) {
      if (e is ServerFailure || e is NetworkFailure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<Bundle>> getBundlesForAccount(String accountId) async {
    try {
      // Check if device is online
      if (await _networkInfo.isConnected) {
        try {
          // 1. Call Remote API
          final bundleModels = await _remoteDataSource.getBundlesForAccount(
            accountId,
          );
          final bundles = bundleModels
              .map((model) => model.toEntity())
              .toList();

          // 2. IMMEDIATELY Cache the received data Locally
          await _localDataSource.cacheBundles(bundles);

          // 3. Return the data from the local cache to ensure consistency
          final cachedBundles = await _localDataSource
              .getCachedBundlesForAccount(accountId);
          return cachedBundles;
        } on ServerException catch (e) {
          // If server fails, try to return cached data
          final cachedBundles = await _localDataSource
              .getCachedBundlesForAccount(accountId);
          if (cachedBundles.isNotEmpty) {
            return cachedBundles;
          }
          throw ServerFailure(e.message);
        }
      } else {
        // Handle offline case: return cached data
        final cachedBundles = await _localDataSource.getCachedBundlesForAccount(
          accountId,
        );
        if (cachedBundles.isNotEmpty) {
          return cachedBundles;
        }
        throw const NetworkFailure('No internet connection and no cached data');
      }
    } catch (e) {
      if (e is ServerFailure || e is NetworkFailure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<Bundle>> getCachedBundles() async {
    try {
      return await _localDataSource.getCachedBundles();
    } on CacheException {
      throw const CacheFailure('Failed to get cached bundles');
    }
  }

  @override
  Future<Bundle?> getCachedBundleById(String bundleId) async {
    try {
      return await _localDataSource.getCachedBundleById(bundleId);
    } on CacheException {
      throw const CacheFailure('Failed to get cached bundle');
    }
  }

  @override
  Future<void> cacheBundles(List<Bundle> bundles) async {
    try {
      await _localDataSource.cacheBundles(bundles);
    } on CacheException {
      throw const CacheFailure('Failed to cache bundles');
    }
  }

  @override
  Future<void> cacheBundle(Bundle bundle) async {
    try {
      await _localDataSource.cacheBundle(bundle);
    } on CacheException {
      throw const CacheFailure('Failed to cache bundle');
    }
  }

  @override
  Future<void> clearCachedBundles() async {
    try {
      await _localDataSource.clearCachedBundles();
    } on CacheException {
      throw const CacheFailure('Failed to clear cached bundles');
    }
  }
}
