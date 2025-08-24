// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  currency: json['currency'] as String,
  timeZone: json['timeZone'] as String,
  address1: json['address1'] as String,
  address2: json['address2'] as String,
  company: json['company'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  country: json['country'] as String,
  phone: json['phone'] as String,
  notes: json['notes'] as String,
  externalKey: json['externalKey'] as String,
  balance: (json['balance'] as num).toDouble(),
  cba: (json['cba'] as num).toDouble(),
  auditLogs: (json['auditLogs'] as List<dynamic>)
      .map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'currency': instance.currency,
      'timeZone': instance.timeZone,
      'address1': instance.address1,
      'address2': instance.address2,
      'company': instance.company,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'phone': instance.phone,
      'notes': instance.notes,
      'externalKey': instance.externalKey,
      'balance': instance.balance,
      'cba': instance.cba,
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
