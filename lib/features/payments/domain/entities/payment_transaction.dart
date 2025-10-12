class PaymentTransaction {
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

  const PaymentTransaction({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentTransaction &&
        other.transactionId == transactionId &&
        other.transactionExternalKey == transactionExternalKey &&
        other.paymentId == paymentId &&
        other.paymentExternalKey == paymentExternalKey &&
        other.transactionType == transactionType &&
        other.amount == amount &&
        other.currency == currency &&
        other.effectiveDate == effectiveDate &&
        other.processedAmount == processedAmount &&
        other.processedCurrency == processedCurrency &&
        other.status == status &&
        other.gatewayErrorCode == gatewayErrorCode &&
        other.gatewayErrorMsg == gatewayErrorMsg &&
        other.firstPaymentReferenceId == firstPaymentReferenceId &&
        other.secondPaymentReferenceId == secondPaymentReferenceId &&
        other.properties == properties &&
        _listEquals(other.auditLogs, auditLogs);
  }

  @override
  int get hashCode {
    return transactionId.hashCode ^
        transactionExternalKey.hashCode ^
        paymentId.hashCode ^
        paymentExternalKey.hashCode ^
        transactionType.hashCode ^
        amount.hashCode ^
        currency.hashCode ^
        effectiveDate.hashCode ^
        processedAmount.hashCode ^
        processedCurrency.hashCode ^
        status.hashCode ^
        gatewayErrorCode.hashCode ^
        gatewayErrorMsg.hashCode ^
        firstPaymentReferenceId.hashCode ^
        secondPaymentReferenceId.hashCode ^
        properties.hashCode ^
        auditLogs.hashCode;
  }

  @override
  String toString() {
    return 'PaymentTransaction(transactionId: $transactionId, transactionExternalKey: $transactionExternalKey, paymentId: $paymentId, paymentExternalKey: $paymentExternalKey, transactionType: $transactionType, amount: $amount, currency: $currency, effectiveDate: $effectiveDate, processedAmount: $processedAmount, processedCurrency: $processedCurrency, status: $status, gatewayErrorCode: $gatewayErrorCode, gatewayErrorMsg: $gatewayErrorMsg, firstPaymentReferenceId: $firstPaymentReferenceId, secondPaymentReferenceId: $secondPaymentReferenceId, properties: $properties, auditLogs: $auditLogs)';
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
