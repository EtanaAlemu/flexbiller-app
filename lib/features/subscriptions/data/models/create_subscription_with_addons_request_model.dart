import 'package:json_annotation/json_annotation.dart';

part 'create_subscription_with_addons_request_model.g.dart';

@JsonSerializable()
class CreateSubscriptionWithAddonsRequestModel {
  @JsonKey(name: 'accountId')
  final String accountId;

  @JsonKey(name: 'productName')
  final String productName;

  @JsonKey(name: 'productCategory')
  final String productCategory;

  @JsonKey(name: 'billingPeriod')
  final String billingPeriod;

  @JsonKey(name: 'priceList')
  final String priceList;

  const CreateSubscriptionWithAddonsRequestModel({
    required this.accountId,
    required this.productName,
    required this.productCategory,
    required this.billingPeriod,
    required this.priceList,
  });

  factory CreateSubscriptionWithAddonsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionWithAddonsRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSubscriptionWithAddonsRequestModelToJson(this);
}
