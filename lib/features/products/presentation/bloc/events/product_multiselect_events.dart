import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

/// Base class for multi-select events
abstract class ProductMultiSelectEvent extends Equatable {
  const ProductMultiSelectEvent();

  @override
  List<Object?> get props => [];
}

/// Event to enable multi-select mode
class EnableMultiSelectMode extends ProductMultiSelectEvent {
  const EnableMultiSelectMode();
}

/// Event to enable multi-select mode and select a product
class EnableMultiSelectModeAndSelect extends ProductMultiSelectEvent {
  final Product product;

  const EnableMultiSelectModeAndSelect(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event to disable multi-select mode
class DisableMultiSelectMode extends ProductMultiSelectEvent {
  const DisableMultiSelectMode();
}

/// Event to select a product
class SelectProduct extends ProductMultiSelectEvent {
  final Product product;

  const SelectProduct(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event to deselect a product
class DeselectProduct extends ProductMultiSelectEvent {
  final Product product;

  const DeselectProduct(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event to select all products
class SelectAllProducts extends ProductMultiSelectEvent {
  final List<Product> products;

  const SelectAllProducts({required this.products});

  @override
  List<Object?> get props => [products];
}

/// Event to deselect all products
class DeselectAllProducts extends ProductMultiSelectEvent {
  const DeselectAllProducts();
}

/// Event to bulk delete selected products
class BulkDeleteProducts extends ProductMultiSelectEvent {
  const BulkDeleteProducts();
}

/// Event to bulk export selected products
class BulkExportProducts extends ProductMultiSelectEvent {
  final String format;

  const BulkExportProducts(this.format);

  @override
  List<Object?> get props => [format];
}

