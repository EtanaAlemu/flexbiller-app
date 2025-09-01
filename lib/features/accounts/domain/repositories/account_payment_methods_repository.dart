import '../entities/account_payment_method.dart';

abstract class AccountPaymentMethodsRepository {
  /// Stream of payment methods for reactive UI updates
  Stream<List<AccountPaymentMethod>> get accountPaymentMethodsStream;

  /// Get all payment methods for a specific account
  Future<List<AccountPaymentMethod>> getAccountPaymentMethods(String accountId);

  /// Get a specific payment method by ID
  Future<AccountPaymentMethod> getAccountPaymentMethod(
    String accountId,
    String paymentMethodId,
  );

  /// Get the default payment method for an account
  Future<AccountPaymentMethod?> getDefaultPaymentMethod(String accountId);

  /// Get active payment methods for an account
  Future<List<AccountPaymentMethod>> getActivePaymentMethods(String accountId);

  /// Get payment methods by type
  Future<List<AccountPaymentMethod>> getPaymentMethodsByType(
    String accountId,
    String type,
  );

  /// Set a payment method as default
  Future<AccountPaymentMethod> setDefaultPaymentMethod(
    String accountId,
    String paymentMethodId,
    bool payAllUnpaidInvoices,
  );

  /// Create a new payment method
  Future<AccountPaymentMethod> createPaymentMethod(
    String accountId,
    String paymentMethodType,
    String paymentMethodName,
    Map<String, dynamic> paymentDetails,
  );

  /// Update an existing payment method
  Future<AccountPaymentMethod> updatePaymentMethod(
    String accountId,
    String paymentMethodId,
    Map<String, dynamic> updates,
  );

  /// Delete a payment method
  Future<void> deletePaymentMethod(String accountId, String paymentMethodId);

  /// Deactivate a payment method
  Future<AccountPaymentMethod> deactivatePaymentMethod(
    String accountId,
    String paymentMethodId,
  );

  /// Reactivate a payment method
  Future<AccountPaymentMethod> reactivatePaymentMethod(
    String accountId,
    String paymentMethodId,
  );

  /// Refresh payment methods for an account (sync with external processors)
  Future<List<AccountPaymentMethod>> refreshPaymentMethods(String accountId);
}
