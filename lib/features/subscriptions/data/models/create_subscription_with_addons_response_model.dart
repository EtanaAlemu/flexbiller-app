import 'package:json_annotation/json_annotation.dart';

part 'create_subscription_with_addons_response_model.g.dart';

@JsonSerializable()
class CreateSubscriptionWithAddonsResponseModel {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'code')
  final int code;

  @JsonKey(name: 'data')
  final String data;

  @JsonKey(name: 'message')
  final String message;

  const CreateSubscriptionWithAddonsResponseModel({
    required this.success,
    required this.code,
    required this.data,
    required this.message,
  });

  factory CreateSubscriptionWithAddonsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionWithAddonsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSubscriptionWithAddonsResponseModelToJson(this);
}
