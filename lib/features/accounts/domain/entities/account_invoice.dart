import 'package:equatable/equatable.dart';

class AccountInvoice extends Equatable {
  final String invoiceId;
  final String invoiceNumber;
  final String accountId;
  final double amount;
  final String currency;
  final String status;
  final double balance;
  final double creditAdj;
  final double refundAdj;
  final String invoiceDate;
  final String targetDate;
  final List<String>? bundleKeys;
  final List<Map<String, dynamic>>? credits;
  final List<Map<String, dynamic>> items;
  final List<String> trackingIds;
  final bool isParentInvoice;
  final String? parentInvoiceId;
  final String? parentAccountId;
  final List<InvoiceAuditLog> auditLogs;

  const AccountInvoice({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.balance,
    required this.creditAdj,
    required this.refundAdj,
    required this.invoiceDate,
    required this.targetDate,
    this.bundleKeys,
    this.credits,
    required this.items,
    required this.trackingIds,
    required this.isParentInvoice,
    this.parentInvoiceId,
    this.parentAccountId,
    required this.auditLogs,
  });

  @override
  List<Object?> get props => [
        invoiceId,
        invoiceNumber,
        accountId,
        amount,
        currency,
        status,
        balance,
        creditAdj,
        refundAdj,
        invoiceDate,
        targetDate,
        bundleKeys,
        credits,
        items,
        trackingIds,
        isParentInvoice,
        parentInvoiceId,
        parentAccountId,
        auditLogs,
      ];
}

class InvoiceAuditLog extends Equatable {
  final String changeType;
  final DateTime changeDate;
  final String changedBy;
  final String? reasonCode;
  final String? comments;
  final String? objectType;
  final String? userToken;

  const InvoiceAuditLog({
    required this.changeType,
    required this.changeDate,
    required this.changedBy,
    this.reasonCode,
    this.comments,
    this.objectType,
    this.userToken,
  });

  @override
  List<Object?> get props => [
        changeType,
        changeDate,
        changedBy,
        reasonCode,
        comments,
        objectType,
        userToken,
      ];
}
