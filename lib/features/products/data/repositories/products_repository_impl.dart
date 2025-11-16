import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/models/repository_response.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/products_query_params.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/local/products_local_data_source.dart';
import '../datasources/remote/products_remote_data_source.dart';
import '../models/product_model.dart';

@LazySingleton(as: ProductsRepository)
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;
  final ProductsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final SyncService _syncService;
  final Logger _logger = Logger();

  // Stream controllers for reactive UI updates
  final StreamController<RepositoryResponse<List<Product>>>
  _productsStreamController =
      StreamController<RepositoryResponse<List<Product>>>.broadcast();
  final StreamController<RepositoryResponse<Product>> _productStreamController =
      StreamController<RepositoryResponse<Product>>.broadcast();

  // Stream subscriptions for local data changes
  StreamSubscription<List<ProductModel>>? _localProductsSubscription;
  StreamSubscription<ProductModel?>? _localProductSubscription;

  // Track products currently being synced to prevent duplicate syncs
  // final Map<String, Completer<void>> _syncingProducts =
  //     <String, Completer<void>>{};

  // Track last sync time to prevent rapid successive syncs
  final Map<String, DateTime> _lastSyncTime = <String, DateTime>{};

  // Track if we're currently processing a product to prevent loops
  final Set<String> _processingProducts = <String>{};

  // Track if we're currently syncing products list to prevent loops
  bool _isSyncingProductsList = false;
  DateTime? _lastProductsListSyncTime;

  ProductsRepositoryImpl({
    required ProductsRemoteDataSource remoteDataSource,
    required ProductsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required SyncService syncService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _syncService = syncService {
    _initializeStreamSubscriptions();
  }

  /// Initialize stream subscriptions for reactive updates from local data source
  void _initializeStreamSubscriptions() {
    // Listen to local products changes and emit to repository streams
    _localProductsSubscription = _localDataSource.watchProducts().listen(
      (products) {
        final productEntities = products
            .map((model) => model.toEntity())
            .toList();
        _productsStreamController.add(
          RepositoryResponse.success(productEntities),
        );
      },
      onError: (error) {
        _logger.e('Error in products stream: $error');
        _productsStreamController.add(
          RepositoryResponse.error(message: 'Failed to load products: $error'),
        );
      },
    );

    // Listen to individual product changes
    _localProductSubscription = _localDataSource
        .watchProductById('')
        .listen(
          (product) {
            if (product != null) {
              _productStreamController.add(
                RepositoryResponse.success(product.toEntity()),
              );
            }
          },
          onError: (error) {
            _logger.e('Error in product stream: $error');
            _productStreamController.add(
              RepositoryResponse.error(
                message: 'Failed to load product: $error',
              ),
            );
          },
        );
  }

  @override
  Future<List<Product>> getProducts(ProductsQueryParams params) async {
    try {
      _logger.d('Getting products with params: $params');

      // First, try to get from local cache
      final cachedProducts = await _localDataSource.getCachedProductsByQuery(
        params,
      );

      if (cachedProducts.isNotEmpty) {
        _logger.d('Returning ${cachedProducts.length} cached products');

        // Trigger background sync if online
        if (await _networkInfo.isConnected) {
          _syncProductsInBackground(params);
        }

        return cachedProducts.map((model) => model.toEntity()).toList();
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d('No cached products, fetching from remote');
        return await _fetchProductsFromRemote(params);
      } else {
        _logger.w('No cached products and offline, returning empty list');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting products: $e');
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      _logger.d('Getting product by ID: $id');

      // First, try to get from local cache
      final cachedProduct = await _localDataSource.getCachedProductById(id);

      if (cachedProduct != null) {
        _logger.d('Returning cached product: ${cachedProduct.id}');

        // Trigger background sync if online
        if (await _networkInfo.isConnected) {
          _syncProductInBackground(id);
        }

        return cachedProduct.toEntity();
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d('No cached product, fetching from remote');
        return await _fetchProductFromRemote(id);
      } else {
        throw CacheException('Product not found in cache and offline');
      }
    } catch (e) {
      _logger.e('Error getting product by ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(String searchKey) async {
    try {
      _logger.d('Searching products with key: $searchKey');

      // First, try to search in local cache
      final cachedResults = await _localDataSource.searchCachedProducts(
        searchKey,
      );

      if (cachedResults.isNotEmpty) {
        _logger.d('Returning ${cachedResults.length} cached search results');
        return cachedResults.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, search remote
      if (await _networkInfo.isConnected) {
        _logger.d('No cached search results, searching remote');
        return await _searchProductsFromRemote(searchKey);
      } else {
        _logger.w('No cached search results and offline, returning empty list');
        return [];
      }
    } catch (e) {
      _logger.e('Error searching products: $e');
      rethrow;
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      _logger.d('Creating product: ${product.productName}');

      // Convert to model
      final productModel = ProductModel.fromEntity(product);

      // If online, create on remote first
      if (await _networkInfo.isConnected) {
        try {
          final createdProduct = await _remoteDataSource.createProduct(
            productModel,
          );
          _logger.d('Product created on remote: ${createdProduct.id}');

          // Cache the created product locally
          await _localDataSource.cacheProduct(createdProduct);

          return createdProduct.toEntity();
        } catch (e) {
          _logger.e('Failed to create product on remote: $e');
          // If remote creation fails, still cache locally for offline sync
          await _localDataSource.cacheProduct(productModel);
          throw e;
        }
      } else {
        // Offline: cache locally for later sync
        _logger.d('Offline: caching product locally for sync');
        await _localDataSource.cacheProduct(productModel);

        // Register for sync
        _syncService.queueOperation(() async {
          try {
            _logger.d('🔄 Syncing product creation: ${product.id}');

            // Get the cached product model
            final cachedProduct = await _localDataSource.getCachedProductById(
              product.id,
            );
            if (cachedProduct == null) {
              _logger.w(
                'Product ${product.id} not found in local cache for sync',
              );
              return;
            }

            // Create product on remote
            final createdProduct = await _remoteDataSource.createProduct(
              cachedProduct,
            );
            _logger.d('✅ Product created on remote: ${createdProduct.id}');

            // Update local cache with the server response
            await _localDataSource.updateCachedProduct(createdProduct);
            _logger.d('✅ Product sync completed: ${createdProduct.id}');
          } catch (e) {
            _logger.e('❌ Failed to sync product creation ${product.id}: $e');
            rethrow;
          }
        });

        return product;
      }
    } catch (e) {
      _logger.e('Error creating product: $e');
      rethrow;
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      _logger.d('Updating product: ${product.id}');

      // Convert to model
      final productModel = ProductModel.fromEntity(product);

      // If online, update on remote first
      if (await _networkInfo.isConnected) {
        try {
          final updatedProduct = await _remoteDataSource.updateProduct(
            productModel,
          );
          _logger.d('Product updated on remote: ${updatedProduct.id}');

          // Update local cache
          await _localDataSource.updateCachedProduct(updatedProduct);

          return updatedProduct.toEntity();
        } catch (e) {
          _logger.e('Failed to update product on remote: $e');
          // If remote update fails, still update locally for offline sync
          await _localDataSource.updateCachedProduct(productModel);
          throw e;
        }
      } else {
        // Offline: update locally for later sync
        _logger.d('Offline: updating product locally for sync');
        await _localDataSource.updateCachedProduct(productModel);

        // Register for sync
        _syncService.queueOperation(() async {
          try {
            _logger.d('🔄 Syncing product update: ${product.id}');

            // Get the cached product model
            final cachedProduct = await _localDataSource.getCachedProductById(
              product.id,
            );
            if (cachedProduct == null) {
              _logger.w(
                'Product ${product.id} not found in local cache for sync',
              );
              return;
            }

            // Update product on remote
            final updatedProduct = await _remoteDataSource.updateProduct(
              cachedProduct,
            );
            _logger.d('✅ Product updated on remote: ${updatedProduct.id}');

            // Update local cache with the server response
            await _localDataSource.updateCachedProduct(updatedProduct);
            _logger.d('✅ Product sync completed: ${updatedProduct.id}');
          } catch (e) {
            _logger.e('❌ Failed to sync product update ${product.id}: $e');
            rethrow;
          }
        });

        return product;
      }
    } catch (e) {
      _logger.e('Error updating product: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      _logger.d('Deleting product: $productId');

      // If online, delete on remote first
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteProduct(productId);
          _logger.d('Product deleted on remote: $productId');

          // Delete from local cache
          await _localDataSource.deleteCachedProduct(productId);
        } catch (e) {
          _logger.e('Failed to delete product on remote: $e');
          // If remote deletion fails, still delete locally
          await _localDataSource.deleteCachedProduct(productId);
          throw e;
        }
      } else {
        // Offline: delete locally
        _logger.d('Offline: deleting product locally');
        await _localDataSource.deleteCachedProduct(productId);

        // Register for sync
        _syncService.queueOperation(() async {
          try {
            _logger.d('🔄 Syncing product deletion: $productId');

            // Delete product on remote
            await _remoteDataSource.deleteProduct(productId);
            _logger.d('✅ Product deleted on remote: $productId');

            // Product is already deleted from local cache, so we're done
            _logger.d('✅ Product deletion sync completed: $productId');
          } catch (e) {
            _logger.e('❌ Failed to sync product deletion $productId: $e');
            // If sync fails, the product will remain in local cache
            // It will be retried later by the sync service
            rethrow;
          }
        });
      }

      // Refresh the products list after deletion
      await _refreshProductsList();
    } catch (e) {
      _logger.e('Error deleting product: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByTenant(String tenantId) async {
    try {
      _logger.d('Getting products by tenant: $tenantId');

      // First, try to get from local cache
      final db = await _localDataSource.getCachedProducts();
      final tenantProducts = db
          .where((product) => product.tenantId == tenantId)
          .toList();

      if (tenantProducts.isNotEmpty) {
        _logger.d('Returning ${tenantProducts.length} cached tenant products');
        return tenantProducts.map((model) => model.toEntity()).toList();
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d('No cached tenant products, fetching from remote');
        final params = ProductsQueryParams(tenantId: tenantId);
        return await _fetchProductsFromRemote(params);
      } else {
        _logger.w(
          'No cached tenant products and offline, returning empty list',
        );
        return [];
      }
    } catch (e) {
      _logger.e('Error getting products by tenant: $e');
      rethrow;
    }
  }

  @override
  Stream<RepositoryResponse<List<Product>>> get productsStream =>
      _productsStreamController.stream;

  @override
  Stream<RepositoryResponse<Product>> get productStream =>
      _productStreamController.stream;

  // Private helper methods for remote operations
  Future<List<Product>> _fetchProductsFromRemote(
    ProductsQueryParams params,
  ) async {
    try {
      final products = await _remoteDataSource.getProducts(params);
      await _localDataSource.cacheProducts(products);
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      _logger.e('Error fetching products from remote: $e');
      rethrow;
    }
  }

  Future<Product> _fetchProductFromRemote(String id) async {
    try {
      final product = await _remoteDataSource.getProductById(id);
      await _localDataSource.cacheProduct(product);
      return product.toEntity();
    } catch (e) {
      _logger.e('Error fetching product from remote: $e');
      rethrow;
    }
  }

  Future<List<Product>> _searchProductsFromRemote(String searchKey) async {
    try {
      final products = await _remoteDataSource.searchProducts(searchKey);
      await _localDataSource.cacheProducts(products);
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      _logger.e('Error searching products from remote: $e');
      rethrow;
    }
  }

  // Background sync methods
  Future<void> _syncProductsInBackground(ProductsQueryParams params) async {
    if (_isSyncingProductsList) return;

    final now = DateTime.now();
    if (_lastProductsListSyncTime != null &&
        now.difference(_lastProductsListSyncTime!).inSeconds < 30) {
      return; // Prevent too frequent syncs
    }

    _isSyncingProductsList = true;
    _lastProductsListSyncTime = now;

    try {
      final products = await _remoteDataSource.getProducts(params);
      await _localDataSource.cacheProducts(products);
      _logger.d('Background sync completed for products list');
    } catch (e) {
      _logger.e('Background sync failed for products list: $e');
    } finally {
      _isSyncingProductsList = false;
    }
  }

  Future<void> _syncProductInBackground(String productId) async {
    if (_processingProducts.contains(productId)) return;

    final now = DateTime.now();
    if (_lastSyncTime[productId] != null &&
        now.difference(_lastSyncTime[productId]!).inSeconds < 30) {
      return; // Prevent too frequent syncs
    }

    _processingProducts.add(productId);
    _lastSyncTime[productId] = now;

    try {
      final product = await _remoteDataSource.getProductById(productId);
      await _localDataSource.cacheProduct(product);
      _logger.d('Background sync completed for product: $productId');
    } catch (e) {
      _logger.e('Background sync failed for product $productId: $e');
    } finally {
      _processingProducts.remove(productId);
    }
  }

  /// Refresh the products list and emit to stream
  Future<void> _refreshProductsList() async {
    try {
      _logger.d('Refreshing products list after deletion');

      // Get current query parameters (use default if none)
      final params = ProductsQueryParams();

      // Get updated products from local cache
      final products = await _localDataSource.getCachedProductsByQuery(params);

      // Emit the updated products list to the stream
      _productsStreamController.add(
        RepositoryResponse.success(
          products.map((model) => model.toEntity()).toList(),
        ),
      );

      _logger.d('Products list refreshed with ${products.length} products');
    } catch (e) {
      _logger.e('Error refreshing products list: $e');
      // Emit error state
      _productsStreamController.add(
        RepositoryResponse.error(
          message: 'Failed to refresh products list: $e',
        ),
      );
    }
  }

  void dispose() {
    _logger.d('🛑 [Products Repository] Disposing resources...');
    _localProductsSubscription?.cancel();
    _localProductsSubscription = null;
    _localProductSubscription?.cancel();
    _localProductSubscription = null;
    if (!_productsStreamController.isClosed) {
      _productsStreamController.close();
    }
    if (!_productStreamController.isClosed) {
      _productStreamController.close();
    }
    _lastSyncTime.clear();
    _processingProducts.clear();
    _logger.i('✅ [Products Repository] All resources disposed');
  }
}
