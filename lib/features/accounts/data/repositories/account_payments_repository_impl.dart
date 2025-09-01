import 'package:injectable/injectable.dart';
import '../../domain/entities/account_payment.dart';
import '../../domain/repositories/account_payments_repository.dart';
import '../datasources/remote/account_payments_remote_data_source.dart';

@Injectable(as: AccountPaymentsRepository)
class AccountPaymentsRepositoryImpl implements AccountPaymentsRepository {
  final AccountPaymentsRemoteDataSource _remoteDataSource;

  AccountPaymentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountPayment>> getAccountPayments(String accountId) async {
    try {
      final paymentModels = await _remoteDataSource.getAccountPayments(accountId);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPayment> getAccountPayment(String accountId, String paymentId) async {
    try {
      final paymentModel = await _remoteDataSource.getAccountPayment(accountId, paymentId);
      return paymentModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsByStatus(String accountId, String status) async {
    try {
      final paymentModels = await _remoteDataSource.getAccountPaymentsByStatus(accountId, status);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsByType(String accountId, String type) async {
    try {
      final paymentModels = await _remoteDataSource.getAccountPaymentsByType(accountId, type);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final paymentModels = await _remoteDataSource.getAccountPaymentsByDateRange(
        accountId,
        startDate,
        endDate,
      );
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final paymentModels = await _remoteDataSource.getAccountPaymentsWithPagination(
        accountId,
        page,
        pageSize,
      );
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAccountPaymentStatistics(String accountId) async {
    try {
      return await _remoteDataSource.getAccountPaymentStatistics(accountId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> searchAccountPayments(String accountId, String searchTerm) async {
    try {
      final paymentModels = await _remoteDataSource.searchAccountPayments(accountId, searchTerm);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getRefundedPayments(String accountId) async {
    try {
      final paymentModels = await _remoteDataSource.getRefundedPayments(accountId);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getFailedPayments(String accountId) async {
    try {
      final paymentModels = await _remoteDataSource.getFailedPayments(accountId);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getSuccessfulPayments(String accountId) async {
    try {
      final paymentModels = await _remoteDataSource.getSuccessfulPayments(accountId);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getPendingPayments(String accountId) async {
    try {
      final paymentModels = await _remoteDataSource.getPendingPayments(accountId);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPayment> createAccountPayment({
    required String accountId,
    required String paymentMethodId,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    String? description,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final paymentModel = await _remoteDataSource.createAccountPayment(
        accountId: accountId,
        paymentMethodId: paymentMethodId,
        transactionType: transactionType,
        amount: amount,
        currency: currency,
        effectiveDate: effectiveDate,
        description: description,
        properties: properties,
      );
      return paymentModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountPayment> createGlobalPayment({
    required String externalKey,
    required String paymentMethodId,
    required String transactionExternalKey,
    required String paymentExternalKey,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    List<Map<String, dynamic>>? properties,
  }) async {
    try {
      final paymentModel = await _remoteDataSource.createGlobalPayment(
        externalKey: externalKey,
        paymentMethodId: paymentMethodId,
        transactionExternalKey: transactionExternalKey,
        paymentExternalKey: paymentExternalKey,
        transactionType: transactionType,
        amount: amount,
        currency: currency,
        effectiveDate: effectiveDate,
        properties: properties,
      );
      return paymentModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
