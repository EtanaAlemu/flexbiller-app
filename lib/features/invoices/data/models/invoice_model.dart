import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/invoice.dart';
import 'invoice_audit_log_model.dart';

part 'invoice_model.g.dart';

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
  final List<String>? bundleKeys;
  final List<Map<String, dynamic>>? credits;
  final List<Map<String, dynamic>> items;
  final List<String> trackingIds;
  final bool isParentInvoice;
  final String? parentInvoiceId;
  final String? parentAccountId;
  final List<InvoiceAuditLogModel> auditLogs;

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
    this.bundleKeys,
    this.credits,
    required this.items,
    required this.trackingIds,
    required this.isParentInvoice,
    this.parentInvoiceId,
    this.parentAccountId,
    required this.auditLogs,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceModelToJson(this);

  factory InvoiceModel.fromEntity(Invoice entity) {
    return InvoiceModel(
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      creditAdj: entity.creditAdj,
      refundAdj: entity.refundAdj,
      invoiceId: entity.invoiceId,
      invoiceDate: entity.invoiceDate,
      targetDate: entity.targetDate,
      invoiceNumber: entity.invoiceNumber,
      balance: entity.balance,
      accountId: entity.accountId,
      bundleKeys: entity.bundleKeys,
      credits: entity.credits,
      items: entity.items,
      trackingIds: entity.trackingIds,
      isParentInvoice: entity.isParentInvoice,
      parentInvoiceId: entity.parentInvoiceId,
      parentAccountId: entity.parentAccountId,
      auditLogs: entity.auditLogs
          .map((auditLog) => InvoiceAuditLogModel.fromEntity(auditLog))
          .toList(),
    );
  }

  Invoice toEntity() {
    return Invoice(
      amount: amount,
      currency: currency,
      status: status,
      creditAdj: creditAdj,
      refundAdj: refundAdj,
      invoiceId: invoiceId,
      invoiceDate: invoiceDate,
      targetDate: targetDate,
      invoiceNumber: invoiceNumber,
      balance: balance,
      accountId: accountId,
      bundleKeys: bundleKeys,
      credits: credits,
      items: items,
      trackingIds: trackingIds,
      isParentInvoice: isParentInvoice,
      parentInvoiceId: parentInvoiceId,
      parentAccountId: parentAccountId,
      auditLogs: auditLogs.map((auditLog) => auditLog.toEntity()).toList(),
    );
  }
}

