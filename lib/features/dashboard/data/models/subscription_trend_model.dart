import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/subscription_trend.dart';

part 'subscription_trend_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SubscriptionTrendModel extends SubscriptionTrend {
  @JsonKey(name: 'month')
  @override
  final String month;

  @JsonKey(name: 'newSubscriptions')
  @override
  final int newSubscriptions;

  @JsonKey(name: 'churnedSubscriptions')
  @override
  final int churnedSubscriptions;

  @JsonKey(name: 'revenue')
  @override
  final double revenue;

  const SubscriptionTrendModel({
    required this.month,
    required this.newSubscriptions,
    required this.churnedSubscriptions,
    required this.revenue,
  }) : super(
         month: month,
         newSubscriptions: newSubscriptions,
         churnedSubscriptions: churnedSubscriptions,
         revenue: revenue,
       );

  factory SubscriptionTrendModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionTrendModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionTrendModelToJson(this);

  // Database operations - keep for local data source compatibility
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'newSubscriptions': newSubscriptions,
      'churnedSubscriptions': churnedSubscriptions,
      'revenue': revenue,
    };
  }

  factory SubscriptionTrendModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionTrendModel(
      month: map['month'] as String,
      newSubscriptions: map['newSubscriptions'] as int? ?? 0,
      churnedSubscriptions: map['churnedSubscriptions'] as int? ?? 0,
      revenue: (map['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  SubscriptionTrend toEntity() {
    return SubscriptionTrend(
      month: month,
      newSubscriptions: newSubscriptions,
      churnedSubscriptions: churnedSubscriptions,
      revenue: revenue,
    );
  }

  factory SubscriptionTrendModel.fromEntity(SubscriptionTrend entity) {
    return SubscriptionTrendModel(
      month: entity.month,
      newSubscriptions: entity.newSubscriptions,
      churnedSubscriptions: entity.churnedSubscriptions,
      revenue: entity.revenue,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SubscriptionTrendsModel extends SubscriptionTrends {
  @JsonKey(name: 'trends')
  @override
  final List<SubscriptionTrendModel> trends;

  @JsonKey(name: 'year')
  @override
  final int year;

  const SubscriptionTrendsModel({required this.trends, required this.year})
    : super(trends: trends, year: year);

  factory SubscriptionTrendsModel.fromJson(
    Map<String, dynamic> json,
    int year,
  ) {
    final List<dynamic> data = json['data'] as List<dynamic>? ?? [];
    final trends = data
        .map(
          (item) =>
              SubscriptionTrendModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    return SubscriptionTrendsModel(trends: trends, year: year);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': trends.map((trend) => trend.toJson()).toList(),
      'year': year,
    };
  }

  // Database operations
  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'trends': trends.map((trend) => trend.toMap()).toList(),
    };
  }

  factory SubscriptionTrendsModel.fromMap(Map<String, dynamic> map) {
    final trendsList =
        (map['trends'] as List<dynamic>?)
            ?.map(
              (item) =>
                  SubscriptionTrendModel.fromMap(item as Map<String, dynamic>),
            )
            .toList() ??
        [];
    return SubscriptionTrendsModel(
      trends: trendsList,
      year: map['year'] as int? ?? DateTime.now().year,
    );
  }

  SubscriptionTrends toEntity() {
    return SubscriptionTrends(
      trends: trends.map((t) => t.toEntity()).toList(),
      year: year,
    );
  }

  factory SubscriptionTrendsModel.fromEntity(SubscriptionTrends entity) {
    return SubscriptionTrendsModel(
      trends: entity.trends
          .map((t) => SubscriptionTrendModel.fromEntity(t))
          .toList(),
      year: entity.year,
    );
  }
}
