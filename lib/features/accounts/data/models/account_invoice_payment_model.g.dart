// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_invoice_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountInvoicePaymentModel _$AccountInvoicePaymentModelFromJson(
  Map<String, dynamic> json,
) => AccountInvoicePaymentModel(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  invoiceId: json['invoiceId'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  paymentMethod: json['paymentMethod'] as String,
  status: json['status'] as String,
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  processedDate: json['processedDate'] == null
      ? null
      : DateTime.parse(json['processedDate'] as String),
  transactionId: json['transactionId'] as String?,
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AccountInvoicePaymentModelToJson(
  AccountInvoicePaymentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'invoiceId': instance.invoiceId,
  'invoiceNumber': instance.invoiceNumber,
  'amount': instance.amount,
  'currency': instance.currency,
  'paymentMethod': instance.paymentMethod,
  'status': instance.status,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'processedDate': instance.processedDate?.toIso8601String(),
  'transactionId': instance.transactionId,
  'notes': instance.notes,
  'metadata': instance.metadata,
};
