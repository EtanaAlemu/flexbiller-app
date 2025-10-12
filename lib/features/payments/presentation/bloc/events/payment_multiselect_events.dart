import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';

/// Base class for multi-select events
abstract class PaymentMultiSelectEvent extends Equatable {
  const PaymentMultiSelectEvent();

  @override
  List<Object?> get props => [];
}

/// Event to enable multi-select mode
class EnableMultiSelectMode extends PaymentMultiSelectEvent {
  const EnableMultiSelectMode();
}

/// Event to enable multi-select mode and select a payment
class EnableMultiSelectModeAndSelect extends PaymentMultiSelectEvent {
  final Payment payment;

  const EnableMultiSelectModeAndSelect(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Event to enable multi-select mode and select all payments
class EnableMultiSelectModeAndSelectAll extends PaymentMultiSelectEvent {
  final List<Payment> payments;

  const EnableMultiSelectModeAndSelectAll({required this.payments});

  @override
  List<Object?> get props => [payments];
}

/// Event to disable multi-select mode
class DisableMultiSelectMode extends PaymentMultiSelectEvent {
  const DisableMultiSelectMode();
}

/// Event to select a payment
class SelectPayment extends PaymentMultiSelectEvent {
  final Payment payment;

  const SelectPayment(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Event to deselect a payment
class DeselectPayment extends PaymentMultiSelectEvent {
  final Payment payment;

  const DeselectPayment(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Event to select all payments
class SelectAllPayments extends PaymentMultiSelectEvent {
  final List<Payment> payments;

  const SelectAllPayments({required this.payments});

  @override
  List<Object?> get props => [payments];
}

/// Event to deselect all payments
class DeselectAllPayments extends PaymentMultiSelectEvent {
  const DeselectAllPayments();
}

/// Event to bulk export selected payments
class BulkExportPayments extends PaymentMultiSelectEvent {
  final String format;

  const BulkExportPayments(this.format);

  @override
  List<Object?> get props => [format];
}
