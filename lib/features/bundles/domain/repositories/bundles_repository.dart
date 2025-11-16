import '../entities/bundle.dart';

abstract class BundlesRepository {
  /// Get all bundles for the current account
  Future<List<Bundle>> getAllBundles();

  /// Get a specific bundle by ID
  Future<Bundle> getBundleById(String bundleId);

  /// Get bundles for a specific account
  Future<List<Bundle>> getBundlesForAccount(String accountId);

  /// Get cached bundles from local storage
  Future<List<Bundle>> getCachedBundles();

  /// Get cached bundle by ID from local storage
  Future<Bundle?> getCachedBundleById(String bundleId);

  /// Cache bundles locally
  Future<void> cacheBundles(List<Bundle> bundles);

  /// Cache a single bundle locally
  Future<void> cacheBundle(Bundle bundle);

  /// Clear all cached bundles
  Future<void> clearCachedBundles();

  /// Delete a bundle
  Future<void> deleteBundle(String bundleId);
}
