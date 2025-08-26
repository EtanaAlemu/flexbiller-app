import 'package:equatable/equatable.dart';

class SubscriptionBcdUpdate extends Equatable {
  final String accountId;
  final String bundleId;
  final String subscriptionId;
  final DateTime startDate;
  final String productName;
  final String productCategory;
  final String billingPeriod;
  final String priceList;
  final String phaseType;
  final int billCycleDayLocal;

  const SubscriptionBcdUpdate({
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

  @override
  List<Object?> get props => [
        accountId,
        bundleId,
        subscriptionId,
        startDate,
        productName,
        productCategory,
        billingPeriod,
        priceList,
        phaseType,
        billCycleDayLocal,
      ];

  @override
  String toString() {
    return 'SubscriptionBcdUpdate(productName: $productName, billCycleDayLocal: $billCycleDayLocal)';
  }

  SubscriptionBcdUpdate copyWith({
    String? accountId,
    String? bundleId,
    String? subscriptionId,
    DateTime? startDate,
    String? productName,
    String? productCategory,
    String? billingPeriod,
    String? priceList,
    String? phaseType,
    int? billCycleDayLocal,
  }) {
    return SubscriptionBcdUpdate(
      accountId: accountId ?? this.accountId,
      bundleId: bundleId ?? this.bundleId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      startDate: startDate ?? this.startDate,
      productName: productName ?? this.productName,
      productCategory: productCategory ?? this.productCategory,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      priceList: priceList ?? this.priceList,
      phaseType: phaseType ?? this.phaseType,
      billCycleDayLocal: billCycleDayLocal ?? this.billCycleDayLocal,
    );
  }
}
