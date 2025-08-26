// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_subscription_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSubscriptionRequestModel _$CreateSubscriptionRequestModelFromJson(
  Map<String, dynamic> json,
) => CreateSubscriptionRequestModel(
  accountId: json['accountId'] as String,
  planName: json['planName'] as String,
);

Map<String, dynamic> _$CreateSubscriptionRequestModelToJson(
  CreateSubscriptionRequestModel instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'planName': instance.planName,
};
