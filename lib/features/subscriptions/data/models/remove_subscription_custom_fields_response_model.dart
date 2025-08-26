import 'package:json_annotation/json_annotation.dart';

part 'remove_subscription_custom_fields_response_model.g.dart';

@JsonSerializable()
class RemoveSubscriptionCustomFieldsResponseModel {
  @JsonKey(name: 'subscriptionId')
  final String subscriptionId;

  @JsonKey(name: 'removedCustomFields')
  final List<String> removedCustomFields;

  const RemoveSubscriptionCustomFieldsResponseModel({
    required this.subscriptionId,
    required this.removedCustomFields,
  });

  factory RemoveSubscriptionCustomFieldsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$RemoveSubscriptionCustomFieldsResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RemoveSubscriptionCustomFieldsResponseModelToJson(this);
}

