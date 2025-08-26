// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remove_subscription_custom_fields_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoveSubscriptionCustomFieldsResponseModel
_$RemoveSubscriptionCustomFieldsResponseModelFromJson(
  Map<String, dynamic> json,
) => RemoveSubscriptionCustomFieldsResponseModel(
  subscriptionId: json['subscriptionId'] as String,
  removedCustomFields: (json['removedCustomFields'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RemoveSubscriptionCustomFieldsResponseModelToJson(
  RemoveSubscriptionCustomFieldsResponseModel instance,
) => <String, dynamic>{
  'subscriptionId': instance.subscriptionId,
  'removedCustomFields': instance.removedCustomFields,
};
