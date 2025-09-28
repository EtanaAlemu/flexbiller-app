import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/dao/product_dao.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../models/product_model.dart';
import '../../../domain/entities/products_query_params.dart';

abstract class ProductsLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
  Future<ProductModel?> getCachedProductById(String productId);
  Future<List<ProductModel>> searchCachedProducts(String searchKey);
  Future<void> cacheProduct(ProductModel product);
  Future<void> updateCachedProduct(ProductModel product);
  Future<void> deleteCachedProduct(String productId);
  Future<void> clearAllCachedProducts();
  Future<bool> hasCachedProducts();
  Future<int> getCachedProductsCount();
  Future<List<ProductModel>> getCachedProductsByQuery(
    ProductsQueryParams params,
  );

  // Reactive stream methods for real-time updates
  Stream<List<ProductModel>> watchProducts();
  Stream<ProductModel?> watchProductById(String productId);
  Stream<List<ProductModel>> watchProductsByQuery(ProductsQueryParams params);
  Stream<List<ProductModel>> watchSearchResults(String searchKey);
}

@Injectable(as: ProductsLocalDataSource)
class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger = Logger();

  // Stream controllers for reactive updates
  final StreamController<List<ProductModel>> _productsStreamController =
      StreamController<List<ProductModel>>.broadcast();
  final StreamController<Map<String, ProductModel>>
  _productByIdStreamController =
      StreamController<Map<String, ProductModel>>.broadcast();
  final StreamController<Map<String, List<ProductModel>>>
  _queryStreamController =
      StreamController<Map<String, List<ProductModel>>>.broadcast();
  final StreamController<Map<String, List<ProductModel>>>
  _searchStreamController =
      StreamController<Map<String, List<ProductModel>>>.broadcast();

  ProductsLocalDataSourceImpl(this._databaseService, this._userSessionService);

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');

        // Try to restore user context from stored data
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();

          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping product caching',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }

      // If we have a user ID, proceed even if hasActiveUser is false
      // This handles the case where the user ID is restored but the full user object is not loaded
      _logger.d('Using restored user ID: $currentUserId');

      final db = await _databaseService.database;
      for (final product in products) {
        await ProductDao.insertOrUpdate(db, product, userId: currentUserId);
      }
      _logger.d(
        'Cached ${products.length} products successfully for user: $currentUserId',
      );

      // Emit to streams for reactive updates
      _emitProductsUpdate();
    } catch (e) {
      _logger.e('Error caching products: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, returning empty products list');
        return [];
      }

      final db = await _databaseService.database;
      return await ProductDao.getAll(
        db,
        orderBy: 'product_name ASC',
        userId: currentUserId,
      );
    } catch (e) {
      _logger.e('Error getting cached products: $e');

      // If table doesn't exist, return empty list instead of throwing
      if (e.toString().contains('no such table: products')) {
        _logger.w('Products table does not exist yet, returning empty list');
        return [];
      }

      rethrow;
    }
  }

  @override
  Future<ProductModel?> getCachedProductById(String productId) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning null for product: $productId',
            );
            return null;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return null;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      final product = await ProductDao.getById(db, productId);

      // Verify the product belongs to the current user
      if (product != null && product.userId != currentUserId) {
        _logger.w(
          'Product $productId does not belong to current user $currentUserId',
        );
        return null;
      }

      return product;
    } catch (e) {
      _logger.e('Error getting cached product by ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> searchCachedProducts(String searchKey) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning empty search results',
            );
            return [];
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return [];
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      return await ProductDao.search(db, searchKey, userId: currentUserId);
    } catch (e) {
      _logger.e('Error searching cached products: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping product caching: ${product.id}',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      await ProductDao.insertOrUpdate(db, product, userId: currentUserId);
      _logger.d(
        'Cached product successfully: ${product.id} for user: $currentUserId',
      );

      // Emit only individual product update, not products list update
      _emitProductUpdate(product);
    } catch (e) {
      _logger.e('Error caching product: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCachedProduct(ProductModel product) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping product update: ${product.id}',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      await ProductDao.insertOrUpdate(db, product, userId: currentUserId);
      _logger.d(
        'Updated cached product: ${product.id} for user: $currentUserId',
      );

      // Emit only individual product update, not products list update
      _emitProductUpdate(product);
    } catch (e) {
      _logger.e('Error updating cached product: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedProduct(String productId) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping product deletion: $productId',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;

      // Verify the product belongs to the current user before deleting
      final product = await ProductDao.getById(db, productId);
      if (product != null && product.userId != currentUserId) {
        _logger.w(
          'Cannot delete product $productId - does not belong to current user $currentUserId',
        );
        return;
      }

      await ProductDao.deleteById(db, productId);
      _logger.d('Deleted cached product: $productId for user: $currentUserId');

      // Emit only individual product deletion, not products list update
      _emitProductDeletion(productId);
    } catch (e) {
      _logger.e('Error deleting cached product: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedProducts() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, skipping clearing all products');
        return;
      }
      final db = await _databaseService.database;

      // Only clear products for the current user
      await db.delete(
        'products',
        where: 'user_id = ?',
        whereArgs: [currentUserId],
      );
      _logger.d('Cleared all cached products for user: $currentUserId');

      // Emit to streams for reactive updates
      _emitProductsUpdate();
    } catch (e) {
      _logger.e('Error clearing cached products: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedProducts() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w(
          'No active user context, returning false for hasCachedProducts',
        );
        return false;
      }
      final db = await _databaseService.database;
      return await ProductDao.hasProducts(db, userId: currentUserId);
    } catch (e) {
      _logger.e('Error checking if has cached products: $e');
      return false;
    }
  }

  @override
  Future<int> getCachedProductsCount() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, returning 0 for products count');
        return 0;
      }
      final db = await _databaseService.database;
      return await ProductDao.getCount(db, userId: currentUserId);
    } catch (e) {
      _logger.e('Error getting cached products count: $e');
      return 0;
    }
  }

  @override
  Future<List<ProductModel>> getCachedProductsByQuery(
    ProductsQueryParams params,
  ) async {
    try {
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');

        // Try to restore user context from stored data
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();

          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning empty products list',
            );
            return [];
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return [];
        }
      }

      // If we have a user ID, proceed even if hasActiveUser is false
      // This handles the case where the user ID is restored but the full user object is not loaded
      _logger.d('Using restored user ID: $currentUserId');

      _logger.d(
        '🔍 DEBUG: getCachedProductsByQuery called with params: ${params.toString()} for user: $currentUserId',
      );
      final db = await _databaseService.database;
      final dbSortBy = _mapSortFieldToDbColumn(params.sortBy);
      final orderBy = '$dbSortBy ${params.sortOrder}';
      _logger.d(
        '🔍 DEBUG: Query orderBy: $orderBy, limit: ${params.limit}, offset: ${params.offset}',
      );

      final result = await ProductDao.getByQuery(
        db,
        limit: params.limit,
        offset: params.offset,
        orderBy: orderBy,
        userId: currentUserId,
      );

      _logger.d(
        '🔍 DEBUG: ProductDao.getByQuery returned ${result.length} products for user: $currentUserId',
      );
      return result;
    } catch (e) {
      _logger.e('Error getting cached products by query: $e');

      // If table doesn't exist, return empty list instead of throwing
      if (e.toString().contains('no such table: products')) {
        _logger.w('Products table does not exist yet, returning empty list');
        return [];
      }

      rethrow;
    }
  }

  // Stream implementations for reactive updates
  @override
  Stream<List<ProductModel>> watchProducts() {
    return _productsStreamController.stream;
  }

  @override
  Stream<ProductModel?> watchProductById(String productId) {
    return _productByIdStreamController.stream
        .map((productMap) => productMap[productId])
        .distinct();
  }

  @override
  Stream<List<ProductModel>> watchProductsByQuery(ProductsQueryParams params) {
    final queryKey = _getQueryKey(params);
    return _queryStreamController.stream
        .map((queryMap) => queryMap[queryKey] ?? [])
        .distinct();
  }

  @override
  Stream<List<ProductModel>> watchSearchResults(String searchKey) {
    return _searchStreamController.stream
        .map((searchMap) => searchMap[searchKey] ?? [])
        .distinct();
  }

  // Helper methods for emitting updates
  Future<void> _emitProductsUpdate() async {
    try {
      final products = await getCachedProducts();
      _productsStreamController.add(products);
      _logger.d('Emitted products update: ${products.length} products');
    } catch (e) {
      _logger.e('Error emitting products update: $e');
    }
  }

  Future<void> _emitProductUpdate(ProductModel product) async {
    try {
      final productMap = {product.id: product};
      _productByIdStreamController.add(productMap);
      _logger.d('Emitted product update: ${product.id}');
    } catch (e) {
      _logger.e('Error emitting product update: $e');
    }
  }

  Future<void> _emitProductDeletion(String productId) async {
    try {
      final productMap = <String, ProductModel>{};
      _productByIdStreamController.add(productMap);
      _logger.d('Emitted product deletion: $productId');
    } catch (e) {
      _logger.e('Error emitting product deletion: $e');
    }
  }

  String _getQueryKey(ProductsQueryParams params) {
    return '${params.offset}_${params.limit}_${params.sortBy}_${params.sortOrder}';
  }

  // Helper method to map sort field names to database column names
  String _mapSortFieldToDbColumn(String sortField) {
    switch (sortField) {
      case 'productName':
        return ProductDao.columnProductName;
      case 'productDescription':
        return ProductDao.columnProductDescription;
      case 'createdAt':
        return ProductDao.columnCreatedAt;
      case 'updatedAt':
        return ProductDao.columnUpdatedAt;
      case 'tenantId':
        return ProductDao.columnTenantId;
      default:
        _logger.w('Unknown sort field: $sortField, defaulting to productName');
        return ProductDao.columnProductName;
    }
  }

  // Clean up stream controllers
  void dispose() {
    _productsStreamController.close();
    _productByIdStreamController.close();
    _queryStreamController.close();
    _searchStreamController.close();
  }
}
