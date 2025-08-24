import 'package:equatable/equatable.dart';

class AccountPayment extends Equatable {
  final String id;
  final String accountId;
  final String paymentType;
  final String paymentStatus;
  final double amount;
  final String currency;
  final String paymentMethodId;
  final String? paymentMethodName;
  final String? paymentMethodType;
  final String? transactionId;
  final String? referenceNumber;
  final String? description;
  final String? notes;
  final DateTime paymentDate;
  final DateTime? processedDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  final String? failureReason;
  final String? gatewayResponse;
  final bool isRefunded;
  final double? refundedAmount;
  final DateTime? refundedDate;
  final String? refundReason;

  const AccountPayment({
    required this.id,
    required this.accountId,
    required this.paymentType,
    required this.paymentStatus,
    required this.amount,
    required this.currency,
    required this.paymentMethodId,
    this.paymentMethodName,
    this.paymentMethodType,
    this.transactionId,
    this.referenceNumber,
    this.description,
    this.notes,
    required this.paymentDate,
    this.processedDate,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
    this.failureReason,
    this.gatewayResponse,
    required this.isRefunded,
    this.refundedAmount,
    this.refundedDate,
    this.refundReason,
  });

  /// Factory constructor for creating new payments
  factory AccountPayment.create({
    required String accountId,
    required String paymentMethodId,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    String? description,
    Map<String, dynamic>? properties,
  }) {
    return AccountPayment(
      id: '', // Will be assigned by the server
      accountId: accountId,
      paymentType: transactionType,
      paymentStatus: 'PENDING', // New payments start as pending
      amount: amount,
      currency: currency,
      paymentMethodId: paymentMethodId,
      paymentDate: effectiveDate,
      createdAt: DateTime.now(),
      isRefunded: false,
      description: description,
      metadata: properties,
    );
  }

  @override
  List<Object?> get props => [
        id,
        accountId,
        paymentType,
        paymentStatus,
        amount,
        currency,
        paymentMethodId,
        paymentMethodName,
        paymentMethodType,
        transactionId,
        referenceNumber,
        description,
        notes,
        paymentDate,
        processedDate,
        createdAt,
        updatedAt,
        metadata,
        failureReason,
        gatewayResponse,
        isRefunded,
        refundedAmount,
        refundedDate,
        refundReason,
      ];

  AccountPayment copyWith({
    String? id,
    String? accountId,
    String? paymentType,
    String? paymentStatus,
    double? amount,
    String? currency,
    String? paymentMethodId,
    String? paymentMethodName,
    String? paymentMethodType,
    String? transactionId,
    String? referenceNumber,
    String? description,
    String? notes,
    DateTime? paymentDate,
    DateTime? processedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    String? failureReason,
    String? gatewayResponse,
    bool? isRefunded,
    double? refundedAmount,
    DateTime? refundedDate,
    String? refundReason,
  }) {
    return AccountPayment(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      paymentType: paymentType ?? this.paymentType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      paymentDate: paymentDate ?? this.paymentDate,
      processedDate: processedDate ?? this.processedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      failureReason: failureReason ?? this.failureReason,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      isRefunded: isRefunded ?? this.isRefunded,
      refundedAmount: refundedAmount ?? this.refundedAmount,
      refundedDate: refundedDate ?? this.refundedDate,
      refundReason: refundReason ?? this.refundReason,
    );
  }
}
