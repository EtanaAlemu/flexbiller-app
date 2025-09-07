import 'package:equatable/equatable.dart';

class AccountsQueryParams extends Equatable {
  final int offset;
  final int limit;
  final bool accountWithBalance;
  final bool accountWithBalanceAndCBA;
  final String audit;
  final String sortBy;
  final String sortOrder;

  const AccountsQueryParams({
    this.offset = 0,
    this.limit = 100,
    this.accountWithBalance = true,
    this.accountWithBalanceAndCBA = true,
    this.audit = 'FULL',
    this.sortBy = 'name',
    this.sortOrder = 'ASC',
  });

  AccountsQueryParams copyWith({
    int? offset,
    int? limit,
    bool? accountWithBalance,
    bool? accountWithBalanceAndCBA,
    String? audit,
    String? sortBy,
    String? sortOrder,
  }) {
    return AccountsQueryParams(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      accountWithBalance: accountWithBalance ?? this.accountWithBalance,
      accountWithBalanceAndCBA:
          accountWithBalanceAndCBA ?? this.accountWithBalanceAndCBA,
      audit: audit ?? this.audit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'accountWithBalance': accountWithBalance.toString(),
      'accountWithBalanceAndCBA': accountWithBalanceAndCBA.toString(),
      'audit': audit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }

  @override
  List<Object?> get props => [
    offset,
    limit,
    accountWithBalance,
    accountWithBalanceAndCBA,
    audit,
    sortBy,
    sortOrder,
  ];

  @override
  String toString() {
    return 'AccountsQueryParams(offset: $offset, limit: $limit, accountWithBalance: $accountWithBalance, accountWithBalanceAndCBA: $accountWithBalanceAndCBA, audit: $audit, sortBy: $sortBy, sortOrder: $sortOrder)';
  }
}
