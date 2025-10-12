part of '../invoices_bloc.dart';

abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();

  @override
  List<Object?> get props => [];
}

class GetInvoicesEvent extends InvoicesEvent {
  const GetInvoicesEvent();
}

class RefreshInvoicesEvent extends InvoicesEvent {
  const RefreshInvoicesEvent();
}

class SearchInvoicesEvent extends InvoicesEvent {
  final String searchKey;

  const SearchInvoicesEvent(this.searchKey);

  @override
  List<Object?> get props => [searchKey];
}
