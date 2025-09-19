import 'package:equatable/equatable.dart';

class AccountsQueryParams extends Equatable {
  final int offset;
  final int limit;
  final bool accountWithBalance;
  final bool accountWithBalanceAndCBA;
  final String audit;
  final String sortBy;
  final String sortOrder;
  final String? company;
  final double? minBalance;
  final double? maxBalance;

  const AccountsQueryParams({
    this.offset = 0,
    this.limit = 100,
    this.accountWithBalance = true,
    this.accountWithBalanceAndCBA = true,
    this.audit = 'FULL',
    this.sortBy = 'name',
    this.sortOrder = 'ASC',
    this.company,
    this.minBalance,
    this.maxBalance,
  });

  AccountsQueryParams copyWith({
    int? offset,
    int? limit,
    bool? accountWithBalance,
    bool? accountWithBalanceAndCBA,
    String? audit,
    String? sortBy,
    String? sortOrder,
    String? company,
    double? minBalance,
    double? maxBalance,
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
      company: company ?? this.company,
      minBalance: minBalance ?? this.minBalance,
      maxBalance: maxBalance ?? this.maxBalance,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'offset': offset.toString(),
      'limit': limit.toString(),
      'accountWithBalance': accountWithBalance.toString(),
      'accountWithBalanceAndCBA': accountWithBalanceAndCBA.toString(),
      'audit': audit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (company != null) params['company'] = company!;
    if (minBalance != null) params['minBalance'] = minBalance!.toString();
    if (maxBalance != null) params['maxBalance'] = maxBalance!.toString();

    return params;
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
    company,
    minBalance,
    maxBalance,
  ];

  @override
  String toString() {
    return 'AccountsQueryParams(offset: $offset, limit: $limit, accountWithBalance: $accountWithBalance, accountWithBalanceAndCBA: $accountWithBalanceAndCBA, audit: $audit, sortBy: $sortBy, sortOrder: $sortOrder, company: $company, minBalance: $minBalance, maxBalance: $maxBalance)';
  }
}
