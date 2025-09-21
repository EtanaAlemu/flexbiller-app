// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentTransactionModel _$PaymentTransactionModelFromJson(
  Map<String, dynamic> json,
) => PaymentTransactionModel(
  transactionId: json['transactionId'] as String,
  transactionExternalKey: json['transactionExternalKey'] as String?,
  paymentId: json['paymentId'] as String,
  paymentExternalKey: json['paymentExternalKey'] as String?,
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
  auditLogs: json['auditLogs'] as List<dynamic>?,
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

AccountPaymentModel _$AccountPaymentModelFromJson(Map<String, dynamic> json) =>
    AccountPaymentModel(
      id: json['paymentId'] as String,
      accountId: json['accountId'] as String,
      paymentNumber: json['paymentNumber'] as String?,
      paymentExternalKey: json['paymentExternalKey'] as String?,
      authAmount: (json['authAmount'] as num).toDouble(),
      capturedAmount: (json['capturedAmount'] as num).toDouble(),
      purchasedAmount: (json['purchasedAmount'] as num).toDouble(),
      refundedAmount: (json['refundedAmount'] as num).toDouble(),
      creditedAmount: (json['creditedAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      transactions: (json['transactions'] as List<dynamic>)
          .map(
            (e) => PaymentTransactionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      paymentAttempts: json['paymentAttempts'] as List<dynamic>?,
      auditLogs: json['auditLogs'] as List<dynamic>?,
    );

Map<String, dynamic> _$AccountPaymentModelToJson(
  AccountPaymentModel instance,
) => <String, dynamic>{
  'paymentId': instance.id,
  'accountId': instance.accountId,
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
