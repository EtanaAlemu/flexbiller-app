// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_subscription_with_addons_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSubscriptionWithAddonsRequestModel
_$CreateSubscriptionWithAddonsRequestModelFromJson(Map<String, dynamic> json) =>
    CreateSubscriptionWithAddonsRequestModel(
      accountId: json['accountId'] as String,
      productName: json['productName'] as String,
      productCategory: json['productCategory'] as String,
      billingPeriod: json['billingPeriod'] as String,
      priceList: json['priceList'] as String,
    );

Map<String, dynamic> _$CreateSubscriptionWithAddonsRequestModelToJson(
  CreateSubscriptionWithAddonsRequestModel instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'productName': instance.productName,
  'productCategory': instance.productCategory,
  'billingPeriod': instance.billingPeriod,
  'priceList': instance.priceList,
};
