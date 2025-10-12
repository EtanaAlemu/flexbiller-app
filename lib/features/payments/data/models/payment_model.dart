import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment.dart';
import 'payment_transaction_model.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final String accountId;
  final String paymentId;
  final String paymentNumber;
  final String paymentExternalKey;
  final double authAmount;
  final double capturedAmount;
  final double purchasedAmount;
  final double refundedAmount;
  final double creditedAmount;
  final String currency;
  final String paymentMethodId;
  final List<PaymentTransactionModel> transactions;
  final List<Map<String, dynamic>>? paymentAttempts;
  final List<Map<String, dynamic>> auditLogs;

  const PaymentModel({
    required this.accountId,
    required this.paymentId,
    required this.paymentNumber,
    required this.paymentExternalKey,
    required this.authAmount,
    required this.capturedAmount,
    required this.purchasedAmount,
    required this.refundedAmount,
    required this.creditedAmount,
    required this.currency,
    required this.paymentMethodId,
    required this.transactions,
    this.paymentAttempts,
    required this.auditLogs,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  factory PaymentModel.fromEntity(Payment entity) {
    return PaymentModel(
      accountId: entity.accountId,
      paymentId: entity.paymentId,
      paymentNumber: entity.paymentNumber,
      paymentExternalKey: entity.paymentExternalKey,
      authAmount: entity.authAmount,
      capturedAmount: entity.capturedAmount,
      purchasedAmount: entity.purchasedAmount,
      refundedAmount: entity.refundedAmount,
      creditedAmount: entity.creditedAmount,
      currency: entity.currency,
      paymentMethodId: entity.paymentMethodId,
      transactions: entity.transactions
          .map((transaction) => PaymentTransactionModel.fromEntity(transaction))
          .toList(),
      paymentAttempts: entity.paymentAttempts,
      auditLogs: entity.auditLogs,
    );
  }

  Payment toEntity() {
    return Payment(
      accountId: accountId,
      paymentId: paymentId,
      paymentNumber: paymentNumber,
      paymentExternalKey: paymentExternalKey,
      authAmount: authAmount,
      capturedAmount: capturedAmount,
      purchasedAmount: purchasedAmount,
      refundedAmount: refundedAmount,
      creditedAmount: creditedAmount,
      currency: currency,
      paymentMethodId: paymentMethodId,
      transactions: transactions
          .map((transaction) => transaction.toEntity())
          .toList(),
      paymentAttempts: paymentAttempts,
      auditLogs: auditLogs,
    );
  }
}
