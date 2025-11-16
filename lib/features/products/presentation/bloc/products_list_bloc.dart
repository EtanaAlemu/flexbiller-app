import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/entities/products_query_params.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../bloc/events/products_list_events.dart';
import '../bloc/states/products_list_states.dart';

/// BLoC for handling product listing, searching, and filtering operations
@injectable
class ProductsListBloc extends Bloc<ProductsListEvent, ProductsListState>
    with BlocErrorHandlerMixin {
  final GetProductsUseCase _getProductsUseCase;
  final SearchProductsUseCase _searchProductsUseCase;
  final ProductsRepository _productsRepository;
  final Logger _logger = Logger();

  ProductsQueryParams _currentQueryParams = const ProductsQueryParams();
  StreamSubscription? _productsStreamSubscription;

  ProductsListBloc({
    required GetProductsUseCase getProductsUseCase,
    required SearchProductsUseCase searchProductsUseCase,
    required ProductsRepository productsRepository,
  }) : _getProductsUseCase = getProductsUseCase,
       _searchProductsUseCase = searchProductsUseCase,
       _productsRepository = productsRepository,
       super(const ProductsListInitial()) {
    // Register event handlers
    on<LoadProducts>(_onLoadProducts);
    on<GetAllProducts>(_onGetAllProducts);
    on<RefreshAllProducts>(_onRefreshAllProducts);
    on<SearchProducts>(_onSearchProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<FilterProductsByTenant>(_onFilterProductsByTenant);
    on<ClearFilters>(_onClearFilters);
    on<GetProductById>(_onGetProductById);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);

    // Initialize stream subscriptions for reactive updates
    _initializeStreamSubscriptions();
  }

  /// Initialize stream subscriptions for reactive updates from repository
  void _initializeStreamSubscriptions() {
    _productsStreamSubscription = _productsRepository.productsStream.listen(
      (response) {
        if (response.isSuccess) {
          add(LoadProducts(params: _currentQueryParams));
        } else if (response.hasError) {
          _logger.e('Error in products stream: ${response.errorMessage}');
          // Don't emit error state from stream subscription
          // Let the individual operations handle their own errors
        }
      },
      onError: (error) {
        _logger.e('Error in products stream: $error');
        // Don't emit error state from stream subscription
        // Let the individual operations handle their own errors
      },
    );
  }

  /// Load products with given parameters
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsListState> emit,
  ) async {
    try {
      _logger.d('Loading products with params: ${event.params}');
      _currentQueryParams = event.params;

      emit(const ProductsListLoading());

      final products = await _getProductsUseCase(event.params);

      if (products.isEmpty) {
        emit(const ProductsListEmpty());
      } else {
        emit(
          ProductsListSuccess(
            products: products,
            hasMore: _hasMoreProducts(products.length),
          ),
        );
      }
    } catch (e) {
      final message = handleException(
        e,
        context: 'products',
        metadata: {
          'action': 'load_products',
          'params': event.params.toString(),
        },
      );
      emit(ProductsListError(message: message));
    }
  }

  /// Get all products with default parameters
  Future<void> _onGetAllProducts(
    GetAllProducts event,
    Emitter<ProductsListState> emit,
  ) async {
    add(LoadProducts(params: const ProductsQueryParams()));
  }

  /// Refresh all products
  Future<void> _onRefreshAllProducts(
    RefreshAllProducts event,
    Emitter<ProductsListState> emit,
  ) async {
    add(LoadProducts(params: const ProductsQueryParams()));
  }

  /// Search products
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsListState> emit,
  ) async {
    try {
      _logger.d('Searching products with key: ${event.searchKey}');

      if (event.searchKey.isEmpty) {
        add(GetAllProducts());
        return;
      }

      emit(const ProductsListLoading());

      final products = await _searchProductsUseCase(event.searchKey);

      if (products.isEmpty) {
        emit(
          ProductsListEmpty(
            message: 'No products found for "${event.searchKey}"',
          ),
        );
      } else {
        emit(
          ProductsListSuccess(
            products: products,
            hasMore: false, // Search results typically don't have pagination
          ),
        );
      }
    } catch (e) {
      final message = handleException(
        e,
        context: 'search',
        metadata: {'action': 'search_products', 'searchKey': event.searchKey},
      );
      emit(ProductsListError(message: message));
    }
  }

  /// Refresh products with current parameters
  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductsListState> emit,
  ) async {
    try {
      _logger.d('Refreshing products with params: ${event.params}');
      _currentQueryParams = event.params;

      // Show refreshing state
      if (state is ProductsListSuccess) {
        emit((state as ProductsListSuccess).copyWith(isRefreshing: true));
      } else {
        emit(const ProductsListLoading());
      }

      final products = await _getProductsUseCase(event.params);

      if (products.isEmpty) {
        emit(const ProductsListEmpty());
      } else {
        emit(
          ProductsListSuccess(
            products: products,
            hasMore: _hasMoreProducts(products.length),
            isRefreshing: false,
          ),
        );
      }
    } catch (e) {
      final message = handleException(
        e,
        context: 'products',
        metadata: {
          'action': 'refresh_products',
          'params': event.params.toString(),
        },
      );
      emit(ProductsListError(message: message));
    }
  }

  /// Load more products (pagination)
  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductsListState> emit,
  ) async {
    try {
      if (state is! ProductsListSuccess) return;

      final currentState = state as ProductsListSuccess;
      if (!currentState.hasMore) return;

      _logger.d('Loading more products with params: ${event.params}');
      _currentQueryParams = event.params;

      final products = await _getProductsUseCase(event.params);

      if (products.isNotEmpty) {
        final updatedProducts = List<Product>.from(currentState.products)
          ..addAll(products);

        emit(
          ProductsListSuccess(
            products: updatedProducts,
            hasMore: _hasMoreProducts(products.length),
          ),
        );
      } else {
        emit(currentState.copyWith(hasMore: false));
      }
    } catch (e) {
      _logger.e('Error loading more products: $e');

      // For pagination errors, we don't want to show a full error state
      // Just log the error and keep the current state
      // The user can try again by scrolling
    }
  }

  /// Filter products by tenant
  Future<void> _onFilterProductsByTenant(
    FilterProductsByTenant event,
    Emitter<ProductsListState> emit,
  ) async {
    final params = _currentQueryParams.copyWith(tenantId: event.tenantId);
    add(LoadProducts(params: params));
  }

  /// Clear all filters
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ProductsListState> emit,
  ) async {
    add(GetAllProducts());
  }

  /// Check if there are more products to load
  bool _hasMoreProducts(int currentCount) {
    return currentCount >= _currentQueryParams.limit;
  }

  /// Get current query parameters
  ProductsQueryParams get currentQueryParams => _currentQueryParams;

  /// Handle GetProductById event
  Future<void> _onGetProductById(
    GetProductById event,
    Emitter<ProductsListState> emit,
  ) async {
    try {
      _logger.d('Getting product by ID: ${event.productId}');
      emit(const ProductsListLoading());

      final product = await _productsRepository.getProductById(event.productId);
      emit(ProductDetailLoaded(product: product));
    } catch (e) {
      final message = handleException(
        e,
        context: 'product',
        metadata: {'action': 'get_product_by_id', 'productId': event.productId},
      );
      emit(ProductsListError(message: message));
    }
  }

  /// Handle CreateProduct event
  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductsListState> emit,
  ) async {
    try {
      _logger.d('Creating product: ${event.product.productName}');
      emit(const ProductsListLoading());

      final createdProduct = await _productsRepository.createProduct(
        event.product,
      );
      emit(ProductCreated(product: createdProduct));
    } catch (e) {
      final message = handleException(
        e,
        context: 'product',
        metadata: {
          'action': 'create_product',
          'productName': event.product.productName,
        },
      );
      emit(ProductsListError(message: message));
    }
  }

  /// Handle UpdateProduct event
  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductsListState> emit,
  ) async {
    try {
      _logger.d('Updating product: ${event.product.productName}');
      emit(const ProductsListLoading());

      final updatedProduct = await _productsRepository.updateProduct(
        event.product,
      );
      emit(ProductUpdated(product: updatedProduct));
    } catch (e) {
      final message = handleException(
        e,
        context: 'product',
        metadata: {'action': 'update_product', 'productId': event.product.id},
      );
      emit(ProductsListError(message: message));
    }
  }

  /// Handle DeleteProduct event
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductsListState> emit,
  ) async {
    try {
      _logger.d('Deleting product: ${event.productId}');
      emit(const ProductsListLoading());

      await _productsRepository.deleteProduct(event.productId);
      emit(ProductDeleted(productId: event.productId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'delete',
        metadata: {'action': 'delete_product', 'productId': event.productId},
      );
      emit(ProductsListError(message: message));
    }
  }

  @override
  Future<void> close() {
    _productsStreamSubscription?.cancel();
    return super.close();
  }
}
