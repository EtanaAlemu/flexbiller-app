import 'payment_transaction.dart';

class Payment {
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
  final List<PaymentTransaction> transactions;
  final List<Map<String, dynamic>>? paymentAttempts;
  final List<Map<String, dynamic>> auditLogs;

  const Payment({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment &&
        other.accountId == accountId &&
        other.paymentId == paymentId &&
        other.paymentNumber == paymentNumber &&
        other.paymentExternalKey == paymentExternalKey &&
        other.authAmount == authAmount &&
        other.capturedAmount == capturedAmount &&
        other.purchasedAmount == purchasedAmount &&
        other.refundedAmount == refundedAmount &&
        other.creditedAmount == creditedAmount &&
        other.currency == currency &&
        other.paymentMethodId == paymentMethodId &&
        _listEquals(other.transactions, transactions) &&
        _listEquals(other.paymentAttempts, paymentAttempts) &&
        _listEquals(other.auditLogs, auditLogs);
  }

  @override
  int get hashCode {
    return accountId.hashCode ^
        paymentId.hashCode ^
        paymentNumber.hashCode ^
        paymentExternalKey.hashCode ^
        authAmount.hashCode ^
        capturedAmount.hashCode ^
        purchasedAmount.hashCode ^
        refundedAmount.hashCode ^
        creditedAmount.hashCode ^
        currency.hashCode ^
        paymentMethodId.hashCode ^
        transactions.hashCode ^
        paymentAttempts.hashCode ^
        auditLogs.hashCode;
  }

  @override
  String toString() {
    return 'Payment(accountId: $accountId, paymentId: $paymentId, paymentNumber: $paymentNumber, paymentExternalKey: $paymentExternalKey, authAmount: $authAmount, capturedAmount: $capturedAmount, purchasedAmount: $purchasedAmount, refundedAmount: $refundedAmount, creditedAmount: $creditedAmount, currency: $currency, paymentMethodId: $paymentMethodId, transactions: $transactions, paymentAttempts: $paymentAttempts, auditLogs: $auditLogs)';
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
