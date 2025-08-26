import 'package:json_annotation/json_annotation.dart';

part 'update_subscription_request_model.g.dart';

@JsonSerializable()
class UpdateSubscriptionRequestModel {
  @JsonKey(name: 'accountId')
  final String accountId;

  @JsonKey(name: 'bundleId')
  final String bundleId;

  @JsonKey(name: 'bundleExternalKey')
  final String bundleExternalKey;

  @JsonKey(name: 'subscriptionId')
  final String subscriptionId;

  @JsonKey(name: 'externalKey')
  final String externalKey;

  @JsonKey(name: 'startDate')
  final String startDate;

  @JsonKey(name: 'productName')
  final String productName;

  @JsonKey(name: 'productCategory')
  final String productCategory;

  @JsonKey(name: 'billingPeriod')
  final String billingPeriod;

  @JsonKey(name: 'phaseType')
  final String phaseType;

  @JsonKey(name: 'priceList')
  final String priceList;

  @JsonKey(name: 'planName')
  final String planName;

  @JsonKey(name: 'state')
  final String state;

  @JsonKey(name: 'sourceType')
  final String sourceType;

  @JsonKey(name: 'cancelledDate')
  final String? cancelledDate;

  @JsonKey(name: 'chargedThroughDate')
  final String? chargedThroughDate;

  @JsonKey(name: 'billingStartDate')
  final String billingStartDate;

  @JsonKey(name: 'billingEndDate')
  final String? billingEndDate;

  @JsonKey(name: 'billCycleDayLocal')
  final int billCycleDayLocal;

  @JsonKey(name: 'quantity')
  final int quantity;

  @JsonKey(name: 'events')
  final List<Map<String, dynamic>> events;

  @JsonKey(name: 'priceOverrides')
  final List<Map<String, dynamic>>? priceOverrides;

  @JsonKey(name: 'prices')
  final List<Map<String, dynamic>> prices;

  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>>? auditLogs;

  const UpdateSubscriptionRequestModel({
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
    this.chargedThroughDate,
    required this.billingStartDate,
    this.billingEndDate,
    required this.billCycleDayLocal,
    required this.quantity,
    required this.events,
    this.priceOverrides,
    required this.prices,
    this.auditLogs,
  });

  factory UpdateSubscriptionRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateSubscriptionRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSubscriptionRequestModelToJson(this);

  // Create from existing subscription model
  factory UpdateSubscriptionRequestModel.fromSubscriptionModel(
    dynamic subscription,
  ) {
    return UpdateSubscriptionRequestModel(
      accountId: subscription.accountId,
      bundleId: subscription.bundleId,
      bundleExternalKey: subscription.bundleExternalKey,
      subscriptionId: subscription.subscriptionId,
      externalKey: subscription.externalKey,
      startDate: subscription.startDate,
      productName: subscription.productName,
      productCategory: subscription.productCategory,
      billingPeriod: subscription.billingPeriod,
      phaseType: subscription.phaseType,
      priceList: subscription.priceList,
      planName: subscription.planName,
      state: subscription.state,
      sourceType: subscription.sourceType,
      cancelledDate: subscription.cancelledDate,
      chargedThroughDate: subscription.chargedThroughDate,
      billingStartDate: subscription.billingStartDate,
      billingEndDate: subscription.billingEndDate,
      billCycleDayLocal: subscription.billCycleDayLocal,
      quantity: subscription.quantity,
      events: subscription.events.map((e) => e.toJson()).toList(),
      priceOverrides: subscription.priceOverrides,
      prices: subscription.prices,
      auditLogs: subscription.auditLogs,
    );
  }
}
