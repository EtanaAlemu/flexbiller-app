import 'package:json_annotation/json_annotation.dart';

part 'update_subscription_custom_fields_request_model.g.dart';

@JsonSerializable()
class UpdateSubscriptionCustomFieldsRequestModel {
  @JsonKey(name: 'customFieldId')
  final String customFieldId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'value')
  final String value;

  const UpdateSubscriptionCustomFieldsRequestModel({
    required this.customFieldId,
    required this.name,
    required this.value,
  });

  factory UpdateSubscriptionCustomFieldsRequestModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$UpdateSubscriptionCustomFieldsRequestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateSubscriptionCustomFieldsRequestModelToJson(this);
}

