import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';

class CreateProductPage extends StatelessWidget {
  final Function(Product)? onCreateProduct;

  const CreateProductPage({Key? key, this.onCreateProduct}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CreateProductView(onCreateProduct: onCreateProduct);
  }
}

class CreateProductView extends StatefulWidget {
  final Function(Product)? onCreateProduct;

  const CreateProductView({Key? key, this.onCreateProduct}) : super(key: key);

  @override
  State<CreateProductView> createState() => _CreateProductViewState();
}

class _CreateProductViewState extends State<CreateProductView> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  // FocusNodes for keyboard navigation
  final _productNameFocusNode = FocusNode();
  final _productDescriptionFocusNode = FocusNode();

  bool _isLoading = false;

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
      appBar: AppBar(title: const Text('Create Product')),
      body: SingleChildScrollView(
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
                            Icons.add_circle_outline,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Create New Product',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the details below to create a new product.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                          _saveProduct();
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
                      onPressed: _isLoading ? null : _saveProduct,
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
                          : const Text('Create Product'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a new product with the form data
        final product = Product(
          id: '', // Will be generated by the server
          productName: _productNameController.text.trim(),
          productDescription: _productDescriptionController.text.trim(),
          tenantId: '', // Will be set by the server based on current user
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: '', // Will be set by the server based on current user
          updatedBy: '', // Will be set by the server based on current user
        );

        // Call the create product callback if provided
        if (widget.onCreateProduct != null) {
          await widget.onCreateProduct!(product);

          // Navigate back - success message will be shown by the BlocListener
          Navigator.of(context).pop();
        } else {
          // Fallback: show error if no callback provided
          throw Exception('No create product callback provided');
        }
      } catch (e) {
        // Show error message
        CustomSnackBar.showError(
          context,
          message: 'Error creating product: $e',
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
