import 'package:injectable/injectable.dart';
import '../../domain/entities/account_payment.dart';
import '../../domain/repositories/account_payments_repository.dart';
import '../datasources/account_payments_remote_data_source.dart';

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
}
