// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adjust_invoice_item_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdjustInvoiceItemResponseModel _$AdjustInvoiceItemResponseModelFromJson(
  Map<String, dynamic> json,
) => AdjustInvoiceItemResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: json['data'] as Map<String, dynamic>?,
  error: json['error'] as String?,
  details: json['details'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AdjustInvoiceItemResponseModelToJson(
  AdjustInvoiceItemResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'error': instance.error,
  'details': instance.details,
};
