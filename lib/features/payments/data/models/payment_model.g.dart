// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  accountId: json['accountId'] as String,
  paymentId: json['paymentId'] as String,
  paymentNumber: json['paymentNumber'] as String,
  paymentExternalKey: json['paymentExternalKey'] as String,
  authAmount: (json['authAmount'] as num).toDouble(),
  capturedAmount: (json['capturedAmount'] as num).toDouble(),
  purchasedAmount: (json['purchasedAmount'] as num).toDouble(),
  refundedAmount: (json['refundedAmount'] as num).toDouble(),
  creditedAmount: (json['creditedAmount'] as num).toDouble(),
  currency: json['currency'] as String,
  paymentMethodId: json['paymentMethodId'] as String,
  transactions: (json['transactions'] as List<dynamic>)
      .map((e) => PaymentTransactionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  paymentAttempts: (json['paymentAttempts'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  auditLogs: (json['auditLogs'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'paymentId': instance.paymentId,
      'paymentNumber': instance.paymentNumber,
      'paymentExternalKey': instance.paymentExternalKey,
      'authAmount': instance.authAmount,
      'capturedAmount': instance.capturedAmount,
      'purchasedAmount': instance.purchasedAmount,
      'refundedAmount': instance.refundedAmount,
      'creditedAmount': instance.creditedAmount,
      'currency': instance.currency,
      'paymentMethodId': instance.paymentMethodId,
      'transactions': instance.transactions,
      'paymentAttempts': instance.paymentAttempts,
      'auditLogs': instance.auditLogs,
    };
