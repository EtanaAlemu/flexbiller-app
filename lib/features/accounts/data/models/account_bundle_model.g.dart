// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_bundle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBundleModel _$AccountBundleModelFromJson(Map<String, dynamic> json) =>
    AccountBundleModel(
      accountId: json['accountId'] as String,
      bundleId: json['bundleId'] as String,
      externalKey: json['externalKey'] as String,
      subscriptions: (json['subscriptions'] as List<dynamic>)
          .map(
            (e) => AccountSubscriptionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      timeline: AccountBundleTimelineModel.fromJson(
        json['timeline'] as Map<String, dynamic>,
      ),
      auditLogs: (json['auditLogs'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$AccountBundleModelToJson(AccountBundleModel instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'bundleId': instance.bundleId,
      'externalKey': instance.externalKey,
      'subscriptions': instance.subscriptions,
      'timeline': instance.timeline,
      'auditLogs': instance.auditLogs,
    };
