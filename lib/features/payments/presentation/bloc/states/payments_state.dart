part of '../payments_bloc.dart';

abstract class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class PaymentsRefreshing extends PaymentsState {
  final List<Payment> payments;

  const PaymentsRefreshing(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentsLoaded extends PaymentsState {
  final List<Payment> payments;

  const PaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentsError extends PaymentsState {
  final String message;

  const PaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentsEmpty extends PaymentsState {
  final String message;

  const PaymentsEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentLoading extends PaymentsState {}

class PaymentLoaded extends PaymentsState {
  final Payment payment;

  const PaymentLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentError extends PaymentsState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
