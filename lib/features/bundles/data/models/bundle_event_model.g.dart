// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BundleEventModel _$BundleEventModelFromJson(Map<String, dynamic> json) =>
    BundleEventModel(
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
      auditLogs: (json['auditLogs'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$BundleEventModelToJson(BundleEventModel instance) =>
    <String, dynamic>{
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
