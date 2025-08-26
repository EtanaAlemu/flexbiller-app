// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_cba_rebalancing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountCbaRebalancingModel _$AccountCbaRebalancingModelFromJson(
  Map<String, dynamic> json,
) => AccountCbaRebalancingModel(
  message: json['message'] as String,
  accountId: json['accountId'] as String,
  result: json['result'] as String,
);

Map<String, dynamic> _$AccountCbaRebalancingModelToJson(
  AccountCbaRebalancingModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'accountId': instance.accountId,
  'result': instance.result,
};
