import 'package:json_annotation/json_annotation.dart';

part 'update_subscription_bcd_request_model.g.dart';

@JsonSerializable()
class UpdateSubscriptionBcdRequestModel {
  @JsonKey(name: 'accountId')
  final String accountId;

  @JsonKey(name: 'bundleId')
  final String bundleId;

  @JsonKey(name: 'subscriptionId')
  final String subscriptionId;

  @JsonKey(name: 'startDate')
  final String startDate;

  @JsonKey(name: 'productName')
  final String productName;

  @JsonKey(name: 'productCategory')
  final String productCategory;

  @JsonKey(name: 'billingPeriod')
  final String billingPeriod;

  @JsonKey(name: 'priceList')
  final String priceList;

  @JsonKey(name: 'phaseType')
  final String phaseType;

  @JsonKey(name: 'billCycleDayLocal')
  final int billCycleDayLocal;

  const UpdateSubscriptionBcdRequestModel({
    required this.accountId,
    required this.bundleId,
    required this.subscriptionId,
    required this.startDate,
    required this.productName,
    required this.productCategory,
    required this.billingPeriod,
    required this.priceList,
    required this.phaseType,
    required this.billCycleDayLocal,
  });

  factory UpdateSubscriptionBcdRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateSubscriptionBcdRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSubscriptionBcdRequestModelToJson(this);
}
