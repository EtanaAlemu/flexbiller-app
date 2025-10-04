import 'package:flexbiller_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';
import '../bloc/products_list_bloc.dart';
import '../bloc/events/products_list_events.dart';
import '../bloc/states/products_list_states.dart';
import '../bloc/product_multiselect_bloc.dart';
import '../bloc/events/product_multiselect_events.dart';
import '../bloc/states/product_multiselect_states.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/product_fab.dart';
import '../widgets/product_empty_state.dart';
import '../widgets/product_error_state.dart';
import '../widgets/product_loading_state.dart';
import '../widgets/selectable_product_card_widget.dart';
import '../widgets/product_multi_select_action_bar.dart';
import 'product_detail_page.dart';
import 'edit_product_page.dart';

class ProductsPage extends StatefulWidget {
  final GlobalKey<ProductsViewState>? productsViewKey;

  const ProductsPage({super.key, this.productsViewKey});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class ProductsView extends StatefulWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  State<ProductsView> createState() => ProductsViewState();
}

class ProductsViewState extends State<ProductsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  bool _showSearchBar = false;

  // Multi-select state
  List<Product> _cachedProducts = [];
  List<Product> _selectedProducts = [];
  bool _isMultiSelectMode = false;

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
      _showSearchBar = false;
    });
    context.read<ProductsListBloc>().add(const GetAllProducts());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductMultiSelectBloc>(
          create: (context) => getIt<ProductMultiSelectBloc>(),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Search bar (conditionally shown)
              if (_showSearchBar)
                ProductSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: _onClearSearch,
                  isSearching: _isSearching,
                ),

              // Products list
              Expanded(
                child: BlocListener<ProductsListBloc, ProductsListState>(
                  listener: (context, state) {
                    if (state is ProductsListSuccess) {
                      // Cache products for multi-select
                      _cachedProducts = state.products;
                    } else if (state is ProductCreated) {
                      // Show success message
                      CustomSnackBar.showSuccess(
                        context,
                        message: 'Product created successfully!',
                      );
                      // Refresh the products list to show the new product
                      context.read<ProductsListBloc>().add(
                        const RefreshAllProducts(),
                      );
                    } else if (state is ProductDeleted) {
                      CustomSnackBar.showSuccess(
                        context,
                        message: 'Product deleted successfully!',
                      );
                    } else if (state is ProductsListError) {
                      CustomSnackBar.showError(
                        context,
                        message: 'Error: ${state.message}',
                      );
                    }
                  },
                  child: BlocListener<ProductMultiSelectBloc, ProductMultiSelectState>(
                    listener: (context, state) {
                      if (state is MultiSelectModeEnabled) {
                        setState(() {
                          _isMultiSelectMode = true;
                          _selectedProducts = state.selectedProducts;
                        });
                      } else if (state is MultiSelectModeDisabled) {
                        setState(() {
                          _isMultiSelectMode = false;
                          _selectedProducts = [];
                        });
                      } else if (state is ProductSelected) {
                        setState(() {
                          _selectedProducts = state.selectedProducts;
                        });
                      } else if (state is ProductDeselected) {
                        setState(() {
                          _selectedProducts = state.selectedProducts;
                        });
                      } else if (state is AllProductsSelected) {
                        setState(() {
                          _selectedProducts = state.selectedProducts;
                        });
                      } else if (state is AllProductsDeselected) {
                        setState(() {
                          _selectedProducts = [];
                        });
                      } else if (state is BulkDeleteInProgress) {
                        CustomSnackBar.showLoading(
                          context,
                          message:
                              'Deleting ${state.selectedProducts.length} products...',
                        );
                      } else if (state is BulkDeleteCompleted) {
                        CustomSnackBar.showSuccess(
                          context,
                          message:
                              '${state.deletedCount} products deleted successfully!',
                        );
                        // Disable multi-select mode after successful deletion
                        context.read<ProductMultiSelectBloc>().add(
                          const DisableMultiSelectMode(),
                        );
                        // Refresh the products list
                        context.read<ProductsListBloc>().add(
                          const RefreshAllProducts(),
                        );
                      } else if (state is BulkDeleteFailed) {
                        CustomSnackBar.showError(
                          context,
                          message: 'Delete failed: ${state.error}',
                        );
                      } else if (state is BulkExportInProgress) {
                        CustomSnackBar.showLoading(
                          context,
                          message:
                              'Exporting ${state.selectedProducts.length} products...',
                        );
                      } else if (state is BulkExportCompleted) {
                        CustomSnackBar.showSuccess(
                          context,
                          message: 'Products exported successfully!',
                        );
                        // Disable multi-select mode after successful export
                        context.read<ProductMultiSelectBloc>().add(
                          const DisableMultiSelectMode(),
                        );
                      } else if (state is BulkExportFailed) {
                        CustomSnackBar.showError(
                          context,
                          message: 'Export failed: ${state.error}',
                        );
                      }
                    },
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
                          if (_isMultiSelectMode) {
                            return _buildMultiSelectMode(
                              context,
                              _selectedProducts,
                            );
                          } else {
                            return RefreshIndicator(
                              onRefresh: () async => _onRefresh(),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount:
                                    state.products.length +
                                    (state.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= state.products.length) {
                                    // Loading indicator for pagination
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
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
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _isMultiSelectMode
            ? null
            : ProductFab(
                onCreateProduct: (Product product) async {
                  // Dispatch the create product event using the BLoC from ProductsPage context
                  context.read<ProductsListBloc>().add(
                    CreateProduct(product: product),
                  );
                },
              ),
      ),
    );
  }

  void _onProductTap(Product product) {
    if (_isMultiSelectMode) {
      // Toggle selection in multi-select mode
      final bloc = context.read<ProductMultiSelectBloc>();
      if (bloc.isProductSelected(product)) {
        bloc.add(DeselectProduct(product));
      } else {
        bloc.add(SelectProduct(product));
      }
    } else {
      // Navigate to product details page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(productId: product.id),
        ),
      );
    }
  }

  void _onEditProduct(Product product) {
    if (_isMultiSelectMode) {
      // In multi-select mode, just toggle selection
      _onProductTap(product);
    } else {
      // Navigate to edit product page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProductPage(
            product: product,
            onProductUpdated: () {
              // Refresh the products list after update
              context.read<ProductsListBloc>().add(const RefreshAllProducts());
            },
          ),
        ),
      );
    }
  }

  void _onDeleteProduct(product) {
    // Capture the BLoC reference before showing the dialog
    final bloc = context.read<ProductsListBloc>();

    // Show delete confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.productName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Dispatch delete product event using the captured BLoC reference
              bloc.add(DeleteProduct(productId: product.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Method to toggle search bar from outside (called by dashboard app bar)
  void toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _onClearSearch();
      }
    });
  }

  Widget _buildMultiSelectMode(
    BuildContext context,
    List<Product> selectedProducts,
  ) {
    // Use cached products instead of trying to get them from current state
    List<Product> allProducts = _cachedProducts;
    bool isAllSelected =
        selectedProducts.length == allProducts.length && allProducts.isNotEmpty;

    return Column(
      children: [
        // Multi-select action bar
        ProductMultiSelectActionBar(
          selectedProducts: selectedProducts,
          isAllSelected: isAllSelected,
          allProducts: allProducts,
        ),
        // Products list with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: allProducts.length,
              itemBuilder: (context, index) {
                final product = allProducts[index];
                final isSelected = selectedProducts.any(
                  (p) => p.id == product.id,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SelectableProductCardWidget(
                    product: product,
                    isSelected: isSelected,
                    isMultiSelectMode: true,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    return ProductsView(key: widget.productsViewKey);
  }
}
