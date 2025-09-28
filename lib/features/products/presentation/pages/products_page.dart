import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_list_bloc.dart';
import '../bloc/events/products_list_events.dart';
import '../bloc/states/products_list_states.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/product_fab.dart';
import '../widgets/product_empty_state.dart';
import '../widgets/product_error_state.dart';
import '../widgets/product_loading_state.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load products when page initializes
    context.read<ProductsListBloc>().add(const GetAllProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more products when scrolled to 80% of the list
      final bloc = context.read<ProductsListBloc>();
      if (bloc.state is ProductsListSuccess) {
        final state = bloc.state as ProductsListSuccess;
        if (state.hasMore && !state.isRefreshing) {
          final params = bloc.currentQueryParams.copyWith(
            offset: state.products.length,
          );
          bloc.add(LoadMoreProducts(params: params));
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      context.read<ProductsListBloc>().add(const GetAllProducts());
    } else {
      setState(() {
        _isSearching = true;
      });
      context.read<ProductsListBloc>().add(SearchProducts(searchKey: query));
    }
  }

  void _onRefresh() {
    if (_isSearching) {
      context.read<ProductsListBloc>().add(
        SearchProducts(searchKey: _searchController.text),
      );
    } else {
      context.read<ProductsListBloc>().add(const RefreshAllProducts());
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    context.read<ProductsListBloc>().add(const GetAllProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          ProductSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _onClearSearch,
            isSearching: _isSearching,
          ),

          // Products list
          Expanded(
            child: BlocBuilder<ProductsListBloc, ProductsListState>(
              builder: (context, state) {
                if (state is ProductsListLoading) {
                  return const ProductLoadingState();
                } else if (state is ProductsListError) {
                  return ProductErrorState(
                    message: state.message,
                    onRetry: _onRefresh,
                    cachedProducts: state.cachedProducts,
                  );
                } else if (state is ProductsListEmpty) {
                  return ProductEmptyState(
                    message: state.message,
                    onRefresh: _onRefresh,
                    isSearching: _isSearching,
                    onClearSearch: _onClearSearch,
                  );
                } else if (state is ProductsListSuccess) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          state.products.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.products.length) {
                          // Loading indicator for pagination
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final product = state.products[index];
                        return ProductListItem(
                          product: product,
                          onTap: () => _onProductTap(product),
                          onEdit: () => _onEditProduct(product),
                          onDelete: () => _onDeleteProduct(product),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const ProductFab(),
    );
  }

  void _onProductTap(product) {
    // Navigate to product details page
    // TODO: Implement product details navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product details: ${product.productName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onEditProduct(product) {
    // Navigate to edit product page
    // TODO: Implement edit product navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit product: ${product.productName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onDeleteProduct(product) {
    // Show delete confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.productName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete product
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Delete product: ${product.productName}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
