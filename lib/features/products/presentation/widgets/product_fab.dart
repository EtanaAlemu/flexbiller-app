import 'package:flutter/material.dart';

class ProductFab extends StatelessWidget {
  const ProductFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _onCreateProduct(context),
      tooltip: 'Create Product',
      child: const Icon(Icons.add),
    );
  }

  void _onCreateProduct(BuildContext context) {
    // TODO: Navigate to create product page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create new product'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
