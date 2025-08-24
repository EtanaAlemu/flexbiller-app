import 'package:equatable/equatable.dart';
import '../../domain/entities/accounts_query_params.dart';

abstract class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountsEvent {
  final AccountsQueryParams params;

  const LoadAccounts({this.params = const AccountsQueryParams()});

  @override
  List<Object?> get props => [params];
}

class RefreshAccounts extends AccountsEvent {
  final AccountsQueryParams params;

  const RefreshAccounts({this.params = const AccountsQueryParams()});

  @override
  List<Object?> get props => [params];
}

class LoadMoreAccounts extends AccountsEvent {
  final int offset;
  final int limit;

  const LoadMoreAccounts({required this.offset, this.limit = 20});

  @override
  List<Object?> get props => [offset, limit];
}

class SearchAccounts extends AccountsEvent {
  final String query;

  const SearchAccounts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterAccountsByCompany extends AccountsEvent {
  final String company;

  const FilterAccountsByCompany(this.company);

  @override
  List<Object?> get props => [company];
}

class FilterAccountsByBalance extends AccountsEvent {
  final double minBalance;

  const FilterAccountsByBalance(this.minBalance);

  @override
  List<Object?> get props => [minBalance];
}

class ClearFilters extends AccountsEvent {}

class LoadAccountDetails extends AccountsEvent {
  final String accountId;

  const LoadAccountDetails(this.accountId);

  @override
  List<Object?> get props => [accountId];
}
