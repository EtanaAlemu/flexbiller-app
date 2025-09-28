import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductsListState extends Equatable {
  const ProductsListState();

  @override
  List<Object?> get props => [];
}

class ProductsListInitial extends ProductsListState {
  const ProductsListInitial();
}

class ProductsListLoading extends ProductsListState {
  const ProductsListLoading();
}

class ProductsListSuccess extends ProductsListState {
  final List<Product> products;
  final bool hasMore;
  final bool isRefreshing;

  const ProductsListSuccess({
    required this.products,
    this.hasMore = false,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [products, hasMore, isRefreshing];

  ProductsListSuccess copyWith({
    List<Product>? products,
    bool? hasMore,
    bool? isRefreshing,
  }) {
    return ProductsListSuccess(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class ProductsListError extends ProductsListState {
  final String message;
  final List<Product>? cachedProducts;

  const ProductsListError({required this.message, this.cachedProducts});

  @override
  List<Object?> get props => [message, cachedProducts];
}

class ProductsListEmpty extends ProductsListState {
  final String message;

  const ProductsListEmpty({this.message = 'No products found'});

  @override
  List<Object?> get props => [message];
}

class ProductDetailLoaded extends ProductsListState {
  final Product product;

  const ProductDetailLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductCreated extends ProductsListState {
  final Product product;

  const ProductCreated({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductUpdated extends ProductsListState {
  final Product product;

  const ProductUpdated({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends ProductsListState {
  final String productId;

  const ProductDeleted({required this.productId});

  @override
  List<Object?> get props => [productId];
}
