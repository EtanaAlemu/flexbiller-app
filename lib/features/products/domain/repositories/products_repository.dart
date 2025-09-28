import 'dart:async';
import '../../../../core/models/repository_response.dart';
import '../entities/product.dart';
import '../entities/products_query_params.dart';

abstract class ProductsRepository {
  /// Get list of products with optional filtering and pagination
  Future<List<Product>> getProducts(ProductsQueryParams params);

  /// Get a single product by ID
  Future<Product> getProductById(String id);

  /// Search products by search key
  Future<List<Product>> searchProducts(String searchKey);

  /// Create a new product
  Future<Product> createProduct(Product product);

  /// Update an existing product
  Future<Product> updateProduct(Product product);

  /// Delete a product
  Future<void> deleteProduct(String productId);

  /// Get products by tenant ID
  Future<List<Product>> getProductsByTenant(String tenantId);

  /// Stream for reactive updates when products data changes
  Stream<RepositoryResponse<List<Product>>> get productsStream;

  /// Stream for reactive updates when individual product data changes
  Stream<RepositoryResponse<Product>> get productStream;
}
