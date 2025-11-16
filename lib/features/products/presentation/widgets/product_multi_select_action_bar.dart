import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_multiselect_bloc.dart';
import '../bloc/events/product_multiselect_events.dart';
import '../../../../core/widgets/delete_confirmation_dialog.dart';
import 'export_products_dialog.dart';

class ProductMultiSelectActionBar extends StatefulWidget {
  final List<Product> selectedProducts;
  final bool isAllSelected;
  final List<Product> allProducts;

  const ProductMultiSelectActionBar({
    Key? key,
    required this.selectedProducts,
    required this.isAllSelected,
    required this.allProducts,
  }) : super(key: key);

  @override
  State<ProductMultiSelectActionBar> createState() =>
      _ProductMultiSelectActionBarState();
}

class _ProductMultiSelectActionBarState
    extends State<ProductMultiSelectActionBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () {
              context.read<ProductMultiSelectBloc>().add(
                const DisableMultiSelectMode(),
              );
            },
            icon: const Icon(Icons.close),
            tooltip: 'Exit multi-select',
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(width: 8),

          // Selection count
          Text(
            '${widget.selectedProducts.length} selected',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const Spacer(),

          // Select all / Deselect all button
          IconButton(
            onPressed: () {
              if (widget.isAllSelected) {
                context.read<ProductMultiSelectBloc>().add(
                  const DeselectAllProducts(),
                );
              } else {
                context.read<ProductMultiSelectBloc>().add(
                  SelectAllProducts(products: widget.allProducts),
                );
              }
            },
            icon: Icon(
              widget.isAllSelected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            tooltip: widget.isAllSelected ? 'Deselect all' : 'Select all',
            style: IconButton.styleFrom(
              foregroundColor: widget.isAllSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),

          // Export button
          IconButton(
            onPressed: widget.selectedProducts.isNotEmpty
                ? _showExportDialog
                : null,
            icon: const Icon(Icons.download),
            tooltip: 'Export selected',
            style: IconButton.styleFrom(
              foregroundColor: widget.selectedProducts.isNotEmpty
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),

          // Delete button
          IconButton(
            onPressed: widget.selectedProducts.isNotEmpty
                ? _showDeleteDialog
                : null,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete selected',
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExportDialog() async {
    // Show export dialog for better user experience
    final result = await showDialog(
      context: context,
      builder: (context) =>
          ExportProductsDialog(products: widget.selectedProducts),
    );
    if (result != null) {
      final selectedFormat = result['format'] as String;
      await _performExport(context, widget.selectedProducts, selectedFormat);
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'Delete Products',
      itemName: 'product(s)',
      count: widget.selectedProducts.length,
    );

    if (confirmed) {
      context.read<ProductMultiSelectBloc>().add(const BulkDeleteProducts());
    }
  }

  Future<void> _performExport(
    BuildContext context,
    List<Product> productsToExport,
    String format,
  ) async {
    // Dispatch export event to BLoC - the BLoC will handle the export and emit states
    context.read<ProductMultiSelectBloc>().add(BulkExportProducts(format));
  }
}
