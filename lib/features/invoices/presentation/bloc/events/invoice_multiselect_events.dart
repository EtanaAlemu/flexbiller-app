import 'package:equatable/equatable.dart';
import '../../../domain/entities/invoice.dart';

/// Base class for multi-select events
abstract class InvoiceMultiSelectEvent extends Equatable {
  const InvoiceMultiSelectEvent();

  @override
  List<Object?> get props => [];
}

/// Event to enable multi-select mode
class EnableMultiSelectMode extends InvoiceMultiSelectEvent {
  const EnableMultiSelectMode();
}

/// Event to enable multi-select mode and select an invoice
class EnableMultiSelectModeAndSelect extends InvoiceMultiSelectEvent {
  final Invoice invoice;

  const EnableMultiSelectModeAndSelect(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

/// Event to enable multi-select mode and select all invoices
class EnableMultiSelectModeAndSelectAll extends InvoiceMultiSelectEvent {
  final List<Invoice> invoices;

  const EnableMultiSelectModeAndSelectAll({required this.invoices});

  @override
  List<Object?> get props => [invoices];
}

/// Event to disable multi-select mode
class DisableMultiSelectMode extends InvoiceMultiSelectEvent {
  const DisableMultiSelectMode();
}

/// Event to select an invoice
class SelectInvoice extends InvoiceMultiSelectEvent {
  final Invoice invoice;

  const SelectInvoice(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

/// Event to deselect an invoice
class DeselectInvoice extends InvoiceMultiSelectEvent {
  final Invoice invoice;

  const DeselectInvoice(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

/// Event to select all invoices
class SelectAllInvoices extends InvoiceMultiSelectEvent {
  final List<Invoice> invoices;

  const SelectAllInvoices({required this.invoices});

  @override
  List<Object?> get props => [invoices];
}

/// Event to deselect all invoices
class DeselectAllInvoices extends InvoiceMultiSelectEvent {
  const DeselectAllInvoices();
}

/// Event to bulk export selected invoices
class BulkExportInvoices extends InvoiceMultiSelectEvent {
  final String format;

  const BulkExportInvoices(this.format);

  @override
  List<Object?> get props => [format];
}

/// Event to bulk delete selected invoices
class BulkDeleteInvoices extends InvoiceMultiSelectEvent {
  const BulkDeleteInvoices();
}

