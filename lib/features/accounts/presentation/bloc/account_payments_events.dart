import 'package:equatable/equatable.dart';

abstract class AccountPaymentsEvent extends Equatable {
  const AccountPaymentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccountPayments extends AccountPaymentsEvent {
  final String accountId;

  const LoadAccountPayments(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountPayments extends AccountPaymentsEvent {
  final String accountId;

  const RefreshAccountPayments(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefundAccountPayment extends AccountPaymentsEvent {
  final String accountId;
  final String paymentId;
  final double refundAmount;
  final String reason;

  const RefundAccountPayment({
    required this.accountId,
    required this.paymentId,
    required this.refundAmount,
    required this.reason,
  });

  @override
  List<Object?> get props => [accountId, paymentId, refundAmount, reason];
}

class ClearAccountPayments extends AccountPaymentsEvent {
  const ClearAccountPayments();
}
