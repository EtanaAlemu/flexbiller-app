import 'package:json_annotation/json_annotation.dart';

part 'adjust_invoice_item_request_model.g.dart';

@JsonSerializable()
class AdjustInvoiceItemRequestModel {
  final String invoiceItemId;
  final String accountId;
  final double amount;
  final String currency;
  final String description;

  const AdjustInvoiceItemRequestModel({
    required this.invoiceItemId,
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.description,
  });

  factory AdjustInvoiceItemRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AdjustInvoiceItemRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdjustInvoiceItemRequestModelToJson(this);
}
