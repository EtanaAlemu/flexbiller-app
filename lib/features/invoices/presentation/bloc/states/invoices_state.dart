part of '../invoices_bloc.dart';

abstract class InvoicesState extends Equatable {
  const InvoicesState();

  @override
  List<Object?> get props => [];
}

class InvoicesInitial extends InvoicesState {}

class InvoicesLoading extends InvoicesState {}

class InvoicesRefreshing extends InvoicesState {
  final List<Invoice> invoices;

  const InvoicesRefreshing(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoicesLoaded extends InvoicesState {
  final List<Invoice> invoices;

  const InvoicesLoaded(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoicesError extends InvoicesState {
  final String message;

  const InvoicesError(this.message);

  @override
  List<Object?> get props => [message];
}

class InvoicesEmpty extends InvoicesState {
  final String message;

  const InvoicesEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

