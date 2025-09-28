import 'package:equatable/equatable.dart';

class ProductsQueryParams extends Equatable {
  final int limit;
  final int offset;
  final String sortBy;
  final String sortOrder;
  final String? searchQuery;
  final String? tenantId;

  const ProductsQueryParams({
    this.limit = 20,
    this.offset = 0,
    this.sortBy = 'productName',
    this.sortOrder = 'ASC',
    this.searchQuery,
    this.tenantId,
  });

  @override
  List<Object?> get props => [
    limit,
    offset,
    sortBy,
    sortOrder,
    searchQuery,
    tenantId,
  ];

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }

    if (tenantId != null && tenantId!.isNotEmpty) {
      params['tenantId'] = tenantId;
    }

    return params;
  }

  ProductsQueryParams copyWith({
    int? limit,
    int? offset,
    String? sortBy,
    String? sortOrder,
    String? searchQuery,
    String? tenantId,
  }) {
    return ProductsQueryParams(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  String toString() {
    return 'ProductsQueryParams{limit: $limit, offset: $offset, sortBy: $sortBy, sortOrder: $sortOrder, searchQuery: $searchQuery, tenantId: $tenantId}';
  }
}
