import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String name;
  final String email;
  final String currency;
  final String timeZone;
  final String address1;
  final String address2;
  final String company;
  final String city;
  final String state;
  final String country;
  final String phone;
  final String notes;
  final String externalKey;
  final double balance;
  final double cba;
  final List<AuditLog> auditLogs;

  const Account({
    required this.id,
    required this.name,
    required this.email,
    required this.currency,
    required this.timeZone,
    required this.address1,
    required this.address2,
    required this.company,
    required this.city,
    required this.state,
    required this.country,
    required this.phone,
    required this.notes,
    required this.externalKey,
    required this.balance,
    required this.cba,
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    currency,
    timeZone,
    address1,
    address2,
    company,
    city,
    state,
    country,
    phone,
    notes,
    externalKey,
    balance,
    cba,
    auditLogs,
  ];

  @override
  String toString() {
    return 'Account(id: $id, name: $name, email: $email, company: $company, balance: $balance)';
  }

  // Helper methods
  String get fullAddress {
    final parts = [
      address1,
      address2,
      city,
      state,
      country,
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  String get displayName => name.isNotEmpty ? name : email;

  bool get hasBalance => balance != 0;
  bool get hasCba => cba != 0;

  String get formattedBalance => '\$${balance.toStringAsFixed(2)}';
  String get formattedCba => '\$${cba.toStringAsFixed(2)}';
}

class AuditLog extends Equatable {
  final String changeType;
  final DateTime changeDate;
  final String changedBy;
  final String reasonCode;
  final String comments;
  final String objectType;
  final String objectId;
  final String userToken;

  const AuditLog({
    required this.changeType,
    required this.changeDate,
    required this.changedBy,
    required this.reasonCode,
    required this.comments,
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
