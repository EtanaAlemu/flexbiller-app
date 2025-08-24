// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_blocking_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBlockingStateModel _$AccountBlockingStateModelFromJson(
  Map<String, dynamic> json,
) => AccountBlockingStateModel(
  stateName: json['stateName'] as String,
  service: json['service'] as String,
  isBlockChange: json['isBlockChange'] as bool,
  isBlockEntitlement: json['isBlockEntitlement'] as bool,
  isBlockBilling: json['isBlockBilling'] as bool,
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  type: json['type'] as String,
);

Map<String, dynamic> _$AccountBlockingStateModelToJson(
  AccountBlockingStateModel instance,
) => <String, dynamic>{
  'stateName': instance.stateName,
  'service': instance.service,
  'isBlockChange': instance.isBlockChange,
  'isBlockEntitlement': instance.isBlockEntitlement,
  'isBlockBilling': instance.isBlockBilling,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'type': instance.type,
};
