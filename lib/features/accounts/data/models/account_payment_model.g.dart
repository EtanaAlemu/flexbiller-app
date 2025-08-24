// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountPaymentModel _$AccountPaymentModelFromJson(Map<String, dynamic> json) =>
    AccountPaymentModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      paymentType: json['paymentType'] as String,
      paymentStatus: json['paymentStatus'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      paymentMethodName: json['paymentMethodName'] as String?,
      paymentMethodType: json['paymentMethodType'] as String?,
      transactionId: json['transactionId'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      processedDate: json['processedDate'] == null
          ? null
          : DateTime.parse(json['processedDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      failureReason: json['failureReason'] as String?,
      gatewayResponse: json['gatewayResponse'] as String?,
      isRefunded: json['isRefunded'] as bool,
      refundedAmount: (json['refundedAmount'] as num?)?.toDouble(),
      refundedDate: json['refundedDate'] == null
          ? null
          : DateTime.parse(json['refundedDate'] as String),
      refundReason: json['refundReason'] as String?,
    );

Map<String, dynamic> _$AccountPaymentModelToJson(
  AccountPaymentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'paymentType': instance.paymentType,
  'paymentStatus': instance.paymentStatus,
  'amount': instance.amount,
  'currency': instance.currency,
  'paymentMethodId': instance.paymentMethodId,
  'paymentMethodName': instance.paymentMethodName,
  'paymentMethodType': instance.paymentMethodType,
  'transactionId': instance.transactionId,
  'referenceNumber': instance.referenceNumber,
  'description': instance.description,
  'notes': instance.notes,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'processedDate': instance.processedDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'metadata': instance.metadata,
  'failureReason': instance.failureReason,
  'gatewayResponse': instance.gatewayResponse,
  'isRefunded': instance.isRefunded,
  'refundedAmount': instance.refundedAmount,
  'refundedDate': instance.refundedDate?.toIso8601String(),
  'refundReason': instance.refundReason,
};
