// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_bundle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBundlesResponseModel _$AccountBundlesResponseModelFromJson(
  Map<String, dynamic> json,
) => AccountBundlesResponseModel(
  message: json['message'] as String,
  accountId: json['accountId'] as String,
  bundles: (json['bundles'] as List<dynamic>)
      .map((e) => BundleModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AccountBundlesResponseModelToJson(
  AccountBundlesResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'accountId': instance.accountId,
  'bundles': instance.bundles,
};

BundleModel _$BundleModelFromJson(Map<String, dynamic> json) => BundleModel(
  accountId: json['accountId'] as String,
  bundleId: json['bundleId'] as String,
  externalKey: json['externalKey'] as String,
  subscriptions: (json['subscriptions'] as List<dynamic>)
      .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  timeline: TimelineModel.fromJson(json['timeline'] as Map<String, dynamic>),
  auditLogs: json['auditLogs'] as List<dynamic>,
);

Map<String, dynamic> _$BundleModelToJson(BundleModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'bundleId': instance.bundleId,
      'externalKey': instance.externalKey,
      'subscriptions': instance.subscriptions,
      'timeline': instance.timeline,
      'auditLogs': instance.auditLogs,
    };

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
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
            (e) => SubscriptionEventModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      priceOverrides: json['priceOverrides'],
      prices: (json['prices'] as List<dynamic>)
          .map((e) => PriceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      auditLogs: json['auditLogs'] as List<dynamic>,
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
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

SubscriptionEventModel _$SubscriptionEventModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionEventModel(
  eventId: json['eventId'] as String,
  billingPeriod: json['billingPeriod'] as String,
  effectiveDate: json['effectiveDate'] as String,
  catalogEffectiveDate: json['catalogEffectiveDate'] as String,
  plan: json['plan'] as String,
  product: json['product'] as String,
  priceList: json['priceList'] as String,
  eventType: json['eventType'] as String,
  isBlockedBilling: json['isBlockedBilling'] as bool,
  isBlockedEntitlement: json['isBlockedEntitlement'] as bool,
  serviceName: json['serviceName'] as String,
  serviceStateName: json['serviceStateName'] as String,
  phase: json['phase'] as String,
  auditLogs: json['auditLogs'] as List<dynamic>,
);

Map<String, dynamic> _$SubscriptionEventModelToJson(
  SubscriptionEventModel instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'billingPeriod': instance.billingPeriod,
  'effectiveDate': instance.effectiveDate,
  'catalogEffectiveDate': instance.catalogEffectiveDate,
  'plan': instance.plan,
  'product': instance.product,
  'priceList': instance.priceList,
  'eventType': instance.eventType,
  'isBlockedBilling': instance.isBlockedBilling,
  'isBlockedEntitlement': instance.isBlockedEntitlement,
  'serviceName': instance.serviceName,
  'serviceStateName': instance.serviceStateName,
  'phase': instance.phase,
  'auditLogs': instance.auditLogs,
};

PriceModel _$PriceModelFromJson(Map<String, dynamic> json) => PriceModel(
  planName: json['planName'] as String,
  phaseName: json['phaseName'] as String,
  phaseType: json['phaseType'] as String,
  fixedPrice: (json['fixedPrice'] as num?)?.toDouble(),
  recurringPrice: (json['recurringPrice'] as num?)?.toDouble(),
  usagePrices: json['usagePrices'] as List<dynamic>,
);

Map<String, dynamic> _$PriceModelToJson(PriceModel instance) =>
    <String, dynamic>{
      'planName': instance.planName,
      'phaseName': instance.phaseName,
      'phaseType': instance.phaseType,
      'fixedPrice': instance.fixedPrice,
      'recurringPrice': instance.recurringPrice,
      'usagePrices': instance.usagePrices,
    };

TimelineModel _$TimelineModelFromJson(Map<String, dynamic> json) =>
    TimelineModel(
      accountId: json['accountId'] as String,
      bundleId: json['bundleId'] as String,
      externalKey: json['externalKey'] as String,
      events: (json['events'] as List<dynamic>)
          .map(
            (e) => SubscriptionEventModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      auditLogs: json['auditLogs'] as List<dynamic>,
    );

Map<String, dynamic> _$TimelineModelToJson(TimelineModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'bundleId': instance.bundleId,
      'externalKey': instance.externalKey,
      'events': instance.events,
      'auditLogs': instance.auditLogs,
    };
