import 'bundle_subscription.dart';
import 'bundle_timeline.dart';

class Bundle {
  final String accountId;
  final String bundleId;
  final String externalKey;
  final List<BundleSubscription> subscriptions;
  final BundleTimeline timeline;
  final List<Map<String, dynamic>>? auditLogs;

  const Bundle({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.subscriptions,
    required this.timeline,
    this.auditLogs,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bundle && other.bundleId == bundleId;
  }

  @override
  int get hashCode => bundleId.hashCode;

  @override
  String toString() {
    return 'Bundle(bundleId: $bundleId, subscriptionsCount: ${subscriptions.length})';
  }
}
