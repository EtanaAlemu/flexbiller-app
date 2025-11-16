import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../bloc/events/product_multiselect_events.dart';
import '../bloc/states/product_multiselect_states.dart';

/// BLoC for handling multi-select operations
@injectable
class ProductMultiSelectBloc
    extends Bloc<ProductMultiSelectEvent, ProductMultiSelectState>
    with BlocErrorHandlerMixin {
  final DeleteProductUseCase _deleteProductUseCase;
  final Logger _logger = Logger();

  final List<Product> _selectedProducts = [];
  bool _isMultiSelectMode = false;

  ProductMultiSelectBloc({required DeleteProductUseCase deleteProductUseCase})
    : _deleteProductUseCase = deleteProductUseCase,
      super(const ProductMultiSelectInitial()) {
    // Register event handlers
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<EnableMultiSelectModeAndSelect>(_onEnableMultiSelectModeAndSelect);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<SelectProduct>(_onSelectProduct);
    on<DeselectProduct>(_onDeselectProduct);
    on<SelectAllProducts>(_onSelectAllProducts);
    on<DeselectAllProducts>(_onDeselectAllProducts);
    on<BulkDeleteProducts>(_onBulkDeleteProducts);
    on<BulkExportProducts>(_onBulkExportProducts);
  }

  /// Get the current list of selected products
  List<Product> get selectedProducts => List.unmodifiable(_selectedProducts);

  /// Check if multi-select mode is enabled
  bool get isMultiSelectMode => _isMultiSelectMode;

  /// Check if a product is selected
  bool isProductSelected(Product product) {
    return _selectedProducts.any((selected) => selected.id == product.id);
  }

  /// Get the count of selected products
  int get selectedCount => _selectedProducts.length;

  void _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<ProductMultiSelectState> emit,
  ) {
    _logger.d('Enabling multi-select mode');
    _isMultiSelectMode = true;
    emit(MultiSelectModeEnabled(selectedProducts: _selectedProducts));
  }

  void _onEnableMultiSelectModeAndSelect(
    EnableMultiSelectModeAndSelect event,
    Emitter<ProductMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting product: ${event.product.productName}',
    );
    _isMultiSelectMode = true;
    _selectedProducts.add(event.product);
    emit(MultiSelectModeEnabled(selectedProducts: _selectedProducts));
  }

  void _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<ProductMultiSelectState> emit,
  ) {
    _logger.d('Disabling multi-select mode');
    _isMultiSelectMode = false;
    _selectedProducts.clear();
    emit(const MultiSelectModeDisabled());
  }

  void _onSelectProduct(
    SelectProduct event,
    Emitter<ProductMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select product: multi-select mode is not enabled');
      return;
    }

    if (!isProductSelected(event.product)) {
      _logger.d('Selecting product: ${event.product.productName}');
      _selectedProducts.add(event.product);
      emit(
        ProductSelected(
          product: event.product,
          selectedProducts: _selectedProducts,
        ),
      );
    }
  }

  void _onDeselectProduct(
    DeselectProduct event,
    Emitter<ProductMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot deselect product: multi-select mode is not enabled');
      return;
    }

    _logger.d('Deselecting product: ${event.product.productName}');
    _selectedProducts.removeWhere((p) => p.id == event.product.id);
    emit(
      ProductDeselected(
        product: event.product,
        selectedProducts: _selectedProducts,
      ),
    );
  }

  void _onSelectAllProducts(
    SelectAllProducts event,
    Emitter<ProductMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select all products: multi-select mode is not enabled');
      return;
    }

    _logger.d('Selecting all ${event.products.length} products');
    _selectedProducts.clear();
    _selectedProducts.addAll(event.products);
    emit(AllProductsSelected(selectedProducts: _selectedProducts));
  }

  void _onDeselectAllProducts(
    DeselectAllProducts event,
    Emitter<ProductMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w(
        'Cannot deselect all products: multi-select mode is not enabled',
      );
      return;
    }

    _logger.d('Deselecting all products');
    _selectedProducts.clear();
    emit(const AllProductsDeselected());
  }

  Future<void> _onBulkDeleteProducts(
    BulkDeleteProducts event,
    Emitter<ProductMultiSelectState> emit,
  ) async {
    if (!_isMultiSelectMode || _selectedProducts.isEmpty) {
      _logger.w(
        'Cannot bulk delete: no products selected or multi-select mode disabled',
      );
      return;
    }

    _logger.d('Starting bulk delete of ${_selectedProducts.length} products');
    emit(BulkDeleteInProgress(selectedProducts: _selectedProducts));

    try {
      int deletedCount = 0;
      for (final product in _selectedProducts) {
        try {
          await _deleteProductUseCase.call(product.id);
          deletedCount++;
          _logger.d('Deleted product: ${product.productName}');
        } catch (e) {
          handleException(e, context: 'delete_product');
        }
      }

      _selectedProducts.clear();
      emit(BulkDeleteCompleted(deletedCount: deletedCount));
      _logger.d('Bulk delete completed: $deletedCount products deleted');
    } catch (e) {
      final message = handleException(e, context: 'bulk_delete_products');
      emit(BulkDeleteFailed(error: message));
    }
  }

  Future<void> _onBulkExportProducts(
    BulkExportProducts event,
    Emitter<ProductMultiSelectState> emit,
  ) async {
    if (!_isMultiSelectMode || _selectedProducts.isEmpty) {
      _logger.w(
        'Cannot bulk export: no products selected or multi-select mode disabled',
      );
      return;
    }

    _logger.d(
      'Starting bulk export of ${_selectedProducts.length} products in ${event.format} format',
    );
    emit(BulkExportInProgress(selectedProducts: _selectedProducts));

    try {
      // Generate timestamp for unique file naming
      final dateTime = DateTime.now();
      final formattedDate =
          '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}${dateTime.second.toString().padLeft(2, '0')}';

      // Generate file content based on format
      String fileContent;
      String fileExtension;

      if (event.format == 'excel') {
        fileContent = _generateExcelContent(_selectedProducts);
        fileExtension = 'xlsx';
      } else {
        fileContent = _generateCSVContent(_selectedProducts);
        fileExtension = 'csv';
      }

      // Convert string content to bytes
      final bytes = Uint8List.fromList(fileContent.codeUnits);

      // Let user choose where to save the file
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Products Export',
        fileName: 'products_export_$formattedDate.$fileExtension',
        type: event.format == 'excel' ? FileType.custom : FileType.custom,
        allowedExtensions: event.format == 'excel' ? ['xlsx'] : ['csv'],
        bytes: bytes,
      );

      if (outputFile != null) {
        // Write the file
        final file = File(outputFile);
        await file.writeAsBytes(bytes);

        _logger.d('Bulk export completed: $outputFile');
        emit(BulkExportCompleted(filePath: outputFile));

        // Share the file
        await Share.shareXFiles([XFile(outputFile)]);
      } else {
        _logger.d('Export cancelled by user');
        emit(BulkExportFailed(error: 'Export cancelled by user'));
      }
    } catch (e) {
      final message = handleException(e, context: 'bulk_export_products');
      emit(BulkExportFailed(error: message));
    }
  }

  /// Generate Excel content for products (simplified implementation)
  String _generateExcelContent(List<Product> products) {
    final buffer = StringBuffer();

    // Add headers with tab separation for better Excel compatibility
    buffer.writeln(
      'Product ID\tProduct Name\tProduct Description\tTenant ID\tCreated At\tUpdated At\tCreated By\tUpdated By',
    );

    // Add product data with tab separation
    for (final product in products) {
      buffer.writeln(
        '${product.id}\t'
        '${product.productName}\t'
        '${product.productDescription}\t'
        '${product.tenantId}\t'
        '${product.createdAt.toLocal().toString().split('.')[0]}\t'
        '${product.updatedAt.toLocal().toString().split('.')[0]}\t'
        '${product.createdBy}\t'
        '${product.updatedBy}',
      );
    }

    return buffer.toString();
  }

  /// Generate CSV content for products
  String _generateCSVContent(List<Product> products) {
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln(
      'Product ID,Product Name,Product Description,Tenant ID,Created At,Updated At,Created By,Updated By',
    );

    // Add product data
    for (final product in products) {
      buffer.writeln(
        '${product.id},'
        '${product.productName},'
        '${product.productDescription},'
        '${product.tenantId},'
        '${product.createdAt.toLocal().toString().split('.')[0]},'
        '${product.updatedAt.toLocal().toString().split('.')[0]},'
        '${product.createdBy},'
        '${product.updatedBy}',
      );
    }

    return buffer.toString();
  }
}
