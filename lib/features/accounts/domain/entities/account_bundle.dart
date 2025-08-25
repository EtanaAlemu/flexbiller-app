import 'package:equatable/equatable.dart';

class AccountBundle extends Equatable {
  final String accountId;
  final String bundleId;
  final String externalKey;
  final List<Subscription> subscriptions;
  final Timeline timeline;
  final List<dynamic> auditLogs;

  const AccountBundle({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.subscriptions,
    required this.timeline,
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [
        accountId,
        bundleId,
        externalKey,
        subscriptions,
        timeline,
        auditLogs,
      ];

  AccountBundle copyWith({
    String? accountId,
    String? bundleId,
    String? externalKey,
    List<Subscription>? subscriptions,
    Timeline? timeline,
    List<dynamic>? auditLogs,
  }) {
    return AccountBundle(
      accountId: accountId ?? this.accountId,
      bundleId: bundleId ?? this.bundleId,
      externalKey: externalKey ?? this.externalKey,
      subscriptions: subscriptions ?? this.subscriptions,
      timeline: timeline ?? this.timeline,
      auditLogs: auditLogs ?? this.auditLogs,
    );
  }
}

class Subscription extends Equatable {
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
  final DateTime chargedThroughDate;
  final DateTime billingStartDate;
  final DateTime? billingEndDate;
  final int billCycleDayLocal;
  final int quantity;
  final List<SubscriptionEvent> events;
  final dynamic priceOverrides;
  final List<Price> prices;
  final List<dynamic> auditLogs;

  const Subscription({
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
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [
        accountId,
        bundleId,
        bundleExternalKey,
        subscriptionId,
        externalKey,
        startDate,
        productName,
        productCategory,
        billingPeriod,
        phaseType,
        priceList,
        planName,
        state,
        sourceType,
        cancelledDate,
        chargedThroughDate,
        billingStartDate,
        billingEndDate,
        billCycleDayLocal,
        quantity,
        events,
        priceOverrides,
        prices,
        auditLogs,
      ];

  // Helper getters
  bool get isActive => state == 'ACTIVE';
  bool get isCancelled => cancelledDate != null;
  bool get isTrial => phaseType == 'TRIAL';
  bool get isEvergreen => phaseType == 'EVERGREEN';
}

class SubscriptionEvent extends Equatable {
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
  final List<dynamic> auditLogs;

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
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [
        eventId,
        billingPeriod,
        effectiveDate,
        catalogEffectiveDate,
        plan,
        product,
        priceList,
        eventType,
        isBlockedBilling,
        isBlockedEntitlement,
        serviceName,
        serviceStateName,
        phase,
        auditLogs,
      ];

  // Helper getters
  bool get isStartEvent => eventType == 'START_ENTITLEMENT' || eventType == 'START_BILLING';
  bool get isPhaseEvent => eventType == 'PHASE';
  bool get isServiceStateChange => eventType == 'SERVICE_STATE_CHANGE';
}

class Price extends Equatable {
  final String planName;
  final String phaseName;
  final String phaseType;
  final double? fixedPrice;
  final double? recurringPrice;
  final List<dynamic> usagePrices;

  const Price({
    required this.planName,
    required this.phaseName,
    required this.phaseType,
    this.fixedPrice,
    this.recurringPrice,
    required this.usagePrices,
  });

  @override
  List<Object?> get props => [
        planName,
        phaseName,
        phaseType,
        fixedPrice,
        recurringPrice,
        usagePrices,
      ];

  // Helper getters
  bool get isTrial => phaseType == 'TRIAL';
  bool get isEvergreen => phaseType == 'EVERGREEN';
  bool get hasFixedPrice => fixedPrice != null;
  bool get hasRecurringPrice => recurringPrice != null;
}

class Timeline extends Equatable {
  final String accountId;
  final String bundleId;
  final String externalKey;
  final List<SubscriptionEvent> events;
  final List<dynamic> auditLogs;

  const Timeline({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.events,
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [
        accountId,
        bundleId,
        externalKey,
        events,
        auditLogs,
      ];
}
