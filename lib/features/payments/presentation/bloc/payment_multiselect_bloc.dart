import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/payment.dart';
import '../bloc/events/payment_multiselect_events.dart';
import '../bloc/states/payment_multiselect_states.dart';

/// BLoC for handling multi-select operations
@injectable
class PaymentMultiSelectBloc
    extends Bloc<PaymentMultiSelectEvent, PaymentMultiSelectState> {
  final Logger _logger = Logger();

  final List<Payment> _selectedPayments = [];
  bool _isMultiSelectMode = false;

  PaymentMultiSelectBloc() : super(const PaymentMultiSelectInitial()) {
    // Register event handlers
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<EnableMultiSelectModeAndSelect>(_onEnableMultiSelectModeAndSelect);
    on<EnableMultiSelectModeAndSelectAll>(_onEnableMultiSelectModeAndSelectAll);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<SelectPayment>(_onSelectPayment);
    on<DeselectPayment>(_onDeselectPayment);
    on<SelectAllPayments>(_onSelectAllPayments);
    on<DeselectAllPayments>(_onDeselectAllPayments);
    on<BulkExportPayments>(_onBulkExportPayments);
  }

  /// Get the current list of selected payments
  List<Payment> get selectedPayments => List.unmodifiable(_selectedPayments);

  /// Check if multi-select mode is enabled
  bool get isMultiSelectMode => _isMultiSelectMode;

  /// Check if a payment is selected
  bool isPaymentSelected(Payment payment) {
    return _selectedPayments.any(
      (selected) => selected.paymentId == payment.paymentId,
    );
  }

  /// Get the count of selected payments
  int get selectedCount => _selectedPayments.length;

  void _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<PaymentMultiSelectState> emit,
  ) {
    _logger.d('Enabling multi-select mode');
    _isMultiSelectMode = true;
    emit(MultiSelectModeEnabled(selectedPayments: _selectedPayments));
  }

  void _onEnableMultiSelectModeAndSelect(
    EnableMultiSelectModeAndSelect event,
    Emitter<PaymentMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting payment: ${event.payment.paymentNumber}',
    );
    _isMultiSelectMode = true;
    _selectedPayments.add(event.payment);
    emit(MultiSelectModeEnabled(selectedPayments: _selectedPayments));
  }

  void _onEnableMultiSelectModeAndSelectAll(
    EnableMultiSelectModeAndSelectAll event,
    Emitter<PaymentMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting all ${event.payments.length} payments',
    );
    _isMultiSelectMode = true;
    _selectedPayments.clear();
    _selectedPayments.addAll(event.payments);
    emit(MultiSelectModeEnabled(selectedPayments: _selectedPayments));
  }

  void _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<PaymentMultiSelectState> emit,
  ) {
    _logger.d('Disabling multi-select mode');
    _isMultiSelectMode = false;
    _selectedPayments.clear();
    emit(const MultiSelectModeDisabled());
  }

  void _onSelectPayment(
    SelectPayment event,
    Emitter<PaymentMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select payment: multi-select mode is not enabled');
      return;
    }

    if (!isPaymentSelected(event.payment)) {
      _logger.d('Selecting payment: ${event.payment.paymentNumber}');
      _selectedPayments.add(event.payment);
      emit(
        PaymentSelected(
          payment: event.payment,
          selectedPayments: _selectedPayments,
        ),
      );
    }
  }

  void _onDeselectPayment(
    DeselectPayment event,
    Emitter<PaymentMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot deselect payment: multi-select mode is not enabled');
      return;
    }

    _logger.d('Deselecting payment: ${event.payment.paymentNumber}');
    _selectedPayments.removeWhere(
      (p) => p.paymentId == event.payment.paymentId,
    );
    emit(
      PaymentDeselected(
        payment: event.payment,
        selectedPayments: _selectedPayments,
      ),
    );
  }

  void _onSelectAllPayments(
    SelectAllPayments event,
    Emitter<PaymentMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select all payments: multi-select mode is not enabled');
      return;
    }

    _logger.d('Selecting all ${event.payments.length} payments');
    _selectedPayments.clear();
    _selectedPayments.addAll(event.payments);
    emit(AllPaymentsSelected(selectedPayments: _selectedPayments));
  }

  void _onDeselectAllPayments(
    DeselectAllPayments event,
    Emitter<PaymentMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w(
        'Cannot deselect all payments: multi-select mode is not enabled',
      );
      return;
    }

    _logger.d('Deselecting all payments');
    _selectedPayments.clear();
    emit(const AllPaymentsDeselected());
  }

  void _onBulkExportPayments(
    BulkExportPayments event,
    Emitter<PaymentMultiSelectState> emit,
  ) async {
    if (!_isMultiSelectMode || _selectedPayments.isEmpty) {
      _logger.w(
        'Cannot bulk export: no payments selected or multi-select mode disabled',
      );
      return;
    }

    _logger.d(
      'Starting bulk export of ${_selectedPayments.length} payments in ${event.format} format',
    );
    emit(BulkExportInProgress(selectedPayments: _selectedPayments));

    try {
      // Generate timestamp for unique file naming
      final dateTime = DateTime.now();
      final formattedDate =
          '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}${dateTime.second.toString().padLeft(2, '0')}';

      // Generate file content based on format
      String fileContent;
      String fileExtension;

      if (event.format == 'excel') {
        fileContent = _generateExcelContent(_selectedPayments);
        fileExtension = 'xlsx';
      } else {
        fileContent = _generateCSVContent(_selectedPayments);
        fileExtension = 'csv';
      }

      // Convert string content to bytes
      final bytes = Uint8List.fromList(fileContent.codeUnits);

      // Let user choose where to save the file
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Payments Export',
        fileName: 'payments_export_$formattedDate.$fileExtension',
        type: event.format == 'excel' ? FileType.custom : FileType.custom,
        allowedExtensions: event.format == 'excel' ? ['xlsx'] : ['csv'],
        bytes: bytes,
      );

      if (outputFile != null) {
        _logger.d('Bulk export completed successfully: $outputFile');
        emit(BulkExportCompleted(filePath: outputFile));
      } else {
        _logger.d('Export cancelled by user');
        emit(const BulkExportFailed(error: 'Export cancelled by user'));
      }
    } catch (e) {
      _logger.e('Bulk export failed: $e');
      emit(BulkExportFailed(error: e.toString()));
    }
  }

  String _generateCSVContent(List<Payment> payments) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln('Payment Number,Account ID,Amount,Currency,Status,Date');

    // CSV Data
    for (final payment in payments) {
      final status = payment.transactions.isNotEmpty
          ? payment.transactions.first.status
          : 'Unknown';
      final date = payment.transactions.isNotEmpty
          ? payment.transactions.first.effectiveDate.toString()
          : 'Unknown';

      buffer.writeln(
        '${payment.paymentNumber},'
        '${payment.accountId},'
        '${payment.purchasedAmount},'
        '${payment.currency},'
        '$status,'
        '$date',
      );
    }

    return buffer.toString();
  }

  String _generateExcelContent(List<Payment> payments) {
    // For now, generate CSV content as Excel files are complex
    // In a real implementation, you would use a library like 'excel' package
    return _generateCSVContent(payments);
  }
}
