import 'package:equatable/equatable.dart';
import '../../domain/entities/account_payment.dart';

abstract class AccountPaymentsState extends Equatable {
  const AccountPaymentsState();

  @override
  List<Object?> get props => [];
}

class AccountPaymentsInitial extends AccountPaymentsState {
  const AccountPaymentsInitial();
}

class AccountPaymentsLoading extends AccountPaymentsState {
  final String accountId;

  const AccountPaymentsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountPaymentsLoaded extends AccountPaymentsState {
  final String accountId;
  final List<AccountPayment> payments;

  const AccountPaymentsLoaded({
    required this.accountId,
    required this.payments,
  });

  @override
  List<Object?> get props => [accountId, payments];
}

class AccountPaymentsFailure extends AccountPaymentsState {
  final String accountId;
  final String message;

  const AccountPaymentsFailure({
    required this.accountId,
    required this.message,
  });

  @override
  List<Object?> get props => [accountId, message];
}

class AccountPaymentRefunding extends AccountPaymentsState {
  final String accountId;
  final String paymentId;

  const AccountPaymentRefunding({
    required this.accountId,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [accountId, paymentId];
}

class AccountPaymentRefunded extends AccountPaymentsState {
  final String accountId;
  final String paymentId;

  const AccountPaymentRefunded({
    required this.accountId,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [accountId, paymentId];
}

class AccountPaymentRefundFailure extends AccountPaymentsState {
  final String accountId;
  final String paymentId;
  final String message;

  const AccountPaymentRefundFailure({
    required this.accountId,
    required this.paymentId,
    required this.message,
  });

  @override
  List<Object?> get props => [accountId, paymentId, message];
}
