import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/product_model.dart';
import '../../../domain/entities/products_query_params.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts(ProductsQueryParams params);
  Future<ProductModel> getProductById(String productId);
  Future<List<ProductModel>> searchProducts(String searchKey);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

@Injectable(as: ProductsRemoteDataSource)
class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final DioClient _dioClient;

  ProductsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts(ProductsQueryParams params) async {
    try {
      final response = await _dioClient.dio.get(
        '/products',
        queryParameters: params.toQueryParameters(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> productsData =
              responseData['data'] as List<dynamic>;
          return productsData
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch products',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch products: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to products');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access products',
        );
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate server issues
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Resource not found');
            }
          }
        }
        throw ServerException('Server error while fetching products');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    try {
      final response = await _dioClient.dio.get('/products/$productId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          return ProductModel.fromJson(data);
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to fetch product',
          );
        }
      } else {
        throw ServerException(
          'Failed to fetch product: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to product');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access product',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Product not found');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate product doesn't exist
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Product not found');
            }
          }
        }
        throw ServerException('Server error while fetching product');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String searchKey) async {
    try {
      final response = await _dioClient.dio.get('/products/search/$searchKey');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> productsData =
              responseData['data'] as List<dynamic>;
          return productsData
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to search products',
          );
        }
      } else {
        throw ServerException(
          'Failed to search products: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized access to products');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to access products',
        );
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate server issues
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Resource not found');
            }
          }
        }
        throw ServerException('Server error while searching products');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _dioClient.dio.post(
        '/products',
        data: product.toJsonForApi(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          return ProductModel.fromJson(data);
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to create product',
          );
        }
      } else {
        throw ServerException(
          'Failed to create product: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid product data');
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to create product');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to create product',
        );
      } else if (e.response?.statusCode == 409) {
        throw ValidationException('Product already exists');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate server issues
        final responseData = e.response?.data;
        if (responseData != null) {
          // Check for CONNECTION_ERROR with meaningful original error
          if (responseData['error'] == 'CONNECTION_ERROR') {
            final details = responseData['details'];
            if (details != null && details['originalError'] != null) {
              final originalError = details['originalError'] as String;
              if (originalError.contains("Product already exists")) {
                throw ValidationException(
                  'Product already exists. Please use a different name.',
                );
              } else if (originalError.contains("doesn't exist")) {
                throw ValidationException('Resource not found');
              } else {
                throw ServerException('Server error: $originalError');
              }
            }
          }

          // Check for direct error message in response
          if (responseData['message'] != null) {
            final message = responseData['message'] as String;
            if (message.contains("Product already exists")) {
              throw ValidationException(
                'Product already exists. Please use a different name.',
              );
            } else {
              throw ServerException('Server error: $message');
            }
          }
        }
        throw ServerException('Server error while creating product');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await _dioClient.dio.put(
        '/products/${product.id}',
        data: product.toJsonForApi(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          return ProductModel.fromJson(data);
        } else {
          throw ServerException(
            responseData['message'] ?? 'Failed to update product',
          );
        }
      } else {
        throw ServerException(
          'Failed to update product: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid product data');
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to update product');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to update product',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Product not found');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate server issues
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Product not found');
            }
          }
        }
        throw ServerException('Server error while updating product');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      final response = await _dioClient.dio.delete('/products/$productId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // For successful deletion, the API returns the deleted product data
        // We can optionally log or process this data, but deletion is successful
        if (responseData['message'] != null &&
            responseData['message'].toString().toLowerCase().contains(
              'deleted successfully',
            )) {
          // Product was deleted successfully
          return;
        } else {
          // Unexpected response format but status is 200
          return;
        }
      } else {
        throw ServerException(
          'Failed to delete product: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid product data for deletion');
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Unauthorized to delete product');
      } else if (e.response?.statusCode == 403) {
        throw AuthException(
          'Forbidden: Insufficient permissions to delete product',
        );
      } else if (e.response?.statusCode == 404) {
        throw ValidationException('Product not found');
      } else if (e.response?.statusCode == 500) {
        // Handle 500 error which might indicate tenant issues or server problems
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData['error'] == 'CONNECTION_ERROR') {
          final details = responseData['details'];
          if (details != null && details['originalError'] != null) {
            final originalError = details['originalError'] as String;
            if (originalError.contains("doesn't exist")) {
              throw ValidationException('Product not found');
            } else if (originalError.contains("doesn't belong to tenant")) {
              throw ValidationException(
                'Product does not belong to your tenant',
              );
            }
          }
        }
        throw ServerException('Server error while deleting product');
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
