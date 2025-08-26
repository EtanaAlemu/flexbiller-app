import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/subscription_event.dart';

part 'subscription_event_model.g.dart';

@JsonSerializable()
class SubscriptionEventModel {
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
    this.auditLogs,
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
