import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bundle_event.dart';

part 'bundle_event_model.g.dart';

@JsonSerializable()
class BundleEventModel {
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
  final List<Map<String, dynamic>> auditLogs;

  const BundleEventModel({
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

  factory BundleEventModel.fromJson(Map<String, dynamic> json) =>
      _$BundleEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$BundleEventModelToJson(this);

  BundleEvent toEntity() {
    return BundleEvent(
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
