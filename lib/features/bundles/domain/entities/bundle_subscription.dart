import 'bundle_event.dart';

class BundleSubscription {
  final String accountId;
  final String bundleId;
  final String bundleExternalKey;
  final String subscriptionId;
  final String externalKey;
  final DateTime startDate;
  final String productName;
  final String productCategory;
  final String billingPeriod;
  final String phaseType;
  final String priceList;
  final String planName;
  final String state;
  final String sourceType;
  final DateTime? cancelledDate;
  final String chargedThroughDate;
  final DateTime billingStartDate;
  final DateTime? billingEndDate;
  final int billCycleDayLocal;
  final int quantity;
  final List<BundleEvent> events;
  final dynamic priceOverrides;
  final List<dynamic> prices;
  final List<Map<String, dynamic>>? auditLogs;

  const BundleSubscription({
    required this.accountId,
    required this.bundleId,
    required this.bundleExternalKey,
    required this.subscriptionId,
    required this.externalKey,
    required this.startDate,
    required this.productName,
    required this.productCategory,
    required this.billingPeriod,
    required this.phaseType,
    required this.priceList,
    required this.planName,
    required this.state,
    required this.sourceType,
    this.cancelledDate,
    required this.chargedThroughDate,
    required this.billingStartDate,
    this.billingEndDate,
    required this.billCycleDayLocal,
    required this.quantity,
    required this.events,
    this.priceOverrides,
    required this.prices,
    this.auditLogs,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BundleSubscription &&
        other.subscriptionId == subscriptionId;
  }

  @override
  int get hashCode => subscriptionId.hashCode;

  @override
  String toString() {
    return 'BundleSubscription(subscriptionId: $subscriptionId, productName: $productName, state: $state)';
  }
}
