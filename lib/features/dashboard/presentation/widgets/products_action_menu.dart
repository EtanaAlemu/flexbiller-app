import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';
import 'package:flexbiller_app/core/widgets/sort_options_bottom_sheet.dart';
import 'package:flexbiller_app/core/widgets/view_mode_dialog.dart';
import 'package:flexbiller_app/core/widgets/base_action_menu.dart';
import '../../../products/presentation/bloc/products_list_bloc.dart';
import '../../../products/presentation/bloc/events/products_list_events.dart';
import '../../../products/presentation/bloc/states/products_list_states.dart';
import '../../../products/domain/entities/product.dart';

class ProductsActionMenu extends StatelessWidget {
  final GlobalKey? productsViewKey;

  const ProductsActionMenu({Key? key, this.productsViewKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      ...BaseActionMenu.buildFilterSortSection(
        searchLabel: 'Search Products',
        filterLabel: null,
        showFilter: false,
      ),
      ...BaseActionMenu.buildActionsSection(exportLabel: 'Export Products'),
      ...BaseActionMenu.buildSettingsSection(),
    ];

    return BaseActionMenu(
      menuItems: menuItems,
      onActionSelected: (value) => _handleMenuAction(context, value),
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
    SortOptionsBottomSheet.show(
      context,
      title: 'Sort Products',
      options: const [
        SortOption(
          title: 'Name (A-Z)',
          sortBy: 'productName',
          sortOrder: 'ASC',
          icon: Icons.sort_by_alpha,
        ),
        SortOption(
          title: 'Name (Z-A)',
          sortBy: 'productName',
          sortOrder: 'DESC',
          icon: Icons.sort_by_alpha,
        ),
        SortOption(
          title: 'Created Date (Newest)',
          sortBy: 'createdAt',
          sortOrder: 'DESC',
          icon: Icons.calendar_today,
        ),
        SortOption(
          title: 'Created Date (Oldest)',
          sortBy: 'createdAt',
          sortOrder: 'ASC',
          icon: Icons.calendar_today,
        ),
      ],
      onSortSelected: (sortBy, sortOrder) {
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
    ViewModeDialog.show(
      context,
      title: 'View Mode',
      onModeSelected: (mode) {
        final modeName = mode == ViewMode.list ? 'List' : 'Grid';
        _showSuccessMessage(context, 'View mode changed to $modeName');
      },
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    CustomSnackBar.showSuccess(context, message: message);
  }

  void _showErrorMessage(BuildContext context, String message) {
    CustomSnackBar.showError(context, message: message);
  }
}
