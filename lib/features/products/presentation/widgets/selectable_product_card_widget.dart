import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';
import '../pages/product_detail_page.dart';
import '../pages/edit_product_page.dart';
import '../bloc/product_multiselect_bloc.dart';
import '../bloc/events/product_multiselect_events.dart';
import '../bloc/products_list_bloc.dart';
import '../bloc/events/products_list_events.dart';
import '../bloc/states/products_list_states.dart';
import 'product_list_item.dart';

class SelectableProductCardWidget extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final bool isMultiSelectMode;

  const SelectableProductCardWidget({
    Key? key,
    required this.product,
    required this.isSelected,
    required this.isMultiSelectMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
      ),
      child: GestureDetector(
        onTap: () {
          if (isMultiSelectMode) {
            _toggleSelection(context);
          } else {
            _navigateToDetails(context);
          }
        },
        onLongPressStart: (details) {
          // Long press start - no action needed
        },
        onLongPress: () {
          // Long press handled below
          if (!isMultiSelectMode) {
            _enableMultiSelectModeAndSelect(context);
          }
        },
        child: Stack(
          children: [
            // Main product content
            ProductListItem(
              product: product,
              onTap: () {
                if (isMultiSelectMode) {
                  _toggleSelection(context);
                } else {
                  _navigateToDetails(context);
                }
              },
              onEdit: () => _navigateToEdit(context),
              onDelete: () => _showDeleteDialog(context),
            ),
            // Selection indicator
            if (isMultiSelectMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 16,
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(BuildContext context) {
    final bloc = context.read<ProductMultiSelectBloc>();

    if (isSelected) {
      bloc.add(DeselectProduct(product));
    } else {
      bloc.add(SelectProduct(product));
    }
  }

  void _enableMultiSelectModeAndSelect(BuildContext context) {
    final bloc = context.read<ProductMultiSelectBloc>();
    bloc.add(EnableMultiSelectModeAndSelect(product));

    // Provide haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: product),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                _performDelete(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _performDelete(BuildContext context) {
    // Dispatch delete event to ProductsListBloc
    context.read<ProductsListBloc>().add(DeleteProduct(productId: product.id));

    // Listen for delete completion
    context.read<ProductsListBloc>().stream.listen((state) {
      if (state is ProductDeleted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Product "${product.productName}" deleted successfully',
        );
      } else if (state is ProductsListError) {
        CustomSnackBar.showError(
          context,
          message: 'Failed to delete product: ${state.message}',
        );
      }
    });
  }
}
