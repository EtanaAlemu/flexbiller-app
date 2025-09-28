import 'package:equatable/equatable.dart';
import '../../../domain/entities/products_query_params.dart';

abstract class ProductsListEvent extends Equatable {
  const ProductsListEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsListEvent {
  final ProductsQueryParams params;

  const LoadProducts({required this.params});

  @override
  List<Object?> get props => [params];
}

class GetAllProducts extends ProductsListEvent {
  const GetAllProducts();
}

class RefreshAllProducts extends ProductsListEvent {
  const RefreshAllProducts();
}

class SearchProducts extends ProductsListEvent {
  final String searchKey;

  const SearchProducts({required this.searchKey});

  @override
  List<Object?> get props => [searchKey];
}

class RefreshProducts extends ProductsListEvent {
  final ProductsQueryParams params;

  const RefreshProducts({required this.params});

  @override
  List<Object?> get props => [params];
}

class LoadMoreProducts extends ProductsListEvent {
  final ProductsQueryParams params;

  const LoadMoreProducts({required this.params});

  @override
  List<Object?> get props => [params];
}

class FilterProductsByTenant extends ProductsListEvent {
  final String tenantId;

  const FilterProductsByTenant({required this.tenantId});

  @override
  List<Object?> get props => [tenantId];
}

class ClearFilters extends ProductsListEvent {
  const ClearFilters();
}
