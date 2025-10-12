import 'bundle_event.dart';

class BundleTimeline {
  final String accountId;
  final String bundleId;
  final String externalKey;
  final List<BundleEvent> events;
  final List<Map<String, dynamic>> auditLogs;

  const BundleTimeline({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.events,
    required this.auditLogs,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BundleTimeline && other.bundleId == bundleId;
  }

  @override
  int get hashCode => bundleId.hashCode;

  @override
  String toString() {
    return 'BundleTimeline(bundleId: $bundleId, eventsCount: ${events.length})';
  }
}
