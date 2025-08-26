class SubscriptionEvent {
  final String eventId;
  final String billingPeriod;
  final DateTime effectiveDate;
  final DateTime catalogEffectiveDate;
  final String plan;
  final String product;
  final String priceList;
  final String eventType;
  final bool isBlockedBilling;
  final bool isBlockedEntitlement;
  final String serviceName;
  final String serviceStateName;
  final String phase;
  final List<Map<String, dynamic>>? auditLogs;

  const SubscriptionEvent({
    required this.eventId,
    required this.billingPeriod,
    required this.effectiveDate,
    required this.catalogEffectiveDate,
    required this.plan,
    required this.product,
    required this.priceList,
    required this.eventType,
    required this.isBlockedBilling,
    required this.isBlockedEntitlement,
    required this.serviceName,
    required this.serviceStateName,
    required this.phase,
    this.auditLogs,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionEvent &&
        other.eventId == eventId;
  }

  @override
  int get hashCode => eventId.hashCode;

  @override
  String toString() {
    return 'SubscriptionEvent(eventId: $eventId, eventType: $eventType, serviceName: $serviceName)';
  }
}
