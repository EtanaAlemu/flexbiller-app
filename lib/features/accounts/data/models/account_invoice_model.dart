import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account_invoice.dart';

part 'account_invoice_model.g.dart';

@JsonSerializable()
class AccountInvoiceModel {
  @JsonKey(name: 'invoiceId')
  final String invoiceId;
  
  @JsonKey(name: 'invoiceNumber')
  final String invoiceNumber;
  
  @JsonKey(name: 'accountId')
  final String accountId;
  
  @JsonKey(name: 'amount')
  final double amount;
  
  @JsonKey(name: 'currency')
  final String currency;
  
  @JsonKey(name: 'status')
  final String status;
  
  @JsonKey(name: 'balance')
  final double balance;
  
  @JsonKey(name: 'creditAdj')
  final double creditAdj;
  
  @JsonKey(name: 'refundAdj')
  final double refundAdj;
  
  @JsonKey(name: 'invoiceDate')
  final String invoiceDate;
  
  @JsonKey(name: 'targetDate')
  final String targetDate;
  
  @JsonKey(name: 'bundleKeys')
  final List<String>? bundleKeys;
  
  @JsonKey(name: 'credits')
  final List<Map<String, dynamic>>? credits;
  
  @JsonKey(name: 'items')
  final List<Map<String, dynamic>> items;
  
  @JsonKey(name: 'trackingIds')
  final List<String> trackingIds;
  
  @JsonKey(name: 'isParentInvoice')
  final bool isParentInvoice;
  
  @JsonKey(name: 'parentInvoiceId')
  final String? parentInvoiceId;
  
  @JsonKey(name: 'parentAccountId')
  final String? parentAccountId;
  
  @JsonKey(name: 'auditLogs')
  final List<Map<String, dynamic>> auditLogs;

  const AccountInvoiceModel({
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

  factory AccountInvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$AccountInvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountInvoiceModelToJson(this);

  // Convert from domain entity to data model
  factory AccountInvoiceModel.fromEntity(AccountInvoice entity) {
    return AccountInvoiceModel(
      invoiceId: entity.invoiceId,
      invoiceNumber: entity.invoiceNumber,
      accountId: entity.accountId,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      balance: entity.balance,
      creditAdj: entity.creditAdj,
      refundAdj: entity.refundAdj,
      invoiceDate: entity.invoiceDate,
      targetDate: entity.targetDate,
      bundleKeys: entity.bundleKeys,
      credits: entity.credits,
      items: entity.items,
      trackingIds: entity.trackingIds,
      isParentInvoice: entity.isParentInvoice,
      parentInvoiceId: entity.parentInvoiceId,
      parentAccountId: entity.parentAccountId,
      auditLogs: entity.auditLogs
          .map((log) => {
                'changeType': log.changeType,
                'changeDate': log.changeDate.toIso8601String(),
                'changedBy': log.changedBy,
                'reasonCode': log.reasonCode,
                'comments': log.comments,
                'objectType': log.objectType,
                'userToken': log.userToken,
              })
          .toList(),
    );
  }

  // Convert from data model to domain entity
  AccountInvoice toEntity() {
    return AccountInvoice(
      invoiceId: invoiceId,
      invoiceNumber: invoiceNumber,
      accountId: accountId,
      amount: amount,
      currency: currency,
      status: status,
      balance: balance,
      creditAdj: creditAdj,
      refundAdj: refundAdj,
      invoiceDate: invoiceDate,
      targetDate: targetDate,
      bundleKeys: bundleKeys,
      credits: credits,
      items: items,
      trackingIds: trackingIds,
      isParentInvoice: isParentInvoice,
      parentInvoiceId: parentInvoiceId,
      parentAccountId: parentAccountId,
      auditLogs: auditLogs
          .map((log) => InvoiceAuditLog(
                changeType: log['changeType'] ?? '',
                changeDate: DateTime.tryParse(log['changeDate'] ?? '') ?? DateTime.now(),
                changedBy: log['changedBy'] ?? '',
                reasonCode: log['reasonCode'],
                comments: log['comments'],
                objectType: log['objectType'],
                userToken: log['userToken'],
              ))
          .toList(),
    );
  }
}
