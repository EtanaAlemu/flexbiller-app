import 'package:json_annotation/json_annotation.dart';
import 'account_subscription_event_model.dart';
import 'account_subscription_price_model.dart';

part 'account_subscription_model.g.dart';

@JsonSerializable()
class AccountSubscriptionModel {
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
  final List<AccountSubscriptionEventModel> events;
  
  @JsonKey(name: 'priceOverrides')
  final dynamic priceOverrides;
  
  @JsonKey(name: 'prices')
  final List<AccountSubscriptionPriceModel> prices;
  
  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>>? auditLogs;

  const AccountSubscriptionModel({
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

  factory AccountSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$AccountSubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountSubscriptionModelToJson(this);
}
