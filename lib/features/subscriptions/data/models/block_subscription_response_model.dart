import 'package:json_annotation/json_annotation.dart';

part 'block_subscription_response_model.g.dart';

@JsonSerializable()
class BlockSubscriptionResponseModel {
  @JsonKey(name: 'stateName')
  final String stateName;

  @JsonKey(name: 'service')
  final String service;

  @JsonKey(name: 'isBlockChange')
  final bool isBlockChange;

  @JsonKey(name: 'isBlockEntitlement')
  final bool isBlockEntitlement;

  @JsonKey(name: 'isBlockBilling')
  final bool isBlockBilling;

  @JsonKey(name: 'effectiveDate')
  final String effectiveDate;

  @JsonKey(name: 'type')
  final String type;

  const BlockSubscriptionResponseModel({
    required this.stateName,
    required this.service,
    required this.isBlockChange,
    required this.isBlockEntitlement,
    required this.isBlockBilling,
    required this.effectiveDate,
    required this.type,
  });

  factory BlockSubscriptionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BlockSubscriptionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlockSubscriptionResponseModelToJson(this);
}
