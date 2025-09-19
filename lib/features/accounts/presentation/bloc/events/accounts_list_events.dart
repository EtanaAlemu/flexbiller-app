import 'package:equatable/equatable.dart';
import '../../../domain/entities/accounts_query_params.dart';

/// Base class for accounts list events
abstract class ListAccountsEvent extends Equatable {
  const ListAccountsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load accounts with query parameters
class LoadAccounts extends ListAccountsEvent {
  final AccountsQueryParams params;

  const LoadAccounts(this.params);

  @override
  List<Object?> get props => [params];
}

/// Event to get all accounts
class GetAllAccounts extends ListAccountsEvent {
  const GetAllAccounts();
}

/// Event to refresh all accounts
class RefreshAllAccounts extends ListAccountsEvent {
  const RefreshAllAccounts();
}

/// Event to search accounts
class SearchAccounts extends ListAccountsEvent {
  final String searchKey;

  const SearchAccounts(this.searchKey);

  @override
  List<Object?> get props => [searchKey];
}

/// Event to refresh accounts
class RefreshAccounts extends ListAccountsEvent {
  const RefreshAccounts();
}

/// Event to load more accounts (pagination)
class LoadMoreAccounts extends ListAccountsEvent {
  const LoadMoreAccounts();
}

/// Event to filter accounts by company
class FilterAccountsByCompany extends ListAccountsEvent {
  final String company;

  const FilterAccountsByCompany(this.company);

  @override
  List<Object?> get props => [company];
}

/// Event to filter accounts by balance range
class FilterAccountsByBalance extends ListAccountsEvent {
  final double minBalance;
  final double maxBalance;

  const FilterAccountsByBalance({
    required this.minBalance,
    required this.maxBalance,
  });

  @override
  List<Object?> get props => [minBalance, maxBalance];
}

class SortAccounts extends ListAccountsEvent {
  final String sortBy;
  final String sortOrder;

  const SortAccounts(this.sortBy, this.sortOrder);

  @override
  List<Object?> get props => [sortBy, sortOrder];
}

class ClearAccountsFilters extends ListAccountsEvent {
  const ClearAccountsFilters();

  @override
  List<Object?> get props => [];
}

/// Event to filter accounts by audit level
class FilterAccountsByAuditLevel extends ListAccountsEvent {
  final String auditLevel;

  const FilterAccountsByAuditLevel(this.auditLevel);

  @override
  List<Object?> get props => [auditLevel];
}

/// Event to clear all filters
class ClearFilters extends ListAccountsEvent {
  const ClearFilters();
}
