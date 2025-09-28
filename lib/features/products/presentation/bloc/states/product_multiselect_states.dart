import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

/// Base class for multi-select states
abstract class ProductMultiSelectState extends Equatable {
  const ProductMultiSelectState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductMultiSelectInitial extends ProductMultiSelectState {
  const ProductMultiSelectInitial();
}

/// Multi-select mode enabled state
class MultiSelectModeEnabled extends ProductMultiSelectState {
  final List<Product> selectedProducts;

  const MultiSelectModeEnabled({required this.selectedProducts});

  @override
  List<Object?> get props => [selectedProducts];
}

/// Multi-select mode disabled state
class MultiSelectModeDisabled extends ProductMultiSelectState {
  const MultiSelectModeDisabled();
}

/// Product selected state
class ProductSelected extends ProductMultiSelectState {
  final Product product;
  final List<Product> selectedProducts;

  const ProductSelected({
    required this.product,
    required this.selectedProducts,
  });

  @override
  List<Object?> get props => [product, selectedProducts];
}

/// Product deselected state
class ProductDeselected extends ProductMultiSelectState {
  final Product product;
  final List<Product> selectedProducts;

  const ProductDeselected({
    required this.product,
    required this.selectedProducts,
  });

  @override
  List<Object?> get props => [product, selectedProducts];
}

/// All products selected state
class AllProductsSelected extends ProductMultiSelectState {
  final List<Product> selectedProducts;

  const AllProductsSelected({required this.selectedProducts});

  @override
  List<Object?> get props => [selectedProducts];
}

/// All products deselected state
class AllProductsDeselected extends ProductMultiSelectState {
  const AllProductsDeselected();
}

/// Bulk delete in progress state
class BulkDeleteInProgress extends ProductMultiSelectState {
  final List<Product> selectedProducts;

  const BulkDeleteInProgress({required this.selectedProducts});

  @override
  List<Object?> get props => [selectedProducts];
}

/// Bulk delete completed state
class BulkDeleteCompleted extends ProductMultiSelectState {
  final int deletedCount;

  const BulkDeleteCompleted({required this.deletedCount});

  @override
  List<Object?> get props => [deletedCount];
}

/// Bulk delete failed state
class BulkDeleteFailed extends ProductMultiSelectState {
  final String error;

  const BulkDeleteFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Bulk export in progress state
class BulkExportInProgress extends ProductMultiSelectState {
  final List<Product> selectedProducts;

  const BulkExportInProgress({required this.selectedProducts});

  @override
  List<Object?> get props => [selectedProducts];
}

/// Bulk export completed state
class BulkExportCompleted extends ProductMultiSelectState {
  final String filePath;

  const BulkExportCompleted({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Bulk export failed state
class BulkExportFailed extends ProductMultiSelectState {
  final String error;

  const BulkExportFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

