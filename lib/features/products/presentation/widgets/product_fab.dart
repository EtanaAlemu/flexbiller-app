import 'package:flutter/material.dart';
import '../pages/create_product_page.dart';
import '../../domain/entities/product.dart';

class ProductFab extends StatelessWidget {
  final Function(Product)? onCreateProduct;

  const ProductFab({super.key, this.onCreateProduct});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _onCreateProduct(context),
      tooltip: 'Create Product',
      child: const Icon(Icons.add),
    );
  }

  void _onCreateProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateProductPage(onCreateProduct: onCreateProduct),
      ),
    );
  }
}
