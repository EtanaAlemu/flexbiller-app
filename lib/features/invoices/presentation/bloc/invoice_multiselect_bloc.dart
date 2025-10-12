import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/invoice.dart';
import '../bloc/events/invoice_multiselect_events.dart';
import '../bloc/states/invoice_multiselect_states.dart';

/// BLoC for handling multi-select operations
@injectable
class InvoiceMultiSelectBloc
    extends Bloc<InvoiceMultiSelectEvent, InvoiceMultiSelectState> {
  final Logger _logger = Logger();

  final List<Invoice> _selectedInvoices = [];
  bool _isMultiSelectMode = false;

  InvoiceMultiSelectBloc() : super(const InvoiceMultiSelectInitial()) {
    // Register event handlers
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<EnableMultiSelectModeAndSelect>(_onEnableMultiSelectModeAndSelect);
    on<EnableMultiSelectModeAndSelectAll>(_onEnableMultiSelectModeAndSelectAll);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<SelectInvoice>(_onSelectInvoice);
    on<DeselectInvoice>(_onDeselectInvoice);
    on<SelectAllInvoices>(_onSelectAllInvoices);
    on<DeselectAllInvoices>(_onDeselectAllInvoices);
    on<BulkExportInvoices>(_onBulkExportInvoices);
    on<BulkDeleteInvoices>(_onBulkDeleteInvoices);
  }

  /// Get the current list of selected invoices
  List<Invoice> get selectedInvoices => List.unmodifiable(_selectedInvoices);

  /// Check if multi-select mode is enabled
  bool get isMultiSelectMode => _isMultiSelectMode;

  /// Check if an invoice is selected
  bool isInvoiceSelected(Invoice invoice) {
    return _selectedInvoices.any(
      (selected) => selected.invoiceId == invoice.invoiceId,
    );
  }

  /// Get the count of selected invoices
  int get selectedCount => _selectedInvoices.length;

  void _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<InvoiceMultiSelectState> emit,
  ) {
    _logger.d('Enabling multi-select mode');
    _isMultiSelectMode = true;
    emit(MultiSelectModeEnabled(selectedInvoices: _selectedInvoices));
  }

  void _onEnableMultiSelectModeAndSelect(
    EnableMultiSelectModeAndSelect event,
    Emitter<InvoiceMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting invoice: ${event.invoice.invoiceNumber}',
    );
    _isMultiSelectMode = true;
    _selectedInvoices.add(event.invoice);
    emit(MultiSelectModeEnabled(selectedInvoices: _selectedInvoices));
  }

  void _onEnableMultiSelectModeAndSelectAll(
    EnableMultiSelectModeAndSelectAll event,
    Emitter<InvoiceMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting all ${event.invoices.length} invoices',
    );
    _isMultiSelectMode = true;
    _selectedInvoices.clear();
    _selectedInvoices.addAll(event.invoices);
    emit(MultiSelectModeEnabled(selectedInvoices: _selectedInvoices));
  }

  void _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<InvoiceMultiSelectState> emit,
  ) {
    _logger.d('Disabling multi-select mode');
    _isMultiSelectMode = false;
    _selectedInvoices.clear();
    emit(const MultiSelectModeDisabled());
  }

  void _onSelectInvoice(
    SelectInvoice event,
    Emitter<InvoiceMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select invoice: multi-select mode is not enabled');
      return;
    }

    if (!isInvoiceSelected(event.invoice)) {
      _logger.d('Selecting invoice: ${event.invoice.invoiceNumber}');
      _selectedInvoices.add(event.invoice);
      emit(
        InvoiceSelected(
          invoice: event.invoice,
          selectedInvoices: _selectedInvoices,
        ),
      );
    }
  }

  void _onDeselectInvoice(
    DeselectInvoice event,
    Emitter<InvoiceMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot deselect invoice: multi-select mode is not enabled');
      return;
    }

    if (isInvoiceSelected(event.invoice)) {
      _logger.d('Deselecting invoice: ${event.invoice.invoiceNumber}');
      _selectedInvoices.removeWhere(
        (selected) => selected.invoiceId == event.invoice.invoiceId,
      );
      emit(
        InvoiceDeselected(
          invoice: event.invoice,
          selectedInvoices: _selectedInvoices,
        ),
      );
    }
  }

  void _onSelectAllInvoices(
    SelectAllInvoices event,
    Emitter<InvoiceMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select all invoices: multi-select mode is not enabled');
      return;
    }

    _logger.d('Selecting all ${event.invoices.length} invoices');
    _selectedInvoices.clear();
    _selectedInvoices.addAll(event.invoices);
    emit(AllInvoicesSelected(selectedInvoices: _selectedInvoices));
  }

  void _onDeselectAllInvoices(
    DeselectAllInvoices event,
    Emitter<InvoiceMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w(
        'Cannot deselect all invoices: multi-select mode is not enabled',
      );
      return;
    }

    _logger.d('Deselecting all invoices');
    _selectedInvoices.clear();
    emit(const AllInvoicesDeselected());
  }

  void _onBulkExportInvoices(
    BulkExportInvoices event,
    Emitter<InvoiceMultiSelectState> emit,
  ) async {
    if (!_isMultiSelectMode || _selectedInvoices.isEmpty) {
      _logger.w(
        'Cannot bulk export: no invoices selected or multi-select mode disabled',
      );
      return;
    }

    _logger.d(
      'Starting bulk export of ${_selectedInvoices.length} invoices in ${event.format} format',
    );
    emit(BulkExportInProgress(selectedInvoices: _selectedInvoices));

    try {
      // Generate timestamp for unique file naming
      final dateTime = DateTime.now();
      final formattedDate =
          '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}${dateTime.second.toString().padLeft(2, '0')}';

      // Generate file content based on format
      String fileContent;
      String fileExtension;

      if (event.format == 'excel') {
        fileContent = _generateExcelContent(_selectedInvoices);
        fileExtension = 'xlsx';
      } else {
        fileContent = _generateCSVContent(_selectedInvoices);
        fileExtension = 'csv';
      }

      // Convert string content to bytes
      final bytes = Uint8List.fromList(fileContent.codeUnits);

      // Let user choose where to save the file
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Invoices Export',
        fileName: 'invoices_export_$formattedDate.$fileExtension',
        type: event.format == 'excel' ? FileType.custom : FileType.custom,
        allowedExtensions: event.format == 'excel' ? ['xlsx'] : ['csv'],
        bytes: bytes,
      );

      if (outputFile != null) {
        _logger.d('Bulk export completed successfully: $outputFile');
        emit(BulkExportCompleted(filePath: outputFile));

        // Automatically disable multi-select mode after successful export
        _logger.d('Disabling multi-select mode after successful export');
        _isMultiSelectMode = false;
        _selectedInvoices.clear();
        emit(const MultiSelectModeDisabled());
      } else {
        _logger.d('Export cancelled by user');
        emit(const BulkExportFailed(error: 'Export cancelled by user'));
      }
    } catch (e) {
      _logger.e('Bulk export failed: $e');
      emit(BulkExportFailed(error: e.toString()));
    }
  }

  String _generateCSVContent(List<Invoice> invoices) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Invoice Number,Invoice ID,Account ID,Amount,Currency,Status,Invoice Date,Target Date,Balance',
    );

    // CSV Data
    for (final invoice in invoices) {
      buffer.writeln(
        '${invoice.invoiceNumber},'
        '${invoice.invoiceId},'
        '${invoice.accountId},'
        '${invoice.amount},'
        '${invoice.currency},'
        '${invoice.status},'
        '${invoice.invoiceDate},'
        '${invoice.targetDate},'
        '${invoice.balance}',
      );
    }

    return buffer.toString();
  }

  String _generateExcelContent(List<Invoice> invoices) {
    // For now, generate CSV content as Excel files are complex
    // In a real implementation, you would use a library like 'excel' package
    return _generateCSVContent(invoices);
  }

  void _onBulkDeleteInvoices(
    BulkDeleteInvoices event,
    Emitter<InvoiceMultiSelectState> emit,
  ) async {
    if (_selectedInvoices.isEmpty) {
      _logger.w('Cannot delete: no invoices selected');
      return;
    }

    try {
      _logger.d('Starting bulk delete of ${_selectedInvoices.length} invoices');
      emit(const BulkDeleteInProgress());

      // Simulate delete process
      await Future.delayed(const Duration(seconds: 1));

      final deletedCount = _selectedInvoices.length;
      _selectedInvoices.clear();

      _logger.d('Bulk delete completed: $deletedCount invoices deleted');
      emit(BulkDeleteCompleted(deletedCount));
    } catch (e) {
      _logger.e('Bulk delete failed: $e');
      emit(BulkDeleteFailed(e.toString()));
    }
  }
}
