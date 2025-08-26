import 'package:json_annotation/json_annotation.dart';

part 'update_subscription_bcd_response_model.g.dart';

@JsonSerializable()
class UpdateSubscriptionBcdResponseModel {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'code')
  final int code;

  @JsonKey(name: 'data')
  final SubscriptionBcdDataModel data;

  @JsonKey(name: 'message')
  final String message;

  const UpdateSubscriptionBcdResponseModel({
    required this.success,
    required this.code,
    required this.data,
    required this.message,
  });

  factory UpdateSubscriptionBcdResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateSubscriptionBcdResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSubscriptionBcdResponseModelToJson(this);
}

@JsonSerializable()
class SubscriptionBcdDataModel {
  @JsonKey(name: 'accountId')
  final String? accountId;

  @JsonKey(name: 'bundleId')
  final String? bundleId;

  @JsonKey(name: 'bundleExternalKey')
  final String? bundleExternalKey;

  @JsonKey(name: 'subscriptionId')
  final String? subscriptionId;

  @JsonKey(name: 'externalKey')
  final String? externalKey;

  @JsonKey(name: 'startDate')
  final String? startDate;

  @JsonKey(name: 'productName')
  final String? productName;

  @JsonKey(name: 'productCategory')
  final String? productCategory;

  @JsonKey(name: 'billingPeriod')
  final String? billingPeriod;

  @JsonKey(name: 'phaseType')
  final String? phaseType;

  @JsonKey(name: 'priceList')
  final String? priceList;

  @JsonKey(name: 'planName')
  final String? planName;

  @JsonKey(name: 'state')
  final String? state;

  @JsonKey(name: 'sourceType')
  final String? sourceType;

  @JsonKey(name: 'cancelledDate')
  final String? cancelledDate;

  @JsonKey(name: 'chargedThroughDate')
  final String? chargedThroughDate;

  @JsonKey(name: 'billingStartDate')
  final String? billingStartDate;

  @JsonKey(name: 'billingEndDate')
  final String? billingEndDate;

  @JsonKey(name: 'billCycleDayLocal')
  final int? billCycleDayLocal;

  @JsonKey(name: 'quantity')
  final int? quantity;

  @JsonKey(name: 'events')
  final List<SubscriptionEventModel>? events;

  @JsonKey(name: 'priceOverrides')
  final dynamic priceOverrides;

  @JsonKey(name: 'prices')
  final List<SubscriptionPriceModel>? prices;

  @JsonKey(name: 'auditLogs')
  final List<dynamic>? auditLogs;

  const SubscriptionBcdDataModel({
    this.accountId,
    this.bundleId,
    this.bundleExternalKey,
    this.subscriptionId,
    this.externalKey,
    this.startDate,
    this.productName,
    this.productCategory,
    this.billingPeriod,
    this.phaseType,
    this.priceList,
    this.planName,
    this.state,
    this.sourceType,
    this.cancelledDate,
    this.chargedThroughDate,
    this.billingStartDate,
    this.billingEndDate,
    this.billCycleDayLocal,
    this.quantity,
    this.events,
    this.priceOverrides,
    this.prices,
    this.auditLogs,
  });

  factory SubscriptionBcdDataModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionBcdDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionBcdDataModelToJson(this);
}

@JsonSerializable()
class SubscriptionEventModel {
  @JsonKey(name: 'eventId')
  final String? eventId;

  @JsonKey(name: 'billingPeriod')
  final String? billingPeriod;

  @JsonKey(name: 'effectiveDate')
  final String? effectiveDate;

  @JsonKey(name: 'catalogEffectiveDate')
  final String? catalogEffectiveDate;

  @JsonKey(name: 'plan')
  final String? plan;

  @JsonKey(name: 'product')
  final String? product;

  @JsonKey(name: 'priceList')
  final String? priceList;

  @JsonKey(name: 'eventType')
  final String? eventType;

  @JsonKey(name: 'isBlockedBilling')
  final bool? isBlockedBilling;

  @JsonKey(name: 'isBlockedEntitlement')
  final bool? isBlockedEntitlement;

  @JsonKey(name: 'serviceName')
  final String? serviceName;

  @JsonKey(name: 'serviceStateName')
  final String? serviceStateName;

  @JsonKey(name: 'phase')
  final String? phase;

  @JsonKey(name: 'auditLogs')
  final List<dynamic>? auditLogs;

  const SubscriptionEventModel({
    this.eventId,
    this.billingPeriod,
    this.effectiveDate,
    this.catalogEffectiveDate,
    this.plan,
    this.product,
    this.priceList,
    this.eventType,
    this.isBlockedBilling,
    this.isBlockedEntitlement,
    this.serviceName,
    this.serviceStateName,
    this.phase,
    this.auditLogs,
  });

  factory SubscriptionEventModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionEventModelToJson(this);
}

@JsonSerializable()
class SubscriptionPriceModel {
  @JsonKey(name: 'planName')
  final String? planName;

  @JsonKey(name: 'phaseName')
  final String? phaseName;

  @JsonKey(name: 'phaseType')
  final String? phaseType;

  @JsonKey(name: 'fixedPrice')
  final double? fixedPrice;

  @JsonKey(name: 'recurringPrice')
  final double? recurringPrice;

  @JsonKey(name: 'usagePrices')
  final List<dynamic>? usagePrices;

  const SubscriptionPriceModel({
    this.planName,
    this.phaseName,
    this.phaseType,
    this.fixedPrice,
    this.recurringPrice,
    this.usagePrices,
  });

  factory SubscriptionPriceModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPriceModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPriceModelToJson(this);
}
