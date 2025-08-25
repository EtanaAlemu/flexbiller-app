// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountPaymentMethodModel _$AccountPaymentMethodModelFromJson(
  Map<String, dynamic> json,
) => AccountPaymentMethodModel(
  id: json['paymentMethodId'] as String,
  accountId: json['accountId'] as String,
  externalKey: json['externalKey'] as String?,
  pluginName: json['pluginName'] as String?,
  pluginInfo: json['pluginInfo'] as Map<String, dynamic>?,
  isDefault: json['isDefault'] as bool,
  auditLogs: (json['auditLogs'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  paymentMethodType: json['paymentMethodType'] as String?,
  paymentMethodName: json['paymentMethodName'] as String?,
  cardLastFourDigits: json['cardLastFourDigits'] as String?,
  cardBrand: json['cardBrand'] as String?,
  cardExpiryMonth: json['cardExpiryMonth'] as String?,
  cardExpiryYear: json['cardExpiryYear'] as String?,
  bankName: json['bankName'] as String?,
  bankAccountLastFourDigits: json['bankAccountLastFourDigits'] as String?,
  bankAccountType: json['bankAccountType'] as String?,
  paypalEmail: json['paypalEmail'] as String?,
  isActive: json['isActive'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AccountPaymentMethodModelToJson(
  AccountPaymentMethodModel instance,
) => <String, dynamic>{
  'paymentMethodId': instance.id,
  'accountId': instance.accountId,
  'externalKey': instance.externalKey,
  'pluginName': instance.pluginName,
  'pluginInfo': instance.pluginInfo,
  'isDefault': instance.isDefault,
  'auditLogs': instance.auditLogs,
  'paymentMethodType': instance.paymentMethodType,
  'paymentMethodName': instance.paymentMethodName,
  'cardLastFourDigits': instance.cardLastFourDigits,
  'cardBrand': instance.cardBrand,
  'cardExpiryMonth': instance.cardExpiryMonth,
  'cardExpiryYear': instance.cardExpiryYear,
  'bankName': instance.bankName,
  'bankAccountLastFourDigits': instance.bankAccountLastFourDigits,
  'bankAccountType': instance.bankAccountType,
  'paypalEmail': instance.paypalEmail,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'metadata': instance.metadata,
};
