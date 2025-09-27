import 'package:equatable/equatable.dart';
import '../../../domain/entities/account_payment_method.dart';

abstract class AccountPaymentMethodsState extends Equatable {
  final String accountId;

  const AccountPaymentMethodsState(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class AccountPaymentMethodsInitial extends AccountPaymentMethodsState {
  const AccountPaymentMethodsInitial(String accountId) : super(accountId);
}

class AccountPaymentMethodsLoading extends AccountPaymentMethodsState {
  const AccountPaymentMethodsLoading(String accountId) : super(accountId);
}

class AccountPaymentMethodsLoaded extends AccountPaymentMethodsState {
  final List<AccountPaymentMethod> paymentMethods;

  const AccountPaymentMethodsLoaded({
    required String accountId,
    required this.paymentMethods,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethods];
}

class AccountPaymentMethodsFailure extends AccountPaymentMethodsState {
  final String message;

  const AccountPaymentMethodsFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class PaymentMethodCreating extends AccountPaymentMethodsState {
  const PaymentMethodCreating(String accountId) : super(accountId);
}

class PaymentMethodCreated extends AccountPaymentMethodsState {
  final AccountPaymentMethod paymentMethod;

  const PaymentMethodCreated({
    required String accountId,
    required this.paymentMethod,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethod];
}

class PaymentMethodCreationFailure extends AccountPaymentMethodsState {
  final String message;

  const PaymentMethodCreationFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class PaymentMethodUpdating extends AccountPaymentMethodsState {
  final String paymentMethodId;

  const PaymentMethodUpdating({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class PaymentMethodUpdated extends AccountPaymentMethodsState {
  final AccountPaymentMethod paymentMethod;

  const PaymentMethodUpdated({
    required String accountId,
    required this.paymentMethod,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethod];
}

class PaymentMethodUpdateFailure extends AccountPaymentMethodsState {
  final String paymentMethodId;
  final String message;

  const PaymentMethodUpdateFailure({
    required String accountId,
    required this.paymentMethodId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId, message];
}

class PaymentMethodDeleting extends AccountPaymentMethodsState {
  final String paymentMethodId;

  const PaymentMethodDeleting({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class PaymentMethodDeleted extends AccountPaymentMethodsState {
  final String paymentMethodId;

  const PaymentMethodDeleted({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class PaymentMethodDeletionFailure extends AccountPaymentMethodsState {
  final String paymentMethodId;
  final String message;

  const PaymentMethodDeletionFailure({
    required String accountId,
    required this.paymentMethodId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId, message];
}

class PaymentMethodDeactivating extends AccountPaymentMethodsState {
  final String paymentMethodId;

  const PaymentMethodDeactivating({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class PaymentMethodDeactivated extends AccountPaymentMethodsState {
  final AccountPaymentMethod paymentMethod;

  const PaymentMethodDeactivated({
    required String accountId,
    required this.paymentMethod,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethod];
}

class PaymentMethodDeactivationFailure extends AccountPaymentMethodsState {
  final String paymentMethodId;
  final String message;

  const PaymentMethodDeactivationFailure({
    required String accountId,
    required this.paymentMethodId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId, message];
}

class PaymentMethodReactivating extends AccountPaymentMethodsState {
  final String paymentMethodId;

  const PaymentMethodReactivating({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class PaymentMethodReactivated extends AccountPaymentMethodsState {
  final AccountPaymentMethod paymentMethod;

  const PaymentMethodReactivated({
    required String accountId,
    required this.paymentMethod,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethod];
}

class PaymentMethodReactivationFailure extends AccountPaymentMethodsState {
  final String paymentMethodId;
  final String message;

  const PaymentMethodReactivationFailure({
    required String accountId,
    required this.paymentMethodId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId, message];
}

class DefaultPaymentMethodSetting extends AccountPaymentMethodsState {
  final String paymentMethodId;

  const DefaultPaymentMethodSetting({
    required String accountId,
    required this.paymentMethodId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId];
}

class DefaultPaymentMethodSet extends AccountPaymentMethodsState {
  final AccountPaymentMethod paymentMethod;

  const DefaultPaymentMethodSet({
    required String accountId,
    required this.paymentMethod,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethod];
}

class DefaultPaymentMethodSetFailure extends AccountPaymentMethodsState {
  final String paymentMethodId;
  final String message;

  const DefaultPaymentMethodSetFailure({
    required String accountId,
    required this.paymentMethodId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethodId, message];
}

class PaymentMethodsSyncing extends AccountPaymentMethodsState {
  const PaymentMethodsSyncing(String accountId) : super(accountId);
}

class PaymentMethodsSynced extends AccountPaymentMethodsState {
  final List<AccountPaymentMethod> paymentMethods;

  const PaymentMethodsSynced({
    required String accountId,
    required this.paymentMethods,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, paymentMethods];
}

class PaymentMethodsSyncFailure extends AccountPaymentMethodsState {
  final String message;

  const PaymentMethodsSyncFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}
