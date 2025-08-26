// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_subscription_bcd_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateSubscriptionBcdRequestModel _$UpdateSubscriptionBcdRequestModelFromJson(
  Map<String, dynamic> json,
) => UpdateSubscriptionBcdRequestModel(
  accountId: json['accountId'] as String,
  bundleId: json['bundleId'] as String,
  subscriptionId: json['subscriptionId'] as String,
  startDate: json['startDate'] as String,
  productName: json['productName'] as String,
  productCategory: json['productCategory'] as String,
  billingPeriod: json['billingPeriod'] as String,
  priceList: json['priceList'] as String,
  phaseType: json['phaseType'] as String,
  billCycleDayLocal: (json['billCycleDayLocal'] as num).toInt(),
);

Map<String, dynamic> _$UpdateSubscriptionBcdRequestModelToJson(
  UpdateSubscriptionBcdRequestModel instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'bundleId': instance.bundleId,
  'subscriptionId': instance.subscriptionId,
  'startDate': instance.startDate,
  'productName': instance.productName,
  'productCategory': instance.productCategory,
  'billingPeriod': instance.billingPeriod,
  'priceList': instance.priceList,
  'phaseType': instance.phaseType,
  'billCycleDayLocal': instance.billCycleDayLocal,
};
