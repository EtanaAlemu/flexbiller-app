import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_bundle.dart';

part 'account_bundle_model.g.dart';

// Main response model for account bundles
@JsonSerializable()
class AccountBundlesResponseModel {
  final String message;
  final String accountId;
  final List<BundleModel> bundles;

  const AccountBundlesResponseModel({
    required this.message,
    required this.accountId,
    required this.bundles,
  });

  factory AccountBundlesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AccountBundlesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBundlesResponseModelToJson(this);

  List<AccountBundle> toEntities() {
    return bundles.map((bundle) => bundle.toEntity()).toList();
  }
}

// Bundle model for account bundles
@JsonSerializable()
class BundleModel {
  final String accountId;
  final String bundleId;
  final String externalKey;
  final List<SubscriptionModel> subscriptions;
  final TimelineModel timeline;
  final List<dynamic> auditLogs;

  const BundleModel({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.subscriptions,
    required this.timeline,
    required this.auditLogs,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) =>
      _$BundleModelFromJson(json);

  Map<String, dynamic> toJson() => _$BundleModelToJson(this);

  AccountBundle toEntity() {
    return AccountBundle(
      accountId: accountId,
      bundleId: bundleId,
      externalKey: externalKey,
      subscriptions: subscriptions.map((s) => s.toEntity()).toList(),
      timeline: timeline.toEntity(),
      auditLogs: auditLogs,
    );
  }
}

// Subscription model
@JsonSerializable()
class SubscriptionModel {
  final String accountId;
  final String bundleId;
  final String bundleExternalKey;
  final String subscriptionId;
  final String externalKey;
  final String startDate;
  final String productName;
  final String productCategory;
  final String billingPeriod;
  final String phaseType;
  final String priceList;
  final String planName;
  final String state;
  final String sourceType;
  final String? cancelledDate;
  final String chargedThroughDate;
  final String billingStartDate;
  final String? billingEndDate;
  final int billCycleDayLocal;
  final int quantity;
  final List<SubscriptionEventModel> events;
  final dynamic priceOverrides;
  final List<PriceModel> prices;
  final List<dynamic> auditLogs;

  const SubscriptionModel({
    required this.accountId,
    required this.bundleId,
    required this.bundleExternalKey,
    required this.subscriptionId,
    required this.externalKey,
    required this.startDate,
    required this.productName,
    required this.productCategory,
    required this.billingPeriod,
    required this.phaseType,
    required this.priceList,
    required this.planName,
    required this.state,
    required this.sourceType,
    this.cancelledDate,
    required this.chargedThroughDate,
    required this.billingStartDate,
    this.billingEndDate,
    required this.billCycleDayLocal,
    required this.quantity,
    required this.events,
    this.priceOverrides,
    required this.prices,
    required this.auditLogs,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);

  Subscription toEntity() {
    return Subscription(
      accountId: accountId,
      bundleId: bundleId,
      bundleExternalKey: bundleExternalKey,
      subscriptionId: subscriptionId,
      externalKey: externalKey,
      startDate: DateTime.parse(startDate),
      productName: productName,
      productCategory: productCategory,
      billingPeriod: billingPeriod,
      phaseType: phaseType,
      priceList: priceList,
      planName: planName,
      state: state,
      sourceType: sourceType,
      cancelledDate: cancelledDate != null
          ? DateTime.parse(cancelledDate!)
          : null,
      chargedThroughDate: DateTime.parse(chargedThroughDate),
      billingStartDate: DateTime.parse(billingStartDate),
      billingEndDate: billingEndDate != null
          ? DateTime.parse(billingEndDate!)
          : null,
      billCycleDayLocal: billCycleDayLocal,
      quantity: quantity,
      events: events.map((e) => e.toEntity()).toList(),
      priceOverrides: priceOverrides,
      prices: prices.map((p) => p.toEntity()).toList(),
      auditLogs: auditLogs,
    );
  }
}

// Subscription event model
@JsonSerializable()
class SubscriptionEventModel {
  final String eventId;
  final String billingPeriod;
  final String effectiveDate;
  final String catalogEffectiveDate;
  final String plan;
  final String product;
  final String priceList;
  final String eventType;
  final bool isBlockedBilling;
  final bool isBlockedEntitlement;
  final String serviceName;
  final String serviceStateName;
  final String phase;
  final List<dynamic> auditLogs;

  const SubscriptionEventModel({
    required this.eventId,
    required this.billingPeriod,
    required this.effectiveDate,
    required this.catalogEffectiveDate,
    required this.plan,
    required this.product,
    required this.priceList,
    required this.eventType,
    required this.isBlockedBilling,
    required this.isBlockedEntitlement,
    required this.serviceName,
    required this.serviceStateName,
    required this.phase,
    required this.auditLogs,
  });

  factory SubscriptionEventModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionEventModelToJson(this);

  SubscriptionEvent toEntity() {
    return SubscriptionEvent(
      eventId: eventId,
      billingPeriod: billingPeriod,
      effectiveDate: DateTime.parse(effectiveDate),
      catalogEffectiveDate: DateTime.parse(catalogEffectiveDate),
      plan: plan,
      product: product,
      priceList: priceList,
      eventType: eventType,
      isBlockedBilling: isBlockedBilling,
      isBlockedEntitlement: isBlockedEntitlement,
      serviceName: serviceName,
      serviceStateName: serviceStateName,
      phase: phase,
      auditLogs: auditLogs,
    );
  }
}

// Price model
@JsonSerializable()
class PriceModel {
  final String planName;
  final String phaseName;
  final String phaseType;
  final double? fixedPrice;
  final double? recurringPrice;
  final List<dynamic> usagePrices;

  const PriceModel({
    required this.planName,
    required this.phaseName,
    required this.phaseType,
    this.fixedPrice,
    this.recurringPrice,
    required this.usagePrices,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) =>
      _$PriceModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceModelToJson(this);

  Price toEntity() {
    return Price(
      planName: planName,
      phaseName: phaseName,
      phaseType: phaseType,
      fixedPrice: fixedPrice,
      recurringPrice: recurringPrice,
      usagePrices: usagePrices,
    );
  }
}

// Timeline model
@JsonSerializable()
class TimelineModel {
  final String accountId;
  final String bundleId;
  final String externalKey;
  final List<SubscriptionEventModel> events;
  final List<dynamic> auditLogs;

  const TimelineModel({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.events,
    required this.auditLogs,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);

  Timeline toEntity() {
    return Timeline(
      accountId: accountId,
      bundleId: bundleId,
      externalKey: externalKey,
      events: events.map((e) => e.toEntity()).toList(),
      auditLogs: auditLogs,
    );
  }
}
