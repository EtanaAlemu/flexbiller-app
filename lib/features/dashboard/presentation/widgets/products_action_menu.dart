import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../products/presentation/bloc/products_list_bloc.dart';
import '../../../products/presentation/bloc/events/products_list_events.dart';
import '../../../products/presentation/bloc/states/products_list_states.dart';
import '../../../products/domain/entities/product.dart';

class ProductsActionMenu extends StatelessWidget {
  final GlobalKey? productsViewKey;

  const ProductsActionMenu({Key? key, this.productsViewKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        // Filter section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'FILTER & SORT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'search',
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Search Products'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sort',
          child: Row(
            children: [
              Icon(
                Icons.sort_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Sort Options'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Actions section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'ACTIONS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            children: [
              Icon(
                Icons.download_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Export Products'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'refresh',
          child: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Refresh Data'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Settings section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'SETTINGS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'view_mode',
          child: Row(
            children: [
              Icon(
                Icons.view_module_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('View Mode'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'search':
        _toggleSearchBar(context);
        break;
      case 'sort':
        _showSortOptions(context);
        break;
      case 'export':
        _exportProducts(context);
        break;
      case 'refresh':
        _refreshProducts(context);
        break;
      case 'view_mode':
        _showViewModeOptions(context);
        break;
    }
  }

  void _toggleSearchBar(BuildContext context) {
    if (productsViewKey?.currentState != null) {
      (productsViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Products',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSortOption(
              context,
              'Name (A-Z)',
              'productName',
              'ASC',
              Icons.sort_by_alpha,
            ),
            _buildSortOption(
              context,
              'Name (Z-A)',
              'productName',
              'DESC',
              Icons.sort_by_alpha,
            ),
            _buildSortOption(
              context,
              'Created Date (Newest)',
              'createdAt',
              'DESC',
              Icons.calendar_today,
            ),
            _buildSortOption(
              context,
              'Created Date (Oldest)',
              'createdAt',
              'ASC',
              Icons.calendar_today,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    String sortBy,
    String sortOrder,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _applySort(context, sortBy, sortOrder);
      },
    );
  }

  void _applySort(BuildContext context, String sortBy, String sortOrder) {
    final bloc = context.read<ProductsListBloc>();
    bloc.add(const GetAllProducts());
  }

  void _exportProducts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Products'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToCSV(context);
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToJSON(context);
            },
            child: const Text('JSON'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportToCSV(BuildContext context) async {
    try {
      final state = context.read<ProductsListBloc>().state;
      if (state is ProductsListSuccess) {
        final products = state.products;
        final csvContent = _generateCSV(products);
        await _saveAndShareFile(csvContent, 'products.csv', 'text/csv');
        _showSuccessMessage(context, 'Products exported to CSV successfully!');
      } else {
        _showErrorMessage(context, 'No products to export');
      }
    } catch (e) {
      _showErrorMessage(context, 'Failed to export products: $e');
    }
  }

  void _exportToJSON(BuildContext context) async {
    try {
      final state = context.read<ProductsListBloc>().state;
      if (state is ProductsListSuccess) {
        final products = state.products;
        final jsonContent = _generateJSON(products);
        await _saveAndShareFile(
          jsonContent,
          'products.json',
          'application/json',
        );
        _showSuccessMessage(context, 'Products exported to JSON successfully!');
      } else {
        _showErrorMessage(context, 'No products to export');
      }
    } catch (e) {
      _showErrorMessage(context, 'Failed to export products: $e');
    }
  }

  String _generateCSV(List<Product> products) {
    final buffer = StringBuffer();
    buffer.writeln(
      'ID,Product Name,Description,Tenant ID,Created At,Updated At,Created By,Updated By',
    );

    for (final product in products) {
      buffer.writeln(
        '"${product.id}",'
        '"${product.productName}",'
        '"${product.productDescription}",'
        '"${product.tenantId}",'
        '"${product.createdAt.toIso8601String()}",'
        '"${product.updatedAt.toIso8601String()}",'
        '"${product.createdBy}",'
        '"${product.updatedBy}"',
      );
    }

    return buffer.toString();
  }

  String _generateJSON(List<Product> products) {
    final jsonList = products
        .map(
          (product) => {
            'id': product.id,
            'productName': product.productName,
            'productDescription': product.productDescription,
            'tenantId': product.tenantId,
            'createdAt': product.createdAt.toIso8601String(),
            'updatedAt': product.updatedAt.toIso8601String(),
            'createdBy': product.createdBy,
            'updatedBy': product.updatedBy,
          },
        )
        .toList();

    return '{"products": ${jsonList.toString()}}';
  }

  Future<void> _saveAndShareFile(
    String content,
    String fileName,
    String mimeType,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);

    await Share.shareXFiles([XFile(file.path)], text: 'Products Export');
  }

  void _refreshProducts(BuildContext context) {
    final bloc = context.read<ProductsListBloc>();
    bloc.add(const GetAllProducts());
    _showSuccessMessage(context, 'Products refreshed successfully!');
  }

  void _showViewModeOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('View Mode'),
        content: const Text('Choose your preferred view mode:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context, 'View mode changed to List');
            },
            child: const Text('List View'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context, 'View mode changed to Grid');
            },
            child: const Text('Grid View'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
