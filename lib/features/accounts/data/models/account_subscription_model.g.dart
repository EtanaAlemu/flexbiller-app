// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountSubscriptionModel _$AccountSubscriptionModelFromJson(
  Map<String, dynamic> json,
) => AccountSubscriptionModel(
  accountId: json['accountId'] as String,
  bundleId: json['bundleId'] as String,
  bundleExternalKey: json['bundleExternalKey'] as String,
  subscriptionId: json['subscriptionId'] as String,
  externalKey: json['externalKey'] as String,
  startDate: json['startDate'] as String,
  productName: json['productName'] as String,
  productCategory: json['productCategory'] as String,
  billingPeriod: json['billingPeriod'] as String,
  phaseType: json['phaseType'] as String,
  priceList: json['priceList'] as String,
  planName: json['planName'] as String,
  state: json['state'] as String,
  sourceType: json['sourceType'] as String,
  cancelledDate: json['cancelledDate'] as String?,
  chargedThroughDate: json['chargedThroughDate'] as String,
  billingStartDate: json['billingStartDate'] as String,
  billingEndDate: json['billingEndDate'] as String?,
  billCycleDayLocal: (json['billCycleDayLocal'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  events: (json['events'] as List<dynamic>)
      .map(
        (e) =>
            AccountSubscriptionEventModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  priceOverrides: json['priceOverrides'],
  prices: (json['prices'] as List<dynamic>)
      .map(
        (e) =>
            AccountSubscriptionPriceModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  auditLogs: (json['auditLogs'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$AccountSubscriptionModelToJson(
  AccountSubscriptionModel instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'bundleId': instance.bundleId,
  'bundleExternalKey': instance.bundleExternalKey,
  'subscriptionId': instance.subscriptionId,
  'externalKey': instance.externalKey,
  'startDate': instance.startDate,
  'productName': instance.productName,
  'productCategory': instance.productCategory,
  'billingPeriod': instance.billingPeriod,
  'phaseType': instance.phaseType,
  'priceList': instance.priceList,
  'planName': instance.planName,
  'state': instance.state,
  'sourceType': instance.sourceType,
  'cancelledDate': instance.cancelledDate,
  'chargedThroughDate': instance.chargedThroughDate,
  'billingStartDate': instance.billingStartDate,
  'billingEndDate': instance.billingEndDate,
  'billCycleDayLocal': instance.billCycleDayLocal,
  'quantity': instance.quantity,
  'events': instance.events,
  'priceOverrides': instance.priceOverrides,
  'prices': instance.prices,
  'auditLogs': instance.auditLogs,
};
