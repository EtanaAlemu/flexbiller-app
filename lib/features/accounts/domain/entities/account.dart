import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String accountId;
  final String name;
  final int? firstNameLength;
  final String externalKey;
  final String email;
  final int billCycleDayLocal;
  final String currency;
  final String? parentAccountId;
  final bool isPaymentDelegatedToParent;
  final String? paymentMethodId;
  final DateTime referenceTime;
  final String timeZone;
  final String? address1;
  final String? address2;
  final String? postalCode;
  final String? company;
  final String? city;
  final String? state;
  final String? country;
  final String? locale;
  final String? phone;
  final String? notes;
  final bool? isMigrated;
  final double? accountBalance;
  final double? accountCBA;
  final List<AuditLog> auditLogs;

  const Account({
    required this.accountId,
    required this.name,
    this.firstNameLength,
    required this.externalKey,
    required this.email,
    required this.billCycleDayLocal,
    required this.currency,
    this.parentAccountId,
    required this.isPaymentDelegatedToParent,
    this.paymentMethodId,
    required this.referenceTime,
    required this.timeZone,
    this.address1,
    this.address2,
    this.postalCode,
    this.company,
    this.city,
    this.state,
    this.country,
    this.locale,
    this.phone,
    this.notes,
    this.isMigrated,
    this.accountBalance,
    this.accountCBA,
    this.auditLogs = const [],
  });

  @override
  List<Object?> get props => [
    accountId,
    name,
    firstNameLength,
    externalKey,
    email,
    billCycleDayLocal,
    currency,
    parentAccountId,
    isPaymentDelegatedToParent,
    paymentMethodId,
    referenceTime,
    timeZone,
    address1,
    address2,
    postalCode,
    company,
    city,
    state,
    country,
    locale,
    phone,
    notes,
    isMigrated,
    accountBalance,
    accountCBA,
    auditLogs,
  ];

  @override
  String toString() {
    return 'Account(accountId: $accountId, name: $name, email: $email, company: $company, accountBalance: $accountBalance)';
  }

  // Helper methods
  String get fullAddress {
    final parts = [
      address1,
      address2,
      city,
      state,
      country,
    ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.join(', ');
  }

  String get displayName => name.isNotEmpty ? name : email;

  bool get hasBalance => accountBalance != null && accountBalance != 0;
  bool get hasCba => accountCBA != null && accountCBA != 0;

  String get formattedBalance => accountBalance != null
      ? '\$${accountBalance!.toStringAsFixed(2)}'
      : 'N/A';
  String get formattedCba =>
      accountCBA != null ? '\$${accountCBA!.toStringAsFixed(2)}' : 'N/A';

  // Legacy getter for backward compatibility
  String get id => accountId;
  double get balance => accountBalance ?? 0.0;
  double get cba => accountCBA ?? 0.0;

  Account copyWith({
    String? accountId,
    String? name,
    int? firstNameLength,
    String? externalKey,
    String? email,
    int? billCycleDayLocal,
    String? currency,
    String? parentAccountId,
    bool? isPaymentDelegatedToParent,
    String? paymentMethodId,
    DateTime? referenceTime,
    String? timeZone,
    String? address1,
    String? address2,
    String? postalCode,
    String? company,
    String? city,
    String? state,
    String? country,
    String? locale,
    String? phone,
    String? notes,
    bool? isMigrated,
    double? accountBalance,
    double? accountCBA,
    List<AuditLog>? auditLogs,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      firstNameLength: firstNameLength ?? this.firstNameLength,
      externalKey: externalKey ?? this.externalKey,
      email: email ?? this.email,
      billCycleDayLocal: billCycleDayLocal ?? this.billCycleDayLocal,
      currency: currency ?? this.currency,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      isPaymentDelegatedToParent:
          isPaymentDelegatedToParent ?? this.isPaymentDelegatedToParent,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      referenceTime: referenceTime ?? this.referenceTime,
      timeZone: timeZone ?? this.timeZone,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      postalCode: postalCode ?? this.postalCode,
      company: company ?? this.company,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      locale: locale ?? this.locale,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      isMigrated: isMigrated ?? this.isMigrated,
      accountBalance: accountBalance ?? this.accountBalance,
      accountCBA: accountCBA ?? this.accountCBA,
      auditLogs: auditLogs ?? this.auditLogs,
    );
  }
}

class AuditLog extends Equatable {
  final String changeType;
  final DateTime changeDate;
  final String changedBy;
  final String? reasonCode;
  final String? comments;
  final String objectType;
  final String objectId;
  final String userToken;

  const AuditLog({
    required this.changeType,
    required this.changeDate,
    required this.changedBy,
    this.reasonCode,
    this.comments,
    required this.objectType,
    required this.objectId,
    required this.userToken,
  });

  @override
  List<Object?> get props => [
    changeType,
    changeDate,
    changedBy,
    reasonCode,
    comments,
    objectType,
    objectId,
    userToken,
  ];

  @override
  String toString() {
    return 'AuditLog(changeType: $changeType, changeDate: $changeDate, changedBy: $changedBy)';
  }
}
