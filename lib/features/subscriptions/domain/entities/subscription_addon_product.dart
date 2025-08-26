import 'package:equatable/equatable.dart';

class SubscriptionAddonProduct extends Equatable {
  final String accountId;
  final String productName;
  final String productCategory;
  final String billingPeriod;
  final String priceList;

  const SubscriptionAddonProduct({
    required this.accountId,
    required this.productName,
    required this.productCategory,
    required this.billingPeriod,
    required this.priceList,
  });

  @override
  List<Object?> get props => [
        accountId,
        productName,
        productCategory,
        billingPeriod,
        priceList,
      ];

  @override
  String toString() {
    return 'SubscriptionAddonProduct(productName: $productName, productCategory: $productCategory, billingPeriod: $billingPeriod)';
  }

  SubscriptionAddonProduct copyWith({
    String? accountId,
    String? productName,
    String? productCategory,
    String? billingPeriod,
    String? priceList,
  }) {
    return SubscriptionAddonProduct(
      accountId: accountId ?? this.accountId,
      productName: productName ?? this.productName,
      productCategory: productCategory ?? this.productCategory,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      priceList: priceList ?? this.priceList,
    );
  }
}
