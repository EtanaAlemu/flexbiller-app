import 'package:injectable/injectable.dart';
import '../../domain/entities/account_invoice_payment.dart';
import '../../domain/repositories/account_invoice_payments_repository.dart';
import '../datasources/account_invoice_payments_remote_data_source.dart';

@Injectable(as: AccountInvoicePaymentsRepository)
class AccountInvoicePaymentsRepositoryImpl implements AccountInvoicePaymentsRepository {
  final AccountInvoicePaymentsRemoteDataSource _remoteDataSource;

  AccountInvoicePaymentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountInvoicePayment>> getAccountInvoicePayments(String accountId) async {
    try {
      final paymentModels = await _remoteDataSource.getAccountInvoicePayments(accountId);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountInvoicePayment> getAccountInvoicePayment(String accountId, String paymentId) async {
    try {
      final paymentModel = await _remoteDataSource.getAccountInvoicePayment(accountId, paymentId);
      return paymentModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByStatus(String accountId, String status) async {
    try {
      final paymentModels = await _remoteDataSource.getInvoicePaymentsByStatus(accountId, status);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final paymentModels = await _remoteDataSource.getInvoicePaymentsByDateRange(accountId, startDate, endDate);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByMethod(String accountId, String paymentMethod) async {
    try {
      final paymentModels = await _remoteDataSource.getInvoicePaymentsByMethod(accountId, paymentMethod);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByInvoiceNumber(String accountId, String invoiceNumber) async {
    try {
      final paymentModels = await _remoteDataSource.getInvoicePaymentsByInvoiceNumber(accountId, invoiceNumber);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final paymentModels = await _remoteDataSource.getInvoicePaymentsWithPagination(accountId, page, pageSize);
      return paymentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getInvoicePaymentStatistics(String accountId) async {
    try {
      return await _remoteDataSource.getInvoicePaymentStatistics(accountId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountInvoicePayment> createInvoicePayment(
    String accountId,
    double paymentAmount,
    String currency,
    String paymentMethod,
    String? notes,
  ) async {
    try {
      final paymentModel = await _remoteDataSource.createInvoicePayment(
        accountId,
        paymentAmount,
        currency,
        paymentMethod,
        notes,
      );
      return paymentModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
