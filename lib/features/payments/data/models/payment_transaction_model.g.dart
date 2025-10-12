// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentTransactionModel _$PaymentTransactionModelFromJson(
  Map<String, dynamic> json,
) => PaymentTransactionModel(
  transactionId: json['transactionId'] as String,
  transactionExternalKey: json['transactionExternalKey'] as String,
  paymentId: json['paymentId'] as String,
  paymentExternalKey: json['paymentExternalKey'] as String,
  transactionType: json['transactionType'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  processedAmount: (json['processedAmount'] as num).toDouble(),
  processedCurrency: json['processedCurrency'] as String,
  status: json['status'] as String,
  gatewayErrorCode: json['gatewayErrorCode'] as String?,
  gatewayErrorMsg: json['gatewayErrorMsg'] as String?,
  firstPaymentReferenceId: json['firstPaymentReferenceId'] as String?,
  secondPaymentReferenceId: json['secondPaymentReferenceId'] as String?,
  properties: json['properties'] as Map<String, dynamic>?,
  auditLogs: (json['auditLogs'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$PaymentTransactionModelToJson(
  PaymentTransactionModel instance,
) => <String, dynamic>{
  'transactionId': instance.transactionId,
  'transactionExternalKey': instance.transactionExternalKey,
  'paymentId': instance.paymentId,
  'paymentExternalKey': instance.paymentExternalKey,
  'transactionType': instance.transactionType,
  'amount': instance.amount,
  'currency': instance.currency,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'processedAmount': instance.processedAmount,
  'processedCurrency': instance.processedCurrency,
  'status': instance.status,
  'gatewayErrorCode': instance.gatewayErrorCode,
  'gatewayErrorMsg': instance.gatewayErrorMsg,
  'firstPaymentReferenceId': instance.firstPaymentReferenceId,
  'secondPaymentReferenceId': instance.secondPaymentReferenceId,
  'properties': instance.properties,
  'auditLogs': instance.auditLogs,
};
