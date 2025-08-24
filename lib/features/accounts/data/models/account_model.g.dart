// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
  accountId: json['accountId'] as String,
  name: json['name'] as String,
  firstNameLength: (json['firstNameLength'] as num?)?.toInt(),
  externalKey: json['externalKey'] as String,
  email: json['email'] as String,
  billCycleDayLocal: (json['billCycleDayLocal'] as num).toInt(),
  currency: json['currency'] as String,
  parentAccountId: json['parentAccountId'] as String?,
  isPaymentDelegatedToParent: json['isPaymentDelegatedToParent'] as bool,
  paymentMethodId: json['paymentMethodId'] as String?,
  referenceTime: DateTime.parse(json['referenceTime'] as String),
  timeZone: json['timeZone'] as String,
  address1: json['address1'] as String?,
  address2: json['address2'] as String?,
  postalCode: json['postalCode'] as String?,
  company: json['company'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
  locale: json['locale'] as String?,
  phone: json['phone'] as String?,
  notes: json['notes'] as String?,
  isMigrated: json['isMigrated'] as bool?,
  accountBalance: (json['accountBalance'] as num?)?.toDouble(),
  accountCBA: (json['accountCBA'] as num?)?.toDouble(),
  auditLogs:
      (json['auditLogs'] as List<dynamic>?)
          ?.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'name': instance.name,
      'firstNameLength': instance.firstNameLength,
      'externalKey': instance.externalKey,
      'email': instance.email,
      'billCycleDayLocal': instance.billCycleDayLocal,
      'currency': instance.currency,
      'parentAccountId': instance.parentAccountId,
      'isPaymentDelegatedToParent': instance.isPaymentDelegatedToParent,
      'paymentMethodId': instance.paymentMethodId,
      'referenceTime': instance.referenceTime.toIso8601String(),
      'timeZone': instance.timeZone,
      'address1': instance.address1,
      'address2': instance.address2,
      'postalCode': instance.postalCode,
      'company': instance.company,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'locale': instance.locale,
      'phone': instance.phone,
      'notes': instance.notes,
      'isMigrated': instance.isMigrated,
      'accountBalance': instance.accountBalance,
      'accountCBA': instance.accountCBA,
      'auditLogs': instance.auditLogs,
    };

AuditLogModel _$AuditLogModelFromJson(Map<String, dynamic> json) =>
    AuditLogModel(
      changeType: json['changeType'] as String,
      changeDate: DateTime.parse(json['changeDate'] as String),
      changedBy: json['changedBy'] as String,
      reasonCode: json['reasonCode'] as String,
      comments: json['comments'] as String,
      objectType: json['objectType'] as String,
      objectId: json['objectId'] as String,
      userToken: json['userToken'] as String,
    );

Map<String, dynamic> _$AuditLogModelToJson(AuditLogModel instance) =>
    <String, dynamic>{
      'changeType': instance.changeType,
      'changeDate': instance.changeDate.toIso8601String(),
      'changedBy': instance.changedBy,
      'reasonCode': instance.reasonCode,
      'comments': instance.comments,
      'objectType': instance.objectType,
      'objectId': instance.objectId,
      'userToken': instance.userToken,
    };
