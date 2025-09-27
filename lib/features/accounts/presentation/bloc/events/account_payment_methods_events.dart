import 'package:equatable/equatable.dart';

abstract class AccountPaymentMethodsEvent extends Equatable {
  final String accountId;

  const AccountPaymentMethodsEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class LoadAccountPaymentMethods extends AccountPaymentMethodsEvent {
  const LoadAccountPaymentMethods(String accountId) : super(accountId);
}

class RefreshAccountPaymentMethods extends AccountPaymentMethodsEvent {
  const RefreshAccountPaymentMethods(String accountId) : super(accountId);
}

class SetDefaultPaymentMethod extends AccountPaymentMethodsEvent {
  final String paymentMethodId;
  final bool payAllUnpaidInvoices;

  const SetDefaultPaymentMethod({
    required String accountId,
    required this.paymentMethodId,
    required this.payAllUnpaidInvoices,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId, payAllUnpaidInvoices];
}

class CreatePaymentMethod extends AccountPaymentMethodsEvent {
  final String paymentMethodType;
  final String paymentMethodName;
  final Map<String, dynamic> paymentDetails;

  const CreatePaymentMethod({
    required String accountId,
    required this.paymentMethodType,
    required this.paymentMethodName,
    required this.paymentDetails,
  }) : super(accountId);

  @override
  List<Object> get props => [
    accountId,
    paymentMethodType,
    paymentMethodName,
    paymentDetails,
  ];
}

class UpdatePaymentMethod extends AccountPaymentMethodsEvent {
  final String paymentMethodId;
  final Map<String, dynamic> updates;

  const UpdatePaymentMethod({
    required String accountId,
    required this.paymentMethodId,
    required this.updates,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId, updates];
}

class DeletePaymentMethod extends AccountPaymentMethodsEvent {
  final String paymentMethodId;

  const DeletePaymentMethod({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class DeactivatePaymentMethod extends AccountPaymentMethodsEvent {
  final String paymentMethodId;

  const DeactivatePaymentMethod({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class ReactivatePaymentMethod extends AccountPaymentMethodsEvent {
  final String paymentMethodId;

  const ReactivatePaymentMethod({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class SyncPaymentMethods extends AccountPaymentMethodsEvent {
  const SyncPaymentMethods(String accountId) : super(accountId);
}

class ClearAccountPaymentMethods extends AccountPaymentMethodsEvent {
  const ClearAccountPaymentMethods(String accountId) : super(accountId);
}
