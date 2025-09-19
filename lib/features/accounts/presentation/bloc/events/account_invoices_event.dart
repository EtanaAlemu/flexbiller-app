import 'package:equatable/equatable.dart';

abstract class AccountInvoicesEvent extends Equatable {
  const AccountInvoicesEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccountInvoices extends AccountInvoicesEvent {
  final String accountId;

  const LoadAccountInvoices({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountInvoices extends AccountInvoicesEvent {
  final String accountId;

  const RefreshAccountInvoices({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}
