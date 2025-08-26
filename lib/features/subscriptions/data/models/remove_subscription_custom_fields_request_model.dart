import 'package:json_annotation/json_annotation.dart';

part 'remove_subscription_custom_fields_request_model.g.dart';

@JsonSerializable()
class RemoveSubscriptionCustomFieldsRequestModel {
  @JsonKey(name: 'customFieldIds')
  final String customFieldIds;

  const RemoveSubscriptionCustomFieldsRequestModel({
    required this.customFieldIds,
  });

  factory RemoveSubscriptionCustomFieldsRequestModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$RemoveSubscriptionCustomFieldsRequestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RemoveSubscriptionCustomFieldsRequestModelToJson(this);
}

