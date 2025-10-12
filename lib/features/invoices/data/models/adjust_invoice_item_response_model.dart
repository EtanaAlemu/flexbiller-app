import 'package:json_annotation/json_annotation.dart';

part 'adjust_invoice_item_response_model.g.dart';

@JsonSerializable()
class AdjustInvoiceItemResponseModel {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final String? error;
  final Map<String, dynamic>? details;

  const AdjustInvoiceItemResponseModel({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.details,
  });

  factory AdjustInvoiceItemResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AdjustInvoiceItemResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdjustInvoiceItemResponseModelToJson(this);
}
