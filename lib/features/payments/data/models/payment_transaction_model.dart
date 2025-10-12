import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_transaction.dart';

part 'payment_transaction_model.g.dart';

@JsonSerializable()
class PaymentTransactionModel {
  final String transactionId;
  final String transactionExternalKey;
  final String paymentId;
  final String paymentExternalKey;
  final String transactionType;
  final double amount;
  final String currency;
  final DateTime effectiveDate;
  final double processedAmount;
  final String processedCurrency;
  final String status;
  final String? gatewayErrorCode;
  final String? gatewayErrorMsg;
  final String? firstPaymentReferenceId;
  final String? secondPaymentReferenceId;
  final Map<String, dynamic>? properties;
  final List<Map<String, dynamic>> auditLogs;

  const PaymentTransactionModel({
    required this.transactionId,
    required this.transactionExternalKey,
    required this.paymentId,
    required this.paymentExternalKey,
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
    required this.auditLogs,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentTransactionModelToJson(this);

  factory PaymentTransactionModel.fromEntity(PaymentTransaction entity) {
    return PaymentTransactionModel(
      transactionId: entity.transactionId,
      transactionExternalKey: entity.transactionExternalKey,
      paymentId: entity.paymentId,
      paymentExternalKey: entity.paymentExternalKey,
      transactionType: entity.transactionType,
      amount: entity.amount,
      currency: entity.currency,
      effectiveDate: entity.effectiveDate,
      processedAmount: entity.processedAmount,
      processedCurrency: entity.processedCurrency,
      status: entity.status,
      gatewayErrorCode: entity.gatewayErrorCode,
      gatewayErrorMsg: entity.gatewayErrorMsg,
      firstPaymentReferenceId: entity.firstPaymentReferenceId,
      secondPaymentReferenceId: entity.secondPaymentReferenceId,
      properties: entity.properties,
      auditLogs: entity.auditLogs,
    );
  }

  PaymentTransaction toEntity() {
    return PaymentTransaction(
      transactionId: transactionId,
      transactionExternalKey: transactionExternalKey,
      paymentId: paymentId,
      paymentExternalKey: paymentExternalKey,
      transactionType: transactionType,
      amount: amount,
      currency: currency,
      effectiveDate: effectiveDate,
      processedAmount: processedAmount,
      processedCurrency: processedCurrency,
      status: status,
      gatewayErrorCode: gatewayErrorCode,
      gatewayErrorMsg: gatewayErrorMsg,
      firstPaymentReferenceId: firstPaymentReferenceId,
      secondPaymentReferenceId: secondPaymentReferenceId,
      properties: properties,
      auditLogs: auditLogs,
    );
  }
}
