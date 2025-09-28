import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/product.dart';
import '../bloc/products_list_bloc.dart';
import '../bloc/events/products_list_events.dart';
import '../bloc/states/products_list_states.dart';
import 'edit_product_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({Key? key, required this.productId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsListBloc>(
      create: (context) => getIt<ProductsListBloc>(),
      child: Builder(
        builder: (context) => ProductDetailView(
          productId: productId,
          productsListBloc: context.read<ProductsListBloc>(),
        ),
      ),
    );
  }
}

class ProductDetailView extends StatefulWidget {
  final String productId;
  final ProductsListBloc productsListBloc;

  const ProductDetailView({
    Key? key,
    required this.productId,
    required this.productsListBloc,
  }) : super(key: key);

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  @override
  void initState() {
    super.initState();
    // Load product details after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.productsListBloc.add(GetProductById(productId: widget.productId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsListBloc, ProductsListState>(
      bloc: widget.productsListBloc,
      builder: (context, state) {
        Product? product;
        if (state is ProductDetailLoaded) {
          product = state.product;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
            actions: [
              if (product != null) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _onEditProduct(context, product!),
                  tooltip: 'Edit Product',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _onDeleteProduct(context, product!),
                  tooltip: 'Delete Product',
                ),
              ],
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductsListState state) {
    if (state is ProductsListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProductsListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading product',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.productsListBloc.add(
                  GetProductById(productId: widget.productId),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (state is ProductDetailLoaded) {
      final product = state.product;
      return _buildProductDetails(context, product);
    }

    return const Center(child: Text('No product data available'));
  }

  Widget _buildProductDetails(BuildContext context, Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Product ID: ${product.id}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.productDescription,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Product Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, 'Product Name', product.productName),
                  _buildInfoRow(
                    context,
                    'Description',
                    product.productDescription,
                  ),
                  _buildInfoRow(context, 'Tenant ID', product.tenantId),
                  _buildInfoRow(context, 'Created By', product.createdBy),
                  _buildInfoRow(context, 'Updated By', product.updatedBy),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timestamps Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timestamps',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    'Created At',
                    _formatDateTime(product.createdAt),
                  ),
                  _buildInfoRow(
                    context,
                    'Updated At',
                    _formatDateTime(product.updatedAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _onEditProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<ProductsListBloc>(
          create: (context) => getIt<ProductsListBloc>(),
          child: EditProductPage(
            product: product,
            onProductUpdated: () {
              // Refresh the product detail after update
              widget.productsListBloc.add(
                GetProductById(productId: product.id),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onDeleteProduct(BuildContext context, Product product) {
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
              // Dispatch delete product event using the passed BLoC reference
              widget.productsListBloc.add(DeleteProduct(productId: product.id));
              // Navigate back to products list after deletion
              Navigator.of(context).pop();
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
