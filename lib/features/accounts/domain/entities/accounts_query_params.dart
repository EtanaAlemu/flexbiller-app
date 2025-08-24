import 'package:equatable/equatable.dart';

class AccountsQueryParams extends Equatable {
  final int offset;
  final int limit;
  final bool accountWithBalance;
  final bool accountWithBalanceAndCBA;
  final String audit;

  const AccountsQueryParams({
    this.offset = 0,
    this.limit = 100,
    this.accountWithBalance = true,
    this.accountWithBalanceAndCBA = true,
    this.audit = 'FULL',
  });

  AccountsQueryParams copyWith({
    int? offset,
    int? limit,
    bool? accountWithBalance,
    bool? accountWithBalanceAndCBA,
    String? audit,
  }) {
    return AccountsQueryParams(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      accountWithBalance: accountWithBalance ?? this.accountWithBalance,
      accountWithBalanceAndCBA:
          accountWithBalanceAndCBA ?? this.accountWithBalanceAndCBA,
      audit: audit ?? this.audit,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'offset': offset.toString(),
      'limit': limit.toString(),
      'accountWithBalance': accountWithBalance.toString(),
      'accountWithBalanceAndCBA': accountWithBalanceAndCBA.toString(),
      'audit': audit,
    };
  }

  @override
  List<Object?> get props => [
    offset,
    limit,
    accountWithBalance,
    accountWithBalanceAndCBA,
    audit,
  ];

  @override
  String toString() {
    return 'AccountsQueryParams(offset: $offset, limit: $limit, accountWithBalance: $accountWithBalance, accountWithBalanceAndCBA: $accountWithBalanceAndCBA, audit: $audit)';
  }
}
