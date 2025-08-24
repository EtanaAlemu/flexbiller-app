import 'package:equatable/equatable.dart';

class AccountInvoicePayment extends Equatable {
  final String id;
  final String accountId;
  final String invoiceId;
  final String invoiceNumber;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final DateTime paymentDate;
  final DateTime? processedDate;
  final String? transactionId;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const AccountInvoicePayment({
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

  @override
  List<Object?> get props => [
        id,
        accountId,
        invoiceId,
        invoiceNumber,
        amount,
        currency,
        paymentMethod,
        status,
        paymentDate,
        processedDate,
        transactionId,
        notes,
        metadata,
      ];

  AccountInvoicePayment copyWith({
    String? id,
    String? accountId,
    String? invoiceId,
    String? invoiceNumber,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? status,
    DateTime? paymentDate,
    DateTime? processedDate,
    String? transactionId,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return AccountInvoicePayment(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      processedDate: processedDate ?? this.processedDate,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }
}
