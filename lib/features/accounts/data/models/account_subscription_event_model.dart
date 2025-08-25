import 'package:json_annotation/json_annotation.dart';

part 'account_subscription_event_model.g.dart';

@JsonSerializable()
class AccountSubscriptionEventModel {
  @JsonKey(name: 'eventId')
  final String eventId;
  
  @JsonKey(name: 'billingPeriod')
  final String billingPeriod;
  
  @JsonKey(name: 'effectiveDate')
  final String effectiveDate;
  
  @JsonKey(name: 'catalogEffectiveDate')
  final String catalogEffectiveDate;
  
  @JsonKey(name: 'plan')
  final String plan;
  
  @JsonKey(name: 'product')
  final String product;
  
  @JsonKey(name: 'priceList')
  final String priceList;
  
  @JsonKey(name: 'eventType')
  final String eventType;
  
  @JsonKey(name: 'isBlockedBilling')
  final bool isBlockedBilling;
  
  @JsonKey(name: 'isBlockedEntitlement')
  final bool isBlockedEntitlement;
  
  @JsonKey(name: 'serviceName')
  final String serviceName;
  
  @JsonKey(name: 'serviceStateName')
  final String serviceStateName;
  
  @JsonKey(name: 'phase')
  final String phase;
  
  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>>? auditLogs;

  const AccountSubscriptionEventModel({
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
    this.auditLogs,
  });

  factory AccountSubscriptionEventModel.fromJson(Map<String, dynamic> json) =>
      _$AccountSubscriptionEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountSubscriptionEventModelToJson(this);
}
