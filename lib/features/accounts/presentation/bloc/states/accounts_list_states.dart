import 'package:equatable/equatable.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/accounts_query_params.dart';

/// Base class for accounts list states
abstract class AccountsListState extends Equatable {
  const AccountsListState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AccountsListInitial extends AccountsListState {
  const AccountsListInitial();
}

/// Loading state for accounts list
class AccountsListLoading extends AccountsListState {
  final AccountsQueryParams params;

  const AccountsListLoading(this.params);

  @override
  List<Object?> get props => [params];
}

/// Loaded state for accounts list
class AccountsListLoaded extends AccountsListState {
  final List<Account> accounts;
  final int currentOffset;
  final int totalCount;
  final bool hasReachedMax;

  const AccountsListLoaded({
    required this.accounts,
    required this.currentOffset,
    required this.totalCount,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [
    accounts,
    currentOffset,
    totalCount,
    hasReachedMax,
  ];
}

/// Failure state for accounts list
class AccountsListFailure extends AccountsListState {
  final String message;
  final List<Account>? previousAccounts;

  const AccountsListFailure(this.message, {this.previousAccounts});

  @override
  List<Object?> get props => [message, previousAccounts];
}

/// Loading state for all accounts
class GetAllAccountsLoading extends AccountsListState {
  const GetAllAccountsLoading();
}

/// Loaded state for all accounts
class AllAccountsLoaded extends AccountsListState {
  final List<Account> accounts;
  final int totalCount;

  const AllAccountsLoaded({required this.accounts, required this.totalCount});

  @override
  List<Object?> get props => [accounts, totalCount];
}

/// Refreshing state for all accounts
class AllAccountsRefreshing extends AccountsListState {
  const AllAccountsRefreshing();
}

/// Filtered state for accounts
class AccountsFiltered extends AccountsListState {
  final List<Account> accounts;
  final String filterType;
  final String filterValue;

  const AccountsFiltered(this.accounts, this.filterType, this.filterValue);

  @override
  List<Object?> get props => [accounts, filterType, filterValue];
}
