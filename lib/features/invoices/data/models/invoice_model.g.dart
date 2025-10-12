// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceModel _$InvoiceModelFromJson(Map<String, dynamic> json) => InvoiceModel(
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
  creditAdj: (json['creditAdj'] as num).toDouble(),
  refundAdj: (json['refundAdj'] as num).toDouble(),
  invoiceId: json['invoiceId'] as String,
  invoiceDate: json['invoiceDate'] as String,
  targetDate: json['targetDate'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  balance: (json['balance'] as num).toDouble(),
  accountId: json['accountId'] as String,
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
      .map((e) => InvoiceAuditLogModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InvoiceModelToJson(InvoiceModel instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'creditAdj': instance.creditAdj,
      'refundAdj': instance.refundAdj,
      'invoiceId': instance.invoiceId,
      'invoiceDate': instance.invoiceDate,
      'targetDate': instance.targetDate,
      'invoiceNumber': instance.invoiceNumber,
      'balance': instance.balance,
      'accountId': instance.accountId,
      'bundleKeys': instance.bundleKeys,
      'credits': instance.credits,
      'items': instance.items,
      'trackingIds': instance.trackingIds,
      'isParentInvoice': instance.isParentInvoice,
      'parentInvoiceId': instance.parentInvoiceId,
      'parentAccountId': instance.parentAccountId,
      'auditLogs': instance.auditLogs,
    };
