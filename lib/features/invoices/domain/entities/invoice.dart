import 'invoice_audit_log.dart';

class Invoice {
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
  final List<InvoiceAuditLog> auditLogs;

  const Invoice({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice &&
        other.amount == amount &&
        other.currency == currency &&
        other.status == status &&
        other.creditAdj == creditAdj &&
        other.refundAdj == refundAdj &&
        other.invoiceId == invoiceId &&
        other.invoiceDate == invoiceDate &&
        other.targetDate == targetDate &&
        other.invoiceNumber == invoiceNumber &&
        other.balance == balance &&
        other.accountId == accountId &&
        _listEquals(other.bundleKeys, bundleKeys) &&
        _listEquals(other.credits, credits) &&
        _listEquals(other.items, items) &&
        _listEquals(other.trackingIds, trackingIds) &&
        other.isParentInvoice == isParentInvoice &&
        other.parentInvoiceId == parentInvoiceId &&
        other.parentAccountId == parentAccountId &&
        _listEquals(other.auditLogs, auditLogs);
  }

  @override
  int get hashCode {
    return amount.hashCode ^
        currency.hashCode ^
        status.hashCode ^
        creditAdj.hashCode ^
        refundAdj.hashCode ^
        invoiceId.hashCode ^
        invoiceDate.hashCode ^
        targetDate.hashCode ^
        invoiceNumber.hashCode ^
        balance.hashCode ^
        accountId.hashCode ^
        bundleKeys.hashCode ^
        credits.hashCode ^
        items.hashCode ^
        trackingIds.hashCode ^
        isParentInvoice.hashCode ^
        parentInvoiceId.hashCode ^
        parentAccountId.hashCode ^
        auditLogs.hashCode;
  }

  @override
  String toString() {
    return 'Invoice(amount: $amount, currency: $currency, status: $status, creditAdj: $creditAdj, refundAdj: $refundAdj, invoiceId: $invoiceId, invoiceDate: $invoiceDate, targetDate: $targetDate, invoiceNumber: $invoiceNumber, balance: $balance, accountId: $accountId, bundleKeys: $bundleKeys, credits: $credits, items: $items, trackingIds: $trackingIds, isParentInvoice: $isParentInvoice, parentInvoiceId: $parentInvoiceId, parentAccountId: $parentAccountId, auditLogs: $auditLogs)';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

