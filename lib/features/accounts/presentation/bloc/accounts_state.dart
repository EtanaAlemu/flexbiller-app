import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<Account> accounts;
  final bool hasReachedMax;
  final int currentOffset;
  final int totalCount;

  const AccountsLoaded({
    required this.accounts,
    this.hasReachedMax = false,
    this.currentOffset = 0,
    this.totalCount = 0,
  });

  AccountsLoaded copyWith({
    List<Account>? accounts,
    bool? hasReachedMax,
    int? currentOffset,
    int? totalCount,
  }) {
    return AccountsLoaded(
      accounts: accounts ?? this.accounts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentOffset: currentOffset ?? this.currentOffset,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [
    accounts,
    hasReachedMax,
    currentOffset,
    totalCount,
  ];
}

class AccountsRefreshing extends AccountsState {
  final List<Account> accounts;

  const AccountsRefreshing(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountsLoadingMore extends AccountsState {
  final List<Account> accounts;

  const AccountsLoadingMore(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountsSearching extends AccountsState {
  final List<Account> accounts;
  final String query;

  const AccountsSearching(this.accounts, this.query);

  @override
  List<Object?> get props => [accounts, query];
}

class AccountsFiltered extends AccountsState {
  final List<Account> accounts;
  final String filterType;
  final String filterValue;

  const AccountsFiltered(this.accounts, this.filterType, this.filterValue);

  @override
  List<Object?> get props => [accounts, filterType, filterValue];
}

class AccountsFailure extends AccountsState {
  final String message;
  final List<Account>? previousAccounts;

  const AccountsFailure(this.message, {this.previousAccounts});

  @override
  List<Object?> get props => [message, previousAccounts];
}

class AccountDetailsLoading extends AccountsState {
  final String accountId;

  const AccountDetailsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountDetailsLoaded extends AccountsState {
  final Account account;

  const AccountDetailsLoaded(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountDetailsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountDetailsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}
