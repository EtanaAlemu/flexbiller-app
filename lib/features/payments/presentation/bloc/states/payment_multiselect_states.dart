import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment.dart';

/// Base class for multi-select states
abstract class PaymentMultiSelectState extends Equatable {
  const PaymentMultiSelectState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PaymentMultiSelectInitial extends PaymentMultiSelectState {
  const PaymentMultiSelectInitial();
}

/// Multi-select mode enabled state
class MultiSelectModeEnabled extends PaymentMultiSelectState {
  final List<Payment> selectedPayments;

  const MultiSelectModeEnabled({required this.selectedPayments});

  @override
  List<Object?> get props => [selectedPayments];
}

/// Multi-select mode disabled state
class MultiSelectModeDisabled extends PaymentMultiSelectState {
  const MultiSelectModeDisabled();
}

/// Payment selected state
class PaymentSelected extends PaymentMultiSelectState {
  final Payment payment;
  final List<Payment> selectedPayments;

  const PaymentSelected({
    required this.payment,
    required this.selectedPayments,
  });

  @override
  List<Object?> get props => [payment, selectedPayments];
}

/// Payment deselected state
class PaymentDeselected extends PaymentMultiSelectState {
  final Payment payment;
  final List<Payment> selectedPayments;

  const PaymentDeselected({
    required this.payment,
    required this.selectedPayments,
  });

  @override
  List<Object?> get props => [payment, selectedPayments];
}

/// All payments selected state
class AllPaymentsSelected extends PaymentMultiSelectState {
  final List<Payment> selectedPayments;

  const AllPaymentsSelected({required this.selectedPayments});

  @override
  List<Object?> get props => [selectedPayments];
}

/// All payments deselected state
class AllPaymentsDeselected extends PaymentMultiSelectState {
  const AllPaymentsDeselected();
}

/// Bulk export in progress state
class BulkExportInProgress extends PaymentMultiSelectState {
  final List<Payment> selectedPayments;

  const BulkExportInProgress({required this.selectedPayments});

  @override
  List<Object?> get props => [selectedPayments];
}

/// Bulk export completed state
class BulkExportCompleted extends PaymentMultiSelectState {
  final String filePath;

  const BulkExportCompleted({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Bulk export failed state
class BulkExportFailed extends PaymentMultiSelectState {
  final String error;

  const BulkExportFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Bulk delete in progress state
class BulkDeleteInProgress extends PaymentMultiSelectState {
  const BulkDeleteInProgress();
}

/// Bulk delete completed state
class BulkDeleteCompleted extends PaymentMultiSelectState {
  final int count;

  const BulkDeleteCompleted(this.count);

  @override
  List<Object?> get props => [count];
}

/// Bulk delete failed state
class BulkDeleteFailed extends PaymentMultiSelectState {
  final String error;

  const BulkDeleteFailed({required this.error});

  @override
  List<Object?> get props => [error];
}
