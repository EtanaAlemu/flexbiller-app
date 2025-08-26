// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_custom_field_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionCustomFieldModel _$SubscriptionCustomFieldModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionCustomFieldModel(
  customFieldId: json['customFieldId'] as String?,
  objectId: json['objectId'] as String?,
  objectType: json['objectType'] as String?,
  name: json['name'] as String,
  value: json['value'] as String,
  auditLogs:
      (json['auditLogs'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$SubscriptionCustomFieldModelToJson(
  SubscriptionCustomFieldModel instance,
) => <String, dynamic>{
  'customFieldId': instance.customFieldId,
  'objectId': instance.objectId,
  'objectType': instance.objectType,
  'name': instance.name,
  'value': instance.value,
  'auditLogs': instance.auditLogs,
};
