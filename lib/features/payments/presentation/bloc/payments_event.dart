part of 'payments_bloc.dart';

abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();

  @override
  List<Object?> get props => [];
}

class GetPaymentsEvent extends PaymentsEvent {
  const GetPaymentsEvent();
}

class GetPaymentByIdEvent extends PaymentsEvent {
  final String paymentId;

  const GetPaymentByIdEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class GetPaymentsByAccountIdEvent extends PaymentsEvent {
  final String accountId;

  const GetPaymentsByAccountIdEvent(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshPaymentsEvent extends PaymentsEvent {
  const RefreshPaymentsEvent();
}
