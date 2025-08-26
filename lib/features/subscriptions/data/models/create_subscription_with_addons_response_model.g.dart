// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_subscription_with_addons_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSubscriptionWithAddonsResponseModel
_$CreateSubscriptionWithAddonsResponseModelFromJson(
  Map<String, dynamic> json,
) => CreateSubscriptionWithAddonsResponseModel(
  success: json['success'] as bool,
  code: (json['code'] as num).toInt(),
  data: json['data'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$CreateSubscriptionWithAddonsResponseModelToJson(
  CreateSubscriptionWithAddonsResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'code': instance.code,
  'data': instance.data,
  'message': instance.message,
};
