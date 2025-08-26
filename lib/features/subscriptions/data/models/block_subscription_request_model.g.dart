// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_subscription_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockSubscriptionRequestModel _$BlockSubscriptionRequestModelFromJson(
  Map<String, dynamic> json,
) => BlockSubscriptionRequestModel(
  stateName: json['stateName'] as String,
  service: json['service'] as String,
  isBlockChange: json['isBlockChange'] as bool,
  isBlockEntitlement: json['isBlockEntitlement'] as bool,
  isBlockBilling: json['isBlockBilling'] as bool,
  effectiveDate: json['effectiveDate'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$BlockSubscriptionRequestModelToJson(
  BlockSubscriptionRequestModel instance,
) => <String, dynamic>{
  'stateName': instance.stateName,
  'service': instance.service,
  'isBlockChange': instance.isBlockChange,
  'isBlockEntitlement': instance.isBlockEntitlement,
  'isBlockBilling': instance.isBlockBilling,
  'effectiveDate': instance.effectiveDate,
  'type': instance.type,
};
