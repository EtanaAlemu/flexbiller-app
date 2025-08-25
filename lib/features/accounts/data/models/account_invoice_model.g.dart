// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountInvoiceModel _$AccountInvoiceModelFromJson(Map<String, dynamic> json) =>
    AccountInvoiceModel(
      invoiceId: json['invoiceId'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      accountId: json['accountId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      balance: (json['balance'] as num).toDouble(),
      creditAdj: (json['creditAdj'] as num).toDouble(),
      refundAdj: (json['refundAdj'] as num).toDouble(),
      invoiceDate: json['invoiceDate'] as String,
      targetDate: json['targetDate'] as String,
      bundleKeys: (json['bundleKeys'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      credits: (json['credits'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      items: (json['items'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      trackingIds: (json['trackingIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isParentInvoice: json['isParentInvoice'] as bool,
      parentInvoiceId: json['parentInvoiceId'] as String?,
      parentAccountId: json['parentAccountId'] as String?,
      auditLogs: (json['auditLogs'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$AccountInvoiceModelToJson(
  AccountInvoiceModel instance,
) => <String, dynamic>{
  'invoiceId': instance.invoiceId,
  'invoiceNumber': instance.invoiceNumber,
  'accountId': instance.accountId,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': instance.status,
  'balance': instance.balance,
  'creditAdj': instance.creditAdj,
  'refundAdj': instance.refundAdj,
  'invoiceDate': instance.invoiceDate,
  'targetDate': instance.targetDate,
  'bundleKeys': instance.bundleKeys,
  'credits': instance.credits,
  'items': instance.items,
  'trackingIds': instance.trackingIds,
  'isParentInvoice': instance.isParentInvoice,
  'parentInvoiceId': instance.parentInvoiceId,
  'parentAccountId': instance.parentAccountId,
  'auditLogs': instance.auditLogs,
};
