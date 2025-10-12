// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BundleModel _$BundleModelFromJson(Map<String, dynamic> json) => BundleModel(
  accountId: json['accountId'] as String,
  bundleId: json['bundleId'] as String,
  externalKey: json['externalKey'] as String,
  subscriptions: (json['subscriptions'] as List<dynamic>)
      .map((e) => BundleSubscriptionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  timeline: BundleTimelineModel.fromJson(
    json['timeline'] as Map<String, dynamic>,
  ),
  auditLogs: (json['auditLogs'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$BundleModelToJson(BundleModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'bundleId': instance.bundleId,
      'externalKey': instance.externalKey,
      'subscriptions': instance.subscriptions,
      'timeline': instance.timeline,
      'auditLogs': instance.auditLogs,
    };
