// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_subscription_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockSubscriptionResponseModel _$BlockSubscriptionResponseModelFromJson(
  Map<String, dynamic> json,
) => BlockSubscriptionResponseModel(
  stateName: json['stateName'] as String,
  service: json['service'] as String,
  isBlockChange: json['isBlockChange'] as bool,
  isBlockEntitlement: json['isBlockEntitlement'] as bool,
  isBlockBilling: json['isBlockBilling'] as bool,
  effectiveDate: json['effectiveDate'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$BlockSubscriptionResponseModelToJson(
  BlockSubscriptionResponseModel instance,
) => <String, dynamic>{
  'stateName': instance.stateName,
  'service': instance.service,
  'isBlockChange': instance.isBlockChange,
  'isBlockEntitlement': instance.isBlockEntitlement,
  'isBlockBilling': instance.isBlockBilling,
  'effectiveDate': instance.effectiveDate,
  'type': instance.type,
};
