// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_trend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionTrendModel _$SubscriptionTrendModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionTrendModel(
  month: json['month'] as String,
  newSubscriptions: (json['newSubscriptions'] as num).toInt(),
  churnedSubscriptions: (json['churnedSubscriptions'] as num).toInt(),
  revenue: (json['revenue'] as num).toDouble(),
);

Map<String, dynamic> _$SubscriptionTrendModelToJson(
  SubscriptionTrendModel instance,
) => <String, dynamic>{
  'month': instance.month,
  'newSubscriptions': instance.newSubscriptions,
  'churnedSubscriptions': instance.churnedSubscriptions,
  'revenue': instance.revenue,
};

SubscriptionTrendsModel _$SubscriptionTrendsModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionTrendsModel(
  trends: (json['trends'] as List<dynamic>)
      .map((e) => SubscriptionTrendModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  year: (json['year'] as num).toInt(),
);

Map<String, dynamic> _$SubscriptionTrendsModelToJson(
  SubscriptionTrendsModel instance,
) => <String, dynamic>{
  'trends': instance.trends.map((e) => e.toJson()).toList(),
  'year': instance.year,
};
