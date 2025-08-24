import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_timeline.dart';
import 'account_model.dart';

part 'account_timeline_model.g.dart';

@JsonSerializable()
class AccountTimelineModel {
  final AccountModel account;
  final List<BundleModel> bundles;
  final List<InvoiceModel> invoices;
  final List<PaymentModel> payments;

  const AccountTimelineModel({
    required this.account,
    required this.bundles,
    required this.invoices,
    required this.payments,
  });

  factory AccountTimelineModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTimelineModelToJson(this);

  factory AccountTimelineModel.fromEntity(AccountTimeline entity) {
    // This is a legacy method - the new structure is more complex
    return AccountTimelineModel(
      account: AccountModel(
        accountId: entity.accountId,
        name: '',
        email: '',
        currency: 'USD',
        timeZone: 'UTC',
        country: 'US',
        state: '',
        address1: '',
        address2: '',
        city: '',
        company: '',
        phone: '',
        notes: '',
        externalKey: '',
        firstNameLength: null,
        billCycleDayLocal: 0,
        parentAccountId: null,
        isPaymentDelegatedToParent: false,
        paymentMethodId: null,
        referenceTime: DateTime.now(),
        postalCode: null,
        locale: null,
        isMigrated: null,
        accountBalance: null,
        accountCBA: null,
        auditLogs: const [],
      ),
      bundles: const [],
      invoices: const [],
      payments: const [],
    );
  }

