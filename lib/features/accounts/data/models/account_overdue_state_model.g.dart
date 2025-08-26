// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_overdue_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountOverdueStateModel _$AccountOverdueStateModelFromJson(
  Map<String, dynamic> json,
) => AccountOverdueStateModel(
  name: json['name'] as String,
  externalMessage: json['externalMessage'] as String,
  isDisableEntitlementAndChangesBlocked:
      json['isDisableEntitlementAndChangesBlocked'] as bool,
  isBlockChanges: json['isBlockChanges'] as bool,
  isClearState: json['isClearState'] as bool,
  reevaluationIntervalDays: (json['reevaluationIntervalDays'] as num?)?.toInt(),
);

Map<String, dynamic> _$AccountOverdueStateModelToJson(
  AccountOverdueStateModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'externalMessage': instance.externalMessage,
  'isDisableEntitlementAndChangesBlocked':
      instance.isDisableEntitlementAndChangesBlocked,
  'isBlockChanges': instance.isBlockChanges,
  'isClearState': instance.isClearState,
  'reevaluationIntervalDays': instance.reevaluationIntervalDays,
};
