import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/products_list_bloc.dart';
import '../bloc/events/products_list_events.dart';
import '../bloc/states/products_list_states.dart';

class EditProductPage extends StatelessWidget {
  final Product product;
  final VoidCallback? onProductUpdated;

  const EditProductPage({
    Key? key,
    required this.product,
    this.onProductUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditProductView(
      product: product,
      onProductUpdated: onProductUpdated,
    );
  }
}

class EditProductView extends StatefulWidget {
  final Product product;
  final VoidCallback? onProductUpdated;

  const EditProductView({
    Key? key,
    required this.product,
    this.onProductUpdated,
  }) : super(key: key);

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  // FocusNodes for keyboard navigation
  final _productNameFocusNode = FocusNode();
  final _productDescriptionFocusNode = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate form with existing product data
    _productNameController.text = widget.product.productName;
    _productDescriptionController.text = widget.product.productDescription;
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _scrollController.dispose();
    _productNameFocusNode.dispose();
    _productDescriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: BlocListener<ProductsListBloc, ProductsListState>(
        listener: (context, state) {
          if (state is ProductsListLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ProductsListError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is ProductUpdated) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onProductUpdated?.call();
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Edit Product',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update the product details below.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'ID: ${widget.product.id}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Product Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Information',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Product Name Field
                        TextFormField(
                          controller: _productNameController,
                          focusNode: _productNameFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Product Name *',
                            hintText: 'Enter product name',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            _productDescriptionFocusNode.requestFocus();
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Product name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Product name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Product Description Field
                        TextFormField(
                          controller: _productDescriptionController,
                          focusNode: _productDescriptionFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Product Description *',
                            hintText: 'Enter product description',
                            prefixIcon: Icon(Icons.description_outlined),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            _updateProduct();
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Product description is required';
                            }
                            if (value.trim().length < 5) {
                              return 'Product description must be at least 5 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProduct,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Update'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create an updated product with the form data
      final updatedProduct = widget.product.copyWith(
        productName: _productNameController.text.trim(),
        productDescription: _productDescriptionController.text.trim(),
        updatedAt: DateTime.now(),
        // Note: updatedBy should be set by the server based on current user
      );

      // Dispatch the update product event
      context.read<ProductsListBloc>().add(
        UpdateProduct(product: updatedProduct),
      );
    }
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
