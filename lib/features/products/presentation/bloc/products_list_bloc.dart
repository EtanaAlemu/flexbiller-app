import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/products_query_params.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../bloc/events/products_list_events.dart';
import '../bloc/states/products_list_states.dart';

/// BLoC for handling product listing, searching, and filtering operations
@injectable
class ProductsListBloc extends Bloc<ProductsListEvent, ProductsListState> {
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

    // Initialize stream subscriptions for reactive updates
    _initializeStreamSubscriptions();
  }

  /// Initialize stream subscriptions for reactive updates from repository
  void _initializeStreamSubscriptions() {
    _productsStreamSubscription = _productsRepository.productsStream.listen(
      (response) {
        if (response.isSuccess) {
          emit(
            ProductsListSuccess(
              products: response.data ?? [],
              hasMore: _hasMoreProducts(response.data?.length ?? 0),
            ),
          );
        } else if (response.hasError) {
          emit(
            ProductsListError(
              message: response.errorMessage,
              cachedProducts: state is ProductsListSuccess
                  ? (state as ProductsListSuccess).products
                  : null,
            ),
          );
        }
      },
      onError: (error) {
        _logger.e('Error in products stream: $error');
        emit(
          ProductsListError(
            message: 'Failed to load products: $error',
            cachedProducts: state is ProductsListSuccess
                ? (state as ProductsListSuccess).products
                : null,
          ),
        );
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
      _logger.e('Error loading products: $e');
      emit(ProductsListError(message: 'Failed to load products: $e'));
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
      _logger.e('Error searching products: $e');
      emit(ProductsListError(message: 'Failed to search products: $e'));
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
      _logger.e('Error refreshing products: $e');
      emit(ProductsListError(message: 'Failed to refresh products: $e'));
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
      emit(ProductsListError(message: 'Failed to load more products: $e'));
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

  @override
  Future<void> close() {
    _productsStreamSubscription?.cancel();
    return super.close();
  }
}
