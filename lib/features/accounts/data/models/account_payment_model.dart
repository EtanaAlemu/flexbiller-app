import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_payment.dart';

part 'account_payment_model.g.dart';

@JsonSerializable()
class PaymentTransactionModel {
  @JsonKey(name: 'transactionId')
  final String transactionId;
  @JsonKey(name: 'transactionExternalKey')
  final String? transactionExternalKey;
  @JsonKey(name: 'paymentId')
  final String paymentId;
  @JsonKey(name: 'paymentExternalKey')
  final String? paymentExternalKey;
  @JsonKey(name: 'transactionType')
  final String transactionType;
  final double amount;
  final String currency;
  @JsonKey(name: 'effectiveDate')
  final DateTime effectiveDate;
  @JsonKey(name: 'processedAmount')
  final double processedAmount;
  @JsonKey(name: 'processedCurrency')
  final String processedCurrency;
  final String status;
  @JsonKey(name: 'gatewayErrorCode')
  final String? gatewayErrorCode;
  @JsonKey(name: 'gatewayErrorMsg')
  final String? gatewayErrorMsg;
  @JsonKey(name: 'firstPaymentReferenceId')
  final String? firstPaymentReferenceId;
  @JsonKey(name: 'secondPaymentReferenceId')
  final String? secondPaymentReferenceId;
  final Map<String, dynamic>? properties;
  @JsonKey(name: 'auditLogs')
  final List<dynamic>? auditLogs;

  const PaymentTransactionModel({
    required this.transactionId,
    this.transactionExternalKey,
    required this.paymentId,
    this.paymentExternalKey,
    required this.transactionType,
    required this.amount,
    required this.currency,
    required this.effectiveDate,
    required this.processedAmount,
    required this.processedCurrency,
    required this.status,
    this.gatewayErrorCode,
    this.gatewayErrorMsg,
    this.firstPaymentReferenceId,
    this.secondPaymentReferenceId,
    this.properties,
    this.auditLogs,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentTransactionModelToJson(this);
}

@JsonSerializable()
class AccountPaymentModel {
  @JsonKey(name: 'paymentId')
  final String id;
  @JsonKey(name: 'accountId')
  final String accountId;
  @JsonKey(name: 'paymentNumber')
  final String? paymentNumber;
  @JsonKey(name: 'paymentExternalKey')
  final String? paymentExternalKey;
  @JsonKey(name: 'authAmount')
  final double authAmount;
  @JsonKey(name: 'capturedAmount')
  final double capturedAmount;
  @JsonKey(name: 'purchasedAmount')
  final double purchasedAmount;
  @JsonKey(name: 'refundedAmount')
  final double refundedAmount;
  @JsonKey(name: 'creditedAmount')
  final double creditedAmount;
  final String currency;
  @JsonKey(name: 'paymentMethodId')
  final String paymentMethodId;
  @JsonKey(name: 'transactions')
  final List<PaymentTransactionModel> transactions;
  @JsonKey(name: 'paymentAttempts')
  final List<dynamic>? paymentAttempts;
  @JsonKey(name: 'auditLogs')
  final List<dynamic>? auditLogs;

  const AccountPaymentModel({
    required this.id,
    required this.accountId,
    this.paymentNumber,
    this.paymentExternalKey,
    required this.authAmount,
    required this.capturedAmount,
    required this.purchasedAmount,
    required this.refundedAmount,
    required this.creditedAmount,
    required this.currency,
    required this.paymentMethodId,
    required this.transactions,
    this.paymentAttempts,
    this.auditLogs,
  });

  factory AccountPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$AccountPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPaymentModelToJson(this);

  factory AccountPaymentModel.fromEntity(AccountPayment entity) {
    // Convert entity to model - this is a simplified conversion
    // In a real app, you might need to handle the transaction mapping differently
    return AccountPaymentModel(
      id: entity.id,
      accountId: entity.accountId,
      paymentNumber: entity.referenceNumber,
      paymentExternalKey: entity.id,
      authAmount: 0.0,
      capturedAmount: 0.0,
      purchasedAmount: entity.amount,
      refundedAmount: entity.refundedAmount ?? 0.0,
      creditedAmount: 0.0,
      currency: entity.currency,
      paymentMethodId: entity.paymentMethodId,
      transactions: [], // This would need to be populated from entity data
    );
  }

  AccountPayment toEntity() {
    // Get the first transaction for basic payment info
    final firstTransaction = transactions.isNotEmpty
        ? transactions.first
        : null;

    return AccountPayment(
      id: id,
      accountId: accountId,
      paymentType: firstTransaction?.transactionType ?? 'PURCHASE',
      paymentStatus: firstTransaction?.status ?? 'SUCCESS',
      amount: purchasedAmount,
      currency: currency,
      paymentMethodId: paymentMethodId,
      paymentMethodName: null,
      paymentMethodType: null,
      transactionId: firstTransaction?.transactionId,
      referenceNumber: paymentNumber,
      description: null,
      notes: null,
      paymentDate: firstTransaction?.effectiveDate ?? DateTime.now(),
      processedDate: firstTransaction?.effectiveDate,
      createdAt: firstTransaction?.effectiveDate ?? DateTime.now(),
      updatedAt: null,
      metadata: null,
      failureReason: firstTransaction?.gatewayErrorMsg,
      gatewayResponse: firstTransaction?.gatewayErrorCode,
      isRefunded: refundedAmount > 0,
      refundedAmount: refundedAmount > 0 ? refundedAmount : null,
      refundedDate: refundedAmount > 0 ? DateTime.now() : null,
      refundReason: null,
    );
  }
}
