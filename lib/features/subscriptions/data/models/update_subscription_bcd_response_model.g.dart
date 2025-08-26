// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_subscription_bcd_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateSubscriptionBcdResponseModel _$UpdateSubscriptionBcdResponseModelFromJson(
  Map<String, dynamic> json,
) => UpdateSubscriptionBcdResponseModel(
  success: json['success'] as bool,
  code: (json['code'] as num).toInt(),
  data: SubscriptionBcdDataModel.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String,
);

Map<String, dynamic> _$UpdateSubscriptionBcdResponseModelToJson(
  UpdateSubscriptionBcdResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'code': instance.code,
  'data': instance.data,
  'message': instance.message,
};

SubscriptionBcdDataModel _$SubscriptionBcdDataModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionBcdDataModel(
  accountId: json['accountId'] as String?,
  bundleId: json['bundleId'] as String?,
  bundleExternalKey: json['bundleExternalKey'] as String?,
  subscriptionId: json['subscriptionId'] as String?,
  externalKey: json['externalKey'] as String?,
  startDate: json['startDate'] as String?,
  productName: json['productName'] as String?,
  productCategory: json['productCategory'] as String?,
  billingPeriod: json['billingPeriod'] as String?,
  phaseType: json['phaseType'] as String?,
  priceList: json['priceList'] as String?,
  planName: json['planName'] as String?,
  state: json['state'] as String?,
  sourceType: json['sourceType'] as String?,
  cancelledDate: json['cancelledDate'] as String?,
  chargedThroughDate: json['chargedThroughDate'] as String?,
  billingStartDate: json['billingStartDate'] as String?,
  billingEndDate: json['billingEndDate'] as String?,
  billCycleDayLocal: (json['billCycleDayLocal'] as num?)?.toInt(),
  quantity: (json['quantity'] as num?)?.toInt(),
  events: (json['events'] as List<dynamic>?)
      ?.map((e) => SubscriptionEventModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  priceOverrides: json['priceOverrides'],
  prices: (json['prices'] as List<dynamic>?)
      ?.map((e) => SubscriptionPriceModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  auditLogs: json['auditLogs'] as List<dynamic>?,
);

Map<String, dynamic> _$SubscriptionBcdDataModelToJson(
  SubscriptionBcdDataModel instance,
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

SubscriptionEventModel _$SubscriptionEventModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionEventModel(
  eventId: json['eventId'] as String?,
  billingPeriod: json['billingPeriod'] as String?,
  effectiveDate: json['effectiveDate'] as String?,
  catalogEffectiveDate: json['catalogEffectiveDate'] as String?,
  plan: json['plan'] as String?,
  product: json['product'] as String?,
  priceList: json['priceList'] as String?,
  eventType: json['eventType'] as String?,
  isBlockedBilling: json['isBlockedBilling'] as bool?,
  isBlockedEntitlement: json['isBlockedEntitlement'] as bool?,
  serviceName: json['serviceName'] as String?,
  serviceStateName: json['serviceStateName'] as String?,
  phase: json['phase'] as String?,
  auditLogs: json['auditLogs'] as List<dynamic>?,
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

SubscriptionPriceModel _$SubscriptionPriceModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionPriceModel(
  planName: json['planName'] as String?,
  phaseName: json['phaseName'] as String?,
  phaseType: json['phaseType'] as String?,
  fixedPrice: (json['fixedPrice'] as num?)?.toDouble(),
  recurringPrice: (json['recurringPrice'] as num?)?.toDouble(),
  usagePrices: json['usagePrices'] as List<dynamic>?,
);

Map<String, dynamic> _$SubscriptionPriceModelToJson(
  SubscriptionPriceModel instance,
) => <String, dynamic>{
  'planName': instance.planName,
  'phaseName': instance.phaseName,
  'phaseType': instance.phaseType,
  'fixedPrice': instance.fixedPrice,
  'recurringPrice': instance.recurringPrice,
  'usagePrices': instance.usagePrices,
};
