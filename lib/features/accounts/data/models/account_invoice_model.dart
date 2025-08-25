import 'package:json_annotation/json_annotation.dart';

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
}
