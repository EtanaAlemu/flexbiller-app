// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_invoice_item_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustInvoiceItemRequestModel _$AdjustInvoiceItemRequestModelFromJson(
  Map<String, dynamic> json,
) => AdjustInvoiceItemRequestModel(
  invoiceItemId: json['invoiceItemId'] as String,
  accountId: json['accountId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$AdjustInvoiceItemRequestModelToJson(
  AdjustInvoiceItemRequestModel instance,
) => <String, dynamic>{
  'invoiceItemId': instance.invoiceItemId,
  'accountId': instance.accountId,
  'amount': instance.amount,
  'currency': instance.currency,
  'description': instance.description,
};
