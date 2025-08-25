import 'package:json_annotation/json_annotation.dart';

part 'account_subscription_price_model.g.dart';

@JsonSerializable()
class AccountSubscriptionPriceModel {
  @JsonKey(name: 'planName')
  final String planName;
  
  @JsonKey(name: 'phaseName')
  final String phaseName;
  
  @JsonKey(name: 'phaseType')
  final String phaseType;
  
  @JsonKey(name: 'fixedPrice')
  final double? fixedPrice;
  
  @JsonKey(name: 'recurringPrice')
  final double? recurringPrice;
  
  @JsonKey(name: 'usagePrices')
  final List<Map<String, dynamic>>? usagePrices;

  const AccountSubscriptionPriceModel({
    required this.planName,
    required this.phaseName,
    required this.phaseType,
    this.fixedPrice,
    this.recurringPrice,
    this.usagePrices,
  });

  factory AccountSubscriptionPriceModel.fromJson(Map<String, dynamic> json) =>
      _$AccountSubscriptionPriceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountSubscriptionPriceModelToJson(this);
}
