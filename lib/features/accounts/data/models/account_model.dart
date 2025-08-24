import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account.dart';

part 'account_model.g.dart';

@JsonSerializable()
class AccountModel {
  @JsonKey(name: 'accountId')
  final String accountId;
  final String name;
  @JsonKey(name: 'firstNameLength')
  final int? firstNameLength;
  @JsonKey(name: 'externalKey')
  final String externalKey;
  final String email;
  @JsonKey(name: 'billCycleDayLocal')
  final int billCycleDayLocal;
  final String currency;
  @JsonKey(name: 'parentAccountId')
  final String? parentAccountId;
  @JsonKey(name: 'isPaymentDelegatedToParent')
  final bool isPaymentDelegatedToParent;
  @JsonKey(name: 'paymentMethodId')
  final String? paymentMethodId;
  @JsonKey(name: 'referenceTime')
  final DateTime referenceTime;
  @JsonKey(name: 'timeZone')
  final String timeZone;
  final String? address1;
  final String? address2;
  @JsonKey(name: 'postalCode')
  final String? postalCode;
  final String? company;
  final String? city;
  final String? state;
  final String? country;
  final String? locale;
  final String? phone;
  final String? notes;
  @JsonKey(name: 'isMigrated')
  final bool? isMigrated;
  @JsonKey(name: 'accountBalance')
  final double? accountBalance;
  @JsonKey(name: 'accountCBA')
  final double? accountCBA;
  @JsonKey(name: 'auditLogs')
  final List<AuditLogModel> auditLogs;

  AccountModel({
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

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);
  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  Account toEntity() {
    return Account(
      accountId: accountId,
      name: name,
      firstNameLength: firstNameLength,
      externalKey: externalKey,
      email: email,
      billCycleDayLocal: billCycleDayLocal,
      currency: currency,
      parentAccountId: parentAccountId,
      isPaymentDelegatedToParent: isPaymentDelegatedToParent,
      paymentMethodId: paymentMethodId,
      referenceTime: referenceTime,
      timeZone: timeZone,
      address1: address1,
      address2: address2,
      postalCode: postalCode,
      company: company,
      city: city,
      state: state,
      country: country,
      locale: locale,
      phone: phone,
      notes: notes,
      isMigrated: isMigrated,
      accountBalance: accountBalance,
      accountCBA: accountCBA,
      auditLogs: auditLogs.map((log) => log.toEntity()).toList(),
    );
  }

  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      accountId: account.accountId,
      name: account.name,
      firstNameLength: account.firstNameLength,
      externalKey: account.externalKey,
      email: account.email,
      billCycleDayLocal: account.billCycleDayLocal,
      currency: account.currency,
      parentAccountId: account.parentAccountId,
      isPaymentDelegatedToParent: account.isPaymentDelegatedToParent,
      paymentMethodId: account.paymentMethodId,
      referenceTime: account.referenceTime,
      timeZone: account.timeZone,
      address1: account.address1,
      address2: account.address2,
      postalCode: account.postalCode,
      company: account.company,
      city: account.city,
      state: account.state,
      country: account.country,
      locale: account.locale,
      phone: account.phone,
      notes: account.notes,
      isMigrated: account.isMigrated,
      accountBalance: account.accountBalance,
      accountCBA: account.accountCBA,
      auditLogs: account.auditLogs
          .map((log) => AuditLogModel.fromEntity(log))
          .toList(),
    );
  }
}

@JsonSerializable()
class AuditLogModel {
  @JsonKey(name: 'changeType')
  final String changeType;
  @JsonKey(name: 'changeDate')
  final DateTime changeDate;
  @JsonKey(name: 'changedBy')
  final String changedBy;
  @JsonKey(name: 'reasonCode')
  final String reasonCode;
  final String comments;
  @JsonKey(name: 'objectType')
  final String objectType;
  @JsonKey(name: 'objectId')
  final String objectId;
  @JsonKey(name: 'userToken')
  final String userToken;

  AuditLogModel({
    required this.changeType,
    required this.changeDate,
    required this.changedBy,
    required this.reasonCode,
    required this.comments,
    required this.objectType,
    required this.objectId,
    required this.userToken,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$AuditLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuditLogModelToJson(this);

  AuditLog toEntity() {
    return AuditLog(
      changeType: changeType,
      changeDate: changeDate,
      changedBy: changedBy,
      reasonCode: reasonCode,
      comments: comments,
      objectType: objectType,
      objectId: objectId,
      userToken: userToken,
    );
  }

  factory AuditLogModel.fromEntity(AuditLog auditLog) {
    return AuditLogModel(
      changeType: auditLog.changeType,
      changeDate: auditLog.changeDate,
      changedBy: auditLog.changedBy,
      reasonCode: auditLog.reasonCode,
      comments: auditLog.comments,
      objectType: auditLog.objectType,
      objectId: auditLog.objectId,
      userToken: auditLog.userToken,
    );
  }
}
