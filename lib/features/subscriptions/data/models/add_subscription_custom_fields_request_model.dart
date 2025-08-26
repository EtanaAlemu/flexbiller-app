import 'package:json_annotation/json_annotation.dart';

part 'add_subscription_custom_fields_request_model.g.dart';

@JsonSerializable()
class AddSubscriptionCustomFieldsRequestModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'value')
  final String value;

  const AddSubscriptionCustomFieldsRequestModel({
    required this.name,
    required this.value,
  });

  factory AddSubscriptionCustomFieldsRequestModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$AddSubscriptionCustomFieldsRequestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AddSubscriptionCustomFieldsRequestModelToJson(this);
}

