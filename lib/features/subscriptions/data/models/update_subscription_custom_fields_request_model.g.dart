// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_subscription_custom_fields_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateSubscriptionCustomFieldsRequestModel
_$UpdateSubscriptionCustomFieldsRequestModelFromJson(
  Map<String, dynamic> json,
) => UpdateSubscriptionCustomFieldsRequestModel(
  customFieldId: json['customFieldId'] as String,
  name: json['name'] as String,
  value: json['value'] as String,
);

Map<String, dynamic> _$UpdateSubscriptionCustomFieldsRequestModelToJson(
  UpdateSubscriptionCustomFieldsRequestModel instance,
) => <String, dynamic>{
  'customFieldId': instance.customFieldId,
  'name': instance.name,
  'value': instance.value,
};
