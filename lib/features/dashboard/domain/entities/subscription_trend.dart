import 'package:equatable/equatable.dart';

class SubscriptionTrend extends Equatable {
  final String month;
  final int newSubscriptions;
  final int churnedSubscriptions;
  final double revenue;

  const SubscriptionTrend({
    required this.month,
    required this.newSubscriptions,
    required this.churnedSubscriptions,
    required this.revenue,
  });

  @override
  List<Object?> get props => [
    month,
    newSubscriptions,
    churnedSubscriptions,
    revenue,
  ];
}

class SubscriptionTrends extends Equatable {
  final List<SubscriptionTrend> trends;
  final int year;

  const SubscriptionTrends({required this.trends, required this.year});

  @override
  List<Object?> get props => [trends, year];
}
