import 'package:json_annotation/json_annotation.dart';

part 'create_subscription_request_model.g.dart';

@JsonSerializable()
class CreateSubscriptionRequestModel {
  @JsonKey(name: 'accountId')
  final String accountId;

  @JsonKey(name: 'planName')
  final String planName;

  const CreateSubscriptionRequestModel({
    required this.accountId,
    required this.planName,
  });

  factory CreateSubscriptionRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSubscriptionRequestModelToJson(this);
}
