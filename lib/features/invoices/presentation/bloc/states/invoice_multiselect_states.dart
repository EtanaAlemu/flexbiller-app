import 'package:equatable/equatable.dart';
import '../../../domain/entities/invoice.dart';

/// Base class for multi-select states
abstract class InvoiceMultiSelectState extends Equatable {
  const InvoiceMultiSelectState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class InvoiceMultiSelectInitial extends InvoiceMultiSelectState {
  const InvoiceMultiSelectInitial();
}

/// Multi-select mode enabled state
class MultiSelectModeEnabled extends InvoiceMultiSelectState {
  final List<Invoice> selectedInvoices;

  const MultiSelectModeEnabled({required this.selectedInvoices});

  @override
  List<Object?> get props => [selectedInvoices];
}

/// Multi-select mode disabled state
class MultiSelectModeDisabled extends InvoiceMultiSelectState {
  const MultiSelectModeDisabled();
}

/// Invoice selected state
class InvoiceSelected extends InvoiceMultiSelectState {
  final Invoice invoice;
  final List<Invoice> selectedInvoices;

  const InvoiceSelected({
    required this.invoice,
    required this.selectedInvoices,
  });

  @override
  List<Object?> get props => [invoice, selectedInvoices];
}

/// Invoice deselected state
class InvoiceDeselected extends InvoiceMultiSelectState {
  final Invoice invoice;
  final List<Invoice> selectedInvoices;

  const InvoiceDeselected({
    required this.invoice,
    required this.selectedInvoices,
  });

  @override
  List<Object?> get props => [invoice, selectedInvoices];
}

/// All invoices selected state
class AllInvoicesSelected extends InvoiceMultiSelectState {
  final List<Invoice> selectedInvoices;

  const AllInvoicesSelected({required this.selectedInvoices});

  @override
  List<Object?> get props => [selectedInvoices];
}

/// All invoices deselected state
class AllInvoicesDeselected extends InvoiceMultiSelectState {
  const AllInvoicesDeselected();
}

/// Bulk export in progress state
class BulkExportInProgress extends InvoiceMultiSelectState {
  final List<Invoice> selectedInvoices;

  const BulkExportInProgress({required this.selectedInvoices});

  @override
  List<Object?> get props => [selectedInvoices];
}

/// Bulk export completed state
class BulkExportCompleted extends InvoiceMultiSelectState {
  final String filePath;

  const BulkExportCompleted({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Bulk export failed state
class BulkExportFailed extends InvoiceMultiSelectState {
  final String error;

  const BulkExportFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Bulk delete in progress state
class BulkDeleteInProgress extends InvoiceMultiSelectState {
  const BulkDeleteInProgress();
}

/// Bulk delete completed state
class BulkDeleteCompleted extends InvoiceMultiSelectState {
  final int deletedCount;

  const BulkDeleteCompleted(this.deletedCount);

  @override
  List<Object?> get props => [deletedCount];
}

/// Bulk delete failed state
class BulkDeleteFailed extends InvoiceMultiSelectState {
  final String error;

  const BulkDeleteFailed(this.error);

  @override
  List<Object?> get props => [error];
}
