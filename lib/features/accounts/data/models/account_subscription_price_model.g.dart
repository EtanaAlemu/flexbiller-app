// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_subscription_price_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountSubscriptionPriceModel _$AccountSubscriptionPriceModelFromJson(
  Map<String, dynamic> json,
) => AccountSubscriptionPriceModel(
  planName: json['planName'] as String,
  phaseName: json['phaseName'] as String,
  phaseType: json['phaseType'] as String,
  fixedPrice: (json['fixedPrice'] as num?)?.toDouble(),
  recurringPrice: (json['recurringPrice'] as num?)?.toDouble(),
  usagePrices: (json['usagePrices'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$AccountSubscriptionPriceModelToJson(
  AccountSubscriptionPriceModel instance,
) => <String, dynamic>{
  'planName': instance.planName,
  'phaseName': instance.phaseName,
  'phaseType': instance.phaseType,
  'fixedPrice': instance.fixedPrice,
  'recurringPrice': instance.recurringPrice,
  'usagePrices': instance.usagePrices,
};
