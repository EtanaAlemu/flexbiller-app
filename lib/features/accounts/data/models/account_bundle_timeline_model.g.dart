// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_bundle_timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBundleTimelineModel _$AccountBundleTimelineModelFromJson(
  Map<String, dynamic> json,
) => AccountBundleTimelineModel(
  accountId: json['accountId'] as String,
  bundleId: json['bundleId'] as String,
  externalKey: json['externalKey'] as String,
  events: (json['events'] as List<dynamic>)
      .map(
        (e) =>
            AccountSubscriptionEventModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  auditLogs: (json['auditLogs'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$AccountBundleTimelineModelToJson(
  AccountBundleTimelineModel instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'bundleId': instance.bundleId,
  'externalKey': instance.externalKey,
  'events': instance.events,
  'auditLogs': instance.auditLogs,
};