  AccountTimeline toEntity() {
    // Convert the comprehensive timeline to a simplified timeline for backward compatibility
    final List<TimelineEvent> events = [];

    // Add bundle events
    for (final bundle in bundles) {
      for (final subscription in bundle.subscriptions) {
        for (final event in subscription.events) {
          events.add(
            TimelineEvent(
              id: event.eventId,
              eventType: event.eventType.toLowerCase(),
              title: '${event.product} - ${event.eventType}',
              description: '${event.plan} (${event.billingPeriod})',
              timestamp: DateTime.parse(event.effectiveDate),
              metadata: {
                'bundleId': bundle.bundleId,
                'subscriptionId': subscription.subscriptionId,
                'product': event.product,
                'plan': event.plan,
                'billingPeriod': event.billingPeriod,
                'phase': event.phase,
                'serviceName': event.serviceName,
                'serviceStateName': event.serviceStateName,
              },
            ),
          );
        }
      }
    }

    // Add invoice events
    for (final invoice in invoices) {
      events.add(
        TimelineEvent(
          id: invoice.invoiceId,
          eventType: 'invoice_created',
          title: 'Invoice #${invoice.invoiceNumber}',
          description:
              '${invoice.currency} ${invoice.amount} - ${invoice.status}',
          timestamp: DateTime.parse(invoice.invoiceDate),
          metadata: {
            'invoiceId': invoice.invoiceId,
            'amount': invoice.amount,
            'currency': invoice.currency,
            'status': invoice.status,
            'balance': invoice.balance,
            'bundleKeys': invoice.bundleKeys,
          },
        ),
      );
    }

    // Add payment events
    for (final payment in payments) {
      events.add(
        TimelineEvent(
          id: payment.paymentId,
          eventType: 'payment_received',
          title: 'Payment Received',
          description: '${payment.currency} ${payment.amount}',
          timestamp: DateTime.parse(payment.paymentDate),
          metadata: {
            'paymentId': payment.paymentId,
            'amount': payment.amount,
            'currency': payment.currency,
            'status': payment.status,
            'paymentMethodId': payment.paymentMethodId,
          },
        ),
      );
    }

    // Sort events by timestamp (newest first)
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return AccountTimeline(
      id: account.accountId,
      accountId: account.accountId,
      events: events,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

@JsonSerializable()
class BundleModel {
  final String accountId;
  final String bundleId;
  final String externalKey;
  final List<SubscriptionModel> subscriptions;
  final TimelineModel timeline;
  final List<dynamic> auditLogs;

  const BundleModel({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.subscriptions,
    required this.timeline,
    required this.auditLogs,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) =>
      _$BundleModelFromJson(json);

  Map<String, dynamic> toJson() => _$BundleModelToJson(this);
}

@JsonSerializable()
class SubscriptionModel {
  final String accountId;
  final String bundleId;
  final String bundleExternalKey;
  final String subscriptionId;
  final String externalKey;
  final String startDate;
  final String productName;
  final String productCategory;
  final String billingPeriod;
  final String phaseType;
  final String priceList;
  final String planName;
  final String state;
  final String sourceType;
  final String? cancelledDate;
  final String chargedThroughDate;
  final String billingStartDate;
  final String? billingEndDate;
  final int billCycleDayLocal;
  final int quantity;
  final List<SubscriptionEventModel> events;
  final dynamic priceOverrides;
  final List<PriceModel> prices;
  final List<dynamic> auditLogs;

  const SubscriptionModel({
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

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);
}

@JsonSerializable()
class SubscriptionEventModel {
  final String eventId;
  final String billingPeriod;
  final String effectiveDate;
  final String catalogEffectiveDate;
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

  const SubscriptionEventModel({
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

  factory SubscriptionEventModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionEventModelToJson(this);
}

@JsonSerializable()
class PriceModel {
  final String planName;
  final String phaseName;
  final String phaseType;
  final double? fixedPrice;
  final double? recurringPrice;
  final List<dynamic> usagePrices;

  const PriceModel({
    required this.planName,
    required this.phaseName,
    required this.phaseType,
    this.fixedPrice,
    this.recurringPrice,
    required this.usagePrices,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) =>
      _$PriceModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceModelToJson(this);
}

@JsonSerializable()
class TimelineModel {
  final String accountId;
  final String bundleId;
  final String externalKey;
  final List<SubscriptionEventModel> events;
  final List<dynamic> auditLogs;

  const TimelineModel({
    required this.accountId,
    required this.bundleId,
    required this.externalKey,
    required this.events,
    required this.auditLogs,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineModelToJson(this);
}

@JsonSerializable()
class InvoiceModel {
  final double amount;
  final String currency;
  final String status;
  final double creditAdj;
  final double refundAdj;
  final String invoiceId;
  final String invoiceDate;
  final String targetDate;
  final String invoiceNumber;
  final double balance;
  final String accountId;
  final String bundleKeys;
  final List<dynamic> credits;
  final dynamic items;
  final dynamic trackingIds;
  final bool isParentInvoice;
  final String? parentInvoiceId;
  final String? parentAccountId;
  final List<dynamic> auditLogs;

  const InvoiceModel({
    required this.amount,
    required this.currency,
    required this.status,
    required this.creditAdj,
    required this.refundAdj,
    required this.invoiceId,
    required this.invoiceDate,
    required this.targetDate,
    required this.invoiceNumber,
    required this.balance,
    required this.accountId,
    required this.bundleKeys,
    required this.credits,
    this.items,
    this.trackingIds,
    required this.isParentInvoice,
    this.parentInvoiceId,
    this.parentAccountId,
    required this.auditLogs,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceModelToJson(this);
}

@JsonSerializable()
class PaymentModel {
  final String paymentId;
  final String accountId;
  final double amount;
  final String currency;
  final String status;
  final String paymentDate;
  final String? paymentMethodId;
  final String? description;
  final Map<String, dynamic>? metadata;

  const PaymentModel({
    required this.paymentId,
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentDate,
    this.paymentMethodId,
    this.description,
    this.metadata,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}

// Legacy TimelineEventModel for backward compatibility
@JsonSerializable()
class TimelineEventModel {
  final String id;
  final String eventType;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final Map<String, dynamic>? metadata;
  final String? icon;
  final String? color;

  const TimelineEventModel({
    required this.id,
    required this.eventType,
    required this.title,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
    this.userEmail,
    this.metadata,
    this.icon,
    this.color,
  });

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineEventModelToJson(this);

  factory TimelineEventModel.fromEntity(TimelineEvent entity) {
    return TimelineEventModel(
      id: entity.id,
      eventType: entity.eventType,
      title: entity.title,
      description: entity.description,
      timestamp: entity.timestamp,
      userId: entity.userId,
      userName: entity.userName,
      userEmail: entity.userEmail,
      metadata: entity.metadata,
      icon: entity.icon,
      color: entity.color,
    );
  }

  TimelineEvent toEntity() {
    return TimelineEvent(
      id: id,
      eventType: eventType,
      title: title,
      description: description,
      timestamp: timestamp,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      metadata: metadata,
      icon: icon,
      color: color,
    );
  }
}
