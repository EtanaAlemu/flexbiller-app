import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bundle_subscription.dart';
import 'bundle_event_model.dart';

part 'bundle_subscription_model.g.dart';

@JsonSerializable()
class BundleSubscriptionModel {
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
  final String chargedThroughDate;

  @JsonKey(name: 'billingStartDate')
  final String billingStartDate;

  @JsonKey(name: 'billingEndDate')
  final String? billingEndDate;

  @JsonKey(name: 'billCycleDayLocal')
  final int billCycleDayLocal;

  @JsonKey(name: 'quantity')
  final int quantity;

  @JsonKey(name: 'events')
  final List<BundleEventModel> events;

  @JsonKey(name: 'priceOverrides')
  final dynamic priceOverrides;

  @JsonKey(name: 'prices')
  final List<dynamic> prices;

  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>>? auditLogs;

  const BundleSubscriptionModel({
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
    this.auditLogs,
  });

  factory BundleSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$BundleSubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$BundleSubscriptionModelToJson(this);

  BundleSubscription toEntity() {
    return BundleSubscription(
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
      chargedThroughDate: chargedThroughDate,
      billingStartDate: DateTime.parse(billingStartDate),
      billingEndDate: billingEndDate != null
          ? DateTime.parse(billingEndDate!)
          : null,
      billCycleDayLocal: billCycleDayLocal,
      quantity: quantity,
      events: events.map((e) => e.toEntity()).toList(),
      priceOverrides: priceOverrides,
      prices: prices,
      auditLogs: auditLogs,
    );
  }
}
