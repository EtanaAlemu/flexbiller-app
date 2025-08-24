import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_invoice_payment.dart';

part 'account_invoice_payment_model.g.dart';

@JsonSerializable()
class AccountInvoicePaymentModel {
  final String id;
  @JsonKey(name: 'accountId')
  final String accountId;
  @JsonKey(name: 'invoiceId')
  final String invoiceId;
  @JsonKey(name: 'invoiceNumber')
  final String invoiceNumber;
  final double amount;
  final String currency;
  @JsonKey(name: 'paymentMethod')
  final String paymentMethod;
  final String status;
  @JsonKey(name: 'paymentDate')
  final DateTime paymentDate;
  @JsonKey(name: 'processedDate')
  final DateTime? processedDate;
  @JsonKey(name: 'transactionId')
  final String? transactionId;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const AccountInvoicePaymentModel({
    required this.id,
    required this.accountId,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
    this.processedDate,
    this.transactionId,
    this.notes,
    this.metadata,
  });

  factory AccountInvoicePaymentModel.fromJson(Map<String, dynamic> json) =>
      _$AccountInvoicePaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountInvoicePaymentModelToJson(this);

  factory AccountInvoicePaymentModel.fromEntity(AccountInvoicePayment entity) {
    return AccountInvoicePaymentModel(
      id: entity.id,
      accountId: entity.accountId,
      invoiceId: entity.invoiceId,
      invoiceNumber: entity.invoiceNumber,
      amount: entity.amount,
      currency: entity.currency,
      paymentMethod: entity.paymentMethod,
      status: entity.status,
      paymentDate: entity.paymentDate,
      processedDate: entity.processedDate,
      transactionId: entity.transactionId,
      notes: entity.notes,
      metadata: entity.metadata,
    );
  }

  AccountInvoicePayment toEntity() {
    return AccountInvoicePayment(
      id: id,
      accountId: accountId,
      invoiceId: invoiceId,
      invoiceNumber: invoiceNumber,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      status: status,
      paymentDate: paymentDate,
      processedDate: processedDate,
      transactionId: transactionId,
      notes: notes,
      metadata: metadata,
    );
  }
}
