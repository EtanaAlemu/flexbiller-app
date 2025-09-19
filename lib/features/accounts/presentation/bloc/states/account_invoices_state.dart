import 'package:equatable/equatable.dart';
import '../../../domain/entities/account_invoice.dart';

abstract class AccountInvoicesState extends Equatable {
  const AccountInvoicesState();

  @override
  List<Object?> get props => [];
}

class AccountInvoicesInitial extends AccountInvoicesState {}

class AccountInvoicesLoading extends AccountInvoicesState {
  final String accountId;

  const AccountInvoicesLoading({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}

class AccountInvoicesLoaded extends AccountInvoicesState {
  final String accountId;
  final List<AccountInvoice> invoices;

  const AccountInvoicesLoaded({
    required this.accountId,
    required this.invoices,
  });

  @override
  List<Object?> get props => [accountId, invoices];
}

class AccountInvoicesFailure extends AccountInvoicesState {
  final String message;
  final String accountId;

  const AccountInvoicesFailure({
    required this.message,
    required this.accountId,
  });

  @override
  List<Object?> get props => [message, accountId];
}

class AccountInvoicesRefreshing extends AccountInvoicesState {
  final String accountId;
  final List<AccountInvoice> invoices;

  const AccountInvoicesRefreshing({
    required this.accountId,
    required this.invoices,
  });

  @override
  List<Object?> get props => [accountId, invoices];
}
